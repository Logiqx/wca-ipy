/*
    Script:   Create Senior Fakes
    Created:  2019-12-22
    Author:   Michael George / 2015GEOR02

    Purpose:  Create artificial / fake results to pad senior rankings
*/

/*
    Create SeniorViews
*/

DROP TABLE IF EXISTS SeniorViews;

CREATE TABLE SeniorViews
AS
SELECT ROW_NUMBER() OVER (ORDER BY runDate, eventId, resultType, ageCategory) AS viewId,
    t1.*, t2.*, t3.*, t4.*
FROM
(
    SELECT DISTINCT runDate
    FROM SeniorStats
) AS t1
JOIN
(
    SELECT DISTINCT id AS eventId
    FROM wca.Events
) AS t2
JOIN
(
    SELECT DISTINCT resultType
    FROM SeniorStats
) AS t3
JOIN
(
    SELECT DISTINCT ageCategory
    FROM SeniorStats
) AS t4
ORDER BY runDate, eventId, resultType, ageCategory;

ALTER TABLE SeniorViews ADD PRIMARY KEY (viewId);
ALTER TABLE SeniorViews ADD UNIQUE KEY SeniorViewsCompositeKey (runDate, eventId, resultType, ageCategory);

/*
    Create improved senior stats table, including totals and awareness of neighbouring groups
*/

-- DROP TEMPORARY TABLE IF EXISTS SeniorStatsExtra;

CREATE TEMPORARY TABLE SeniorStatsExtra AS
SELECT sv.viewId, groupNo, groupSize,
    SUM(groupSize) OVER (PARTITION BY viewId ORDER BY groupNo) AS totSeniors,
    LAG(groupResult) OVER (PARTITION BY viewId ORDER BY groupNo) AS prevResult,
    groupResult,
    LEAD(groupResult) OVER (PARTITION BY viewId ORDER BY groupNo) AS nextResult
FROM SeniorStats AS ss
JOIN SeniorViews AS sv ON sv.runDate = ss.runDate AND sv.eventId = ss.eventId AND sv.resultType = ss.resultType AND sv.ageCategory = ss.ageCategory
JOIN (SELECT MAX(runDate) AS runDate FROM SeniorViews) AS t ON t.runDate = ss.runDate;

ALTER TABLE SeniorStatsExtra ADD PRIMARY KEY (viewId, groupNo);

/*
    Create table containing senior bests (averages and singles)
*/

-- DROP TEMPORARY TABLE IF EXISTS SeniorBests;

