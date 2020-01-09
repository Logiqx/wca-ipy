/*
    Script:   Review Senior Fakes
    Created:  2019-12-27
    Author:   Michael George / 2015GEOR02

    Purpose:  Review senior fakes for curiosities
*/

-- Summarise seniors by event
SELECT eventId, resultType, ageCategory,
    totSeniors, knownSeniors, totSeniors - knownSeniors AS missingSeniors, IFNULL(topSeniors, 0) AS topSeniors,
    ROUND(100 * knownSeniors / totSeniors, 2) AS pctKnownSeniors,
    ROUND(100 * (totSeniors - knownSeniors) / totSeniors, 2) AS pctMissingSeniors,
    ROUND(100 * IFNULL(topSeniors, 0) / totSeniors, 2) AS pctTopSeniors
FROM
(
    SELECT viewId, MAX(totSeniors) AS totSeniors, MAX(totRows) AS knownSeniors
    FROM SeniorStatsExtra AS ss1
    GROUP BY viewId
)
AS t1
LEFT JOIN
(
    SELECT ss1.viewId, MAX(totRows) AS topSeniors
    FROM SeniorStatsExtra AS ss1
    WHERE stepNo BETWEEN 1 AND 2
    AND numRows >= groupSize - 1
    AND NOT EXISTS
    (
        SELECT 1
        FROM SeniorStatsExtra AS ss2
        WHERE ss2.viewId = ss1.viewId
        AND ss2.groupNo < ss1.groupNo
        AND (NOT stepNo BETWEEN 1 AND 2 OR numRows < groupSize - 1)
    )
    GROUP BY viewId
) AS t2 ON t2.viewId = t1.viewId
JOIN SeniorViews AS sv on sv.viewId = t1.viewId
WHERE eventId NOT IN ('magic', 'mmagic', '333mbo')
ORDER BY eventId, ageCategory, resultType DESC;

-- Check for matching results (commonplace)

SELECT eventId, resultType, ageCategory, sb.viewId, best, MIN(rowNo), MAX(rowNo), COUNT(*)
FROM SeniorBestsExtra AS sb
JOIN SeniorViews AS sv ON sv.viewId = sb.viewId
GROUP BY viewId, best
HAVING COUNT(*) > 1;

-- Check for matching rolling averages (typically 333fm single)

SELECT eventId, resultType, ageCategory, sb.viewId, rollingAvg, MIN(rowNo), MAX(rowNo), COUNT(*)
FROM SeniorBestsExtra AS sb
JOIN SeniorViews AS sv ON sv.viewId = sb.viewId
GROUP BY viewId, rollingAvg
HAVING COUNT(*) > 1;

-- Only min or max row is curious but not significant
SELECT 'Curious row' AS label, sv.*, ss.*
FROM SeniorStatsExtra AS ss
JOIN SeniorViews AS sv on sv.viewId = ss.viewId
WHERE (minRowNo IS NULL AND maxRowNo IS NOT NULL)
    OR (minRowNo IS NOT NULL AND maxRowNo IS NULL);

-- Check where propogation of numMissing had an effect
SELECT 'Incorrect totals' AS label, sv.*, ss.*
FROM SeniorStatsExtra AS ss
JOIN SeniorViews AS sv on sv.viewId = ss.viewId
WHERE totSeniors < totRows + totMissing;

-- Check for rolling averages that haven't been used despite exact match
-- TODO - Investigate 333mbf
SELECT sv.*, ss.*
FROM SeniorStatsExtra AS ss
JOIN SeniorViews AS sv ON sv.viewId = ss.viewId
JOIN SeniorBestsExtra AS sb ON sb.viewId = ss.viewId AND sb.rollingAvg = ss.groupResult
WHERE stepNo IS NULL;

-- Check for groups with large numbers of missing seniors
SELECT 'Unknowns' AS label, sv.*,
    MIN(numMissing) AS minNumMissing, MAX(numMissing) AS maxNumMissing,
    MIN(ss.groupNo) AS firstGroupNo, MIN(ss.totSeniors) AS firstTotSeniors
FROM SeniorStatsExtra AS ss
JOIN SeniorViews AS sv ON sv.viewId = ss.viewId
WHERE numMissing BETWEEN 4 AND 5
-- AND ageCategory = 50
GROUP BY ss.viewId;

-- Check for fake results outside of sensible range #1
SELECT sv.*, ss.*, sf.*
FROM SeniorFakes AS sf
JOIN SeniorStatsExtra AS ss ON ss.viewId = sf.viewId AND ss.groupNo = sf.groupNo
JOIN SeniorViews AS sv ON sv.viewId = sf.viewId
WHERE fakeResult < groupResult - (groupResult - prevResult) * 0.8
OR fakeResult > groupResult + (nextResult - groupResult) * 0.8;

-- Check for fake results outside of sensible range #2
SELECT sv.*, ss2.*, sf.*
FROM SeniorFakes AS sf
JOIN SeniorStatsExtra AS ss1 ON ss1.viewId = sf.viewId AND ss1.groupNo = sf.groupNo
JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo - 1
JOIN SeniorViews AS sv ON sv.viewId = sf.viewId
WHERE fakeResult < ss2.maxResult;

-- Check for fake results outside of sensible range #3
SELECT sv.*, ss2.*, sf.*
FROM SeniorFakes AS sf
JOIN SeniorStatsExtra AS ss1 ON ss1.viewId = sf.viewId AND ss1.groupNo = sf.groupNo
JOIN SeniorStatsExtra AS ss2 ON ss2.viewId = ss1.viewId AND ss2.groupNo = ss1.groupNo + 1
JOIN SeniorViews AS sv ON sv.viewId = sf.viewId
WHERE fakeResult > ss2.minResult;
