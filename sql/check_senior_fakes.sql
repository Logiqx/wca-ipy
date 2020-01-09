/*
    Script:   Check Senior Fakes
    Created:  2019-12-27
    Author:   Michael George / 2015GEOR02

    Purpose:  Check senior fakes for processing errors
*/

/*
   Sanity checks
*/

-- NULL groupResult implies pre-processing was incomplete
SELECT 'Poor pre-processing' AS label, sv.*, ss.*
FROM SeniorStatsExtra AS ss
JOIN SeniorViews AS sv ON sv.viewId = ss.viewId
WHERE groupResult IS NULL;

-- Check numRows always matches row numbers
SELECT 'Incorrect numRows' AS label, sv.*, ss.*
FROM SeniorStatsExtra AS ss
JOIN SeniorViews AS sv on sv.viewId = ss.viewId
WHERE numRows != maxRowNo - minRowNo + 1;

-- Check last row
SELECT 'Incorrect totals' AS label, sv.*, ss.*
FROM SeniorStatsExtra AS ss
JOIN SeniorViews AS sv on sv.viewId = ss.viewId
WHERE nextResult IS NULL
AND totSeniors != totRows + totMissing;

-- Check totals of the two tables
SELECT 'Incorrect count' AS label, sv.*, t1.viewId, t1.totRows, t2.numPersons
FROM
(
    SELECT ss.viewId, SUM(numRows) AS totRows
    FROM SeniorStatsExtra AS ss
    GROUP BY viewId
) AS t1
JOIN
(
    SELECT viewId, COUNT(DISTINCT personId) AS numPersons
    FROM SeniorBests
    GROUP BY viewId
) AS t2 ON t2.viewId = t1.viewId
JOIN SeniorViews AS sv ON sv.viewId = t1.viewId
WHERE NOT totRows = numPersons;

-- List exceptions
SELECT 'Missing result' AS label, sv.*, sb.rowNo, sb.personId, sb.best
FROM SeniorBestsExtra AS sb
JOIN SeniorViews AS sv ON sv.viewId = sb.viewId
LEFT JOIN SeniorStatsExtra AS ss ON ss.viewId = sb.viewId AND rowNo BETWEEN minRowNo AND maxRowNo
WHERE ss.viewId IS NULL;

-- Check for change in totMissing
SELECT 'totMissing', sv.*, ss2.*
FROM SeniorStatsExtra AS ss1
JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo + 1
JOIN SeniorViews AS sv ON sv.viewId = ss1.viewId
WHERE ss2.totMissing < ss1.totMissing;

-- ???
SELECT 'totMissing', sv.*, t.*
FROM
(
    SELECT *, MAX(totMissing) OVER (PARTITION BY viewId ORDER BY groupNo) AS maxTotMissing
    FROM SeniorStatsExtra
) AS t
JOIN SeniorViews AS sv ON sv.viewId = t.viewId
WHERE t.maxTotMissing > t.totMissing
ORDER BY t.viewId, groupNo;

-- Evaluate Overall Counts
SELECT t.viewId, eventId, resultType, ageCategory, SUM(groupSize) AS expectedRecs, numRecs
FROM
(
    SELECT viewId, COUNT(*) AS numRecs
    FROM
    (
        SELECT viewId, fakeResult AS best, 'fake' AS label
        FROM SeniorFakes
        UNION ALL
        SELECT viewId, best, 'real' AS label
        FROM SeniorBests
    ) AS t
    GROUP BY viewId
) AS t
JOIN SeniorStatsExtra AS ss ON ss.viewId = t.viewId
JOIN SeniorViews AS sv ON sv.viewId = t.viewId
GROUP BY viewId
HAVING numRecs != expectedRecs;