CREATE TEMPORARY TABLE SeniorBests AS
SELECT viewId, ROW_NUMBER() OVER (PARTITION BY viewId ORDER BY best, personId) - 1 AS rowNo, personId, best
FROM
(
    SELECT runDate, eventId, resultType, seq AS ageCategory, personId, MIN(best) AS best
    FROM
    (
        SELECT s.runDate, r.eventId, 'average' AS resultType, r.personId, r.average AS best,
            TIMESTAMPDIFF(YEAR,dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
        FROM Seniors AS p
        JOIN (SELECT MAX(runDate) AS runDate FROM SeniorStats) AS s
        JOIN wca.Results AS r ON r.personId = p.personId AND average > 0
        JOIN wca.Competitions AS c ON c.id = r.competitionId AND DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') < s.runDate
        WHERE YEAR(dob) <= YEAR(CURDATE()) - 40
        AND accuracyId NOT IN ('x', 'y')
        HAVING age_at_comp >= 40
        UNION ALL
        SELECT s.runDate, r.eventId, 'single' AS resultType, r.personId, r.best,
            TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
        FROM Seniors AS p
        JOIN (SELECT MAX(runDate) AS runDate FROM SeniorStats) AS s
        JOIN wca.Results AS r ON r.personId = p.personId AND best > 0
        JOIN wca.Competitions AS c ON c.id = r.competitionId AND DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') < s.runDate
        WHERE YEAR(dob) <= YEAR(CURDATE()) - 40
        AND accuracyId NOT IN ('x', 'y')
        HAVING age_at_comp >= 40
    ) AS t
    JOIN seq_40_to_100_step_10 ON seq <= age_at_comp
    GROUP BY eventId, resultType, ageCategory, personId
) AS t
JOIN SeniorViews AS sv ON sv.runDate = t.runDate AND sv.eventId = t.eventId AND sv.resultType = t.resultType AND sv.ageCategory = t.ageCategory;

ALTER TABLE SeniorBests ADD PRIMARY KEY (viewId, rowNo);

/*
    Create improved senior bests table, including rolling averages
*/

-- DROP TEMPORARY TABLE IF EXISTS SeniorBestsExtra;

CREATE TEMPORARY TABLE SeniorBestsExtra AS
SELECT viewId, rowNo, personId, best,
    FLOOR(MIN(best) OVER (PARTITION BY viewId ORDER BY rowNo ROWS 5 PRECEDING)) AS rollingMin,
    FLOOR(AVG(best) OVER (PARTITION BY viewId ORDER BY rowNo ROWS 5 PRECEDING)) AS rollingAvg
FROM SeniorBests;

ALTER TABLE SeniorBestsExtra ADD PRIMARY KEY (viewId, rowNo);
ALTER TABLE SeniorBestsExtra ADD INDEX SeniorBestsExtra_rollingAverage (viewId, rollingAvg);

/*
    Pre-processing - Patch final group(s) in each view where the 'average' may be NULL
*/

-- Use the slowest results in the WCA to patch the final groups (where necessary)
UPDATE SeniorStatsExtra AS ss
JOIN SeniorViews AS sv ON sv.viewId = ss.viewId
JOIN
(
    SELECT eventId, MAX(best) AS maxSingle, MAX(average) AS maxAverage
    FROM wca.Results AS r
    GROUP BY eventId
) AS t ON t.eventId = sv.eventId
SET ss.groupResult = IF(sv.resultType = 'single', maxSingle, maxAverage)
WHERE groupResult IS NULL;

-- Fix any groups preceding the ones patched by the last query
UPDATE SeniorStatsExtra AS ss1
JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo + 1
SET ss1.nextResult = ss2.groupResult
WHERE ss1.nextResult IS NULL;

-- Get ready for the actual processing
ALTER TABLE SeniorStatsExtra ADD
(
    minRowNo smallint(6),
    maxRowNo smallint(6),
    minResult int(11),
    maxResult int(11),
    stepNo tinyint(2)
);

/*
   Step 1 - Process groups with matching averages, using rolling averages of 6
*/

-- DROP TEMPORARY TABLE IF EXISTS SeniorGroups;

-- Create temporary table to speed up the step 1 processing
CREATE TEMPORARY TABLE SeniorGroups AS
SELECT ss.viewId, ss.groupNo, sb.rowNo, sb.rollingMin, sb.best
FROM SeniorStatsExtra AS ss
JOIN SeniorBestsExtra AS sb ON sb.viewId = ss.viewId AND sb.rollingAvg = ss.groupResult
WHERE rowNo >= groupSize - 1;

ALTER TABLE SeniorGroups ADD INDEX SeniorGroups (viewId, groupNo);

-- Determine most likely groups based on matching rolling averages #1 (required for FMC singles)
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT sg1.viewId, sg1.groupNo, MIN(sg1.rollingMin) AS rollingMin, MIN(sg1.best) AS best, MIN(sg1.rowNo) AS rowNo
    FROM SeniorGroups AS sg1
    JOIN SeniorGroups AS sg2 ON sg2.viewId = sg1.viewId AND sg2.groupNo = sg1.groupNo - 1 AND sg2.rowNo = sg1.rowNo - 6
    JOIN SeniorGroups AS sg3 ON sg3.viewId = sg1.viewId AND sg3.groupNo = sg1.groupNo + 1 AND sg3.rowNo = sg1.rowNo + 6
    GROUP BY sg1.viewId, sg1.groupNo
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET minRowNo = IF(rowNo - 5 > 0, rowNo - 5, 0), maxRowNo = rowNo, minResult = rollingMin, maxResult = best, stepNo = 1
WHERE stepNo IS NULL;

-- Determine likely groups based on matching rolling averages #2 (avoiding overlaps with previous group)
UPDATE SeniorStatsExtra AS ss1
JOIN SeniorGroups AS sg ON sg.viewId = ss1.viewId AND sg.groupNo = ss1.groupNo
SET minRowNo = IF(rowNo - 5 > 0, rowNo - 5, 0), maxRowNo = rowNo, minResult = rollingMin, maxResult = best, stepNo = 1
WHERE NOT EXISTS
(
    SELECT 1
    FROM SeniorStatsExtra AS ss2
    WHERE ss2.viewId = ss1.viewId
    AND ss2.groupNo = ss1.groupNo - 1
    AND ss2.maxRowNo >= IF(rowNo - 5 > 0, rowNo - 5, 0)
)
AND NOT EXISTS
(
    SELECT 1
    FROM SeniorStatsExtra AS ss3
    WHERE ss3.viewId = ss1.viewId
    AND ss3.groupNo = ss1.groupNo + 1
    AND ss3.minRowNo <= rowNo
)
AND stepNo IS NULL;

-- Reset any overlapping groups
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT ss2.viewId, ss2.groupNo
    FROM SeniorStatsExtra AS ss1
    JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo > ss1.groupNo
    WHERE ss2.minRowNo <= ss1.maxRowNo
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET minRowNo = NULL, maxRowNo = NULL, minResult = NULL, maxResult = NULL, stepNo = NULL;

-- Reset any groups where a gap (invalid) is present before the next group - rare but important!
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT ss2.viewId, ss2.groupNo
    FROM SeniorStatsExtra AS ss1
    JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo + 1
    WHERE ss2.minRowNo > ss1.maxRowNo + 1
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET minRowNo = NULL, maxRowNo = NULL, minResult = NULL, maxResult = NULL, stepNo = NULL;

-- Reset any excessively wide groups
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT ss1.viewId, ss1.groupNo
    FROM SeniorStatsExtra AS ss1
    JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo - 1
    WHERE ss1.minResult < ss1.groupResult - (ss1.groupResult - ss1.prevResult) * 0.8
    AND ss2.prevResult IS NOT NULL AND ss2.stepNo IS NULL
    UNION
    SELECT ss1.viewId, ss1.groupNo
    FROM SeniorStatsExtra AS ss1
    JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo + 1
    WHERE ss1.maxResult > ss1.groupResult + (ss1.nextResult - ss1.groupResult) * 0.8
    AND ss2.nextResult IS NOT NULL AND ss2.stepNo IS NULL
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET minRowNo = NULL, maxRowNo = NULL, minResult = NULL, maxResult = NULL, stepNo = NULL;

/*
   Step 2 - Process groups sandwiched between groups identified in step 1
*/

-- Propagate max row to next group
UPDATE SeniorStatsExtra AS ss1
JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo - 1 AND ss2.maxRowNo IS NOT NULL
SET ss1.minRowNo = ss2.maxRowNo + 1
WHERE ss1.minRowNo IS NULL;

-- Propagate min row to previous group
UPDATE SeniorStatsExtra AS ss1
JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId    AND ss2.groupNo = ss1.groupNo + 1 AND ss2.minRowNo IS NOT NULL
SET ss1.maxRowNo = ss2.minRowNo - 1
WHERE ss1.maxRowNo IS NULL;

-- Process fully enclosed groups, including first and last groups
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT ss.viewId, groupNo, MIN(rowNo) AS minRowNo, MAX(rowNo) AS maxRowNo, MIN(best) AS minResult, MAX(best) AS maxResult
    FROM SeniorStatsExtra AS ss
    JOIN SeniorBestsExtra AS sb ON sb.viewId = ss.viewId
        AND (sb.rowNo >= ss.minRowNo OR prevResult IS NULL) AND (sb.rowNo <= ss.maxRowNo OR nextResult IS NULL)
    WHERE stepNo IS NULL
    GROUP BY viewId, groupNo
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET ss.minRowNo = t.minRowNo, ss.maxRowNo = t.maxRowNo, ss.minResult = t.minResult, ss.maxResult = t.maxResult, stepNo = 2;

/*
   Step 3 - Process groups with a single known boundary
*/

-- Process groups with undefined max row (includes first groups)
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT ss.viewId, ss.groupNo, MIN(rowNo) AS minRowNo, MAX(rowNo) AS maxRowNo, MIN(best) AS minResult, MAX(best) AS maxResult
    FROM SeniorStatsExtra AS ss
    JOIN SeniorBestsExtra AS sb ON sb.viewId = ss.viewId
        AND (rowNo >= minRowNo OR prevResult IS NULL) AND best <= (groupResult + nextResult) / 2
    WHERE stepNo IS NULL
    GROUP BY viewId, groupNo
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET ss.minRowNo = t.minRowNo, ss.maxRowNo = t.maxRowNo, ss.minResult = t.minResult, ss.maxResult = t.maxResult, ss.stepNo = 3;

-- Process groups with undefined min row (includes final groups)
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT ss.viewId, ss.groupNo, MIN(rowNo) AS minRowNo, MAX(rowNo) AS maxRowNo, MIN(best) AS minResult, MAX(best) AS maxResult
    FROM SeniorStatsExtra AS ss
    JOIN SeniorBestsExtra AS sb ON sb.viewId = ss.viewId
        AND best > (prevResult + groupResult) / 2 AND (rowNo <= maxRowNo OR nextResult IS NULL)
    WHERE stepNo IS NULL
    GROUP BY viewId, groupNo
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET ss.minRowNo = t.minRowNo, ss.maxRowNo = t.maxRowNo, ss.minResult = t.minResult, ss.maxResult = t.maxResult, ss.stepNo = 3;

/*
   Step 4 - Soft match where prev and next groups unknown, including first and last groups
*/

UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT ss.viewId, ss.groupNo, MIN(rowNo) AS minRowNo, MAX(rowNo) AS maxRowNo, MIN(best) AS minResult, MAX(best) AS maxResult
    FROM SeniorStatsExtra AS ss
    JOIN SeniorBestsExtra AS sb ON sb.viewId = ss.viewId AND minRowNo IS NULL AND maxRowNo IS NULL
        AND (best > (prevResult + groupResult) / 2 OR prevResult IS NULL) AND (best <= (groupResult + nextResult) / 2 OR nextResult IS NULL)
    WHERE stepNo IS NULL
    GROUP BY viewId, groupNo
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET ss.minRowNo = t.minRowNo, ss.maxRowNo = t.maxRowNo, ss.minResult = t.minResult, ss.maxResult = t.maxResult, ss.stepNo = 4;

/*
    Post processing - Calculate averages, totals, counts, etc.
*/

ALTER TABLE SeniorStatsExtra ADD
(
    totResult bigint(12),
    avgResult int(11),
    numRows smallint(6),
    numMissing smallint(6),
    totRows smallint(6),
    totMissing smallint(6)
);

UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT t.*, SUM(numRows) OVER (PARTITION BY viewId ORDER BY groupNo) AS totRows
    FROM
    (
        SELECT ss.viewId, ss.groupNo, SUM(best) AS totResult, FLOOR(AVG(best)) AS avgResult, COUNT(personId) AS numRows
        FROM SeniorStatsExtra AS ss
        LEFT JOIN SeniorBestsExtra AS sb ON sb.viewId = ss.viewId AND rowNo BETWEEN minRowNo AND maxRowNo
        GROUP BY ss.viewId, ss.groupNo
    ) AS t
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET ss.totResult = t.totResult, ss.avgResult = t.avgResult, ss.numRows = t.numRows, ss.totRows = t.totRows,
    ss.numMissing = ss.groupSize - t.numRows, ss.totMissing = ss.totSeniors - t.totRows;

-- Ensure that total missing is not negative
UPDATE SeniorStatsExtra
SET totMissing = 0
WHERE totMissing < 0;

-- Transfer total missing from later groups to earlier groups, where it is a smaller number
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT viewId, groupNo, MIN(totMissing) OVER (PARTITION BY viewId ORDER BY groupNo RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS totMissing
    FROM SeniorStatsExtra
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET ss.totMissing = t.totMissing
WHERE ss.totMissing > t.totMissing;

-- Fix number missing for the first group, ensuring consistency with total missing
UPDATE SeniorStatsExtra AS ss
SET numMissing = totMissing
WHERE prevResult IS NULL
AND numMissing != totMissing;

-- Fix number missing for all other groups, ensuring consistency with total missing
UPDATE SeniorStatsExtra AS ss
JOIN
(
    SELECT viewId, groupNo, totMissing - LAG(totMissing) OVER (PARTITION BY viewId ORDER BY groupNo) AS numMissing
    FROM SeniorStatsExtra
) AS t ON t.viewId = ss.viewId AND t.groupNo = ss.groupNo
SET ss.numMissing = t.numMissing
WHERE ss.numMissing != t.numMissing;

/*
    Generate artificial / fake results for missing seniors
*/

DROP TABLE IF EXISTS SeniorFakes;

CREATE TABLE SeniorFakes AS
(
    -- Most artificial results are created using ranges and intervals
    SELECT viewId, CAST(fakeResult AS unsigned integer) AS fakeResult, groupNo, numMissing, CONVERT('FAKE_RANGE' USING utf8) AS fakeId
    FROM
    (
        SELECT viewId,
            ROUND((groupResult - fakeRange / 2 + fakeInterval / 2) + fakeInterval * seq) AS fakeResult,
            groupNo, numMissing
        FROM
        (
            SELECT *,
                IFNULL(IF(groupResult - prevResult < nextResult - groupResult OR nextResult IS NULL,
                    groupResult - prevResult, nextResult - groupResult), 0) AS fakeRange,
                IFNULL(IF(groupResult - prevResult < nextResult - groupResult OR nextResult IS NULL,
                    groupResult - prevResult, nextResult - groupResult), 0) / numMissing AS fakeInterval
            FROM SeniorStatsExtra
            WHERE (NOT stepNo <=> 2 AND numMissing > 0) OR (stepNo = 2 AND numMissing > 1) OR (stepNo = 2 AND groupSize < 4)
        ) AS t
        JOIN seq_0_to_5 ON seq < numMissing
    ) AS t
)
UNION ALL
(
    -- A small number of artificial results can be exactly calculated
    SELECT viewId, CAST(groupResult * groupSize - totResult AS unsigned integer) AS fakeResult, groupNo, numMissing, CONVERT('FAKE_EXACT' USING utf8) AS fakeId
    FROM SeniorStatsExtra
    WHERE stepNo = 2
    AND numMissing = 1
    AND groupSize >= 4
);
