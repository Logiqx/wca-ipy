/* 
      Script:   Check Seniors
      Created:  2019-05-20
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Review seniors from a data quality perspective
*/

USE wca_ipy;

-- List the over 40s
SELECT 'Over 40' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 40;

-- List the over 50s
SELECT 'Over 50' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 50;

-- List the over 60s
SELECT 'Over 60' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 60;

-- List the over 70s
SELECT 'Over 70' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 70;

-- List the over 80s
SELECT 'Over 80' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 80;

-- List the over 90s
SELECT 'Over 90' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 90;

-- List the delegates appearing in the senior rankings
SELECT 'Delegate' AS label, delegate_status, s.*
FROM SeniorDetails AS s
JOIN wca_dev.users u ON u.wca_id = s.personId AND delegate_status IS NOT NULL;

-- List the possible 'embassadors' for the senior rankings
WITH SeniorYears AS
(
    SELECT r.personId, c.year, COUNT(DISTINCT competitionId) AS numComps
    FROM wca.Results AS r
    JOIN wca.Competitions AS c ON c.id = r.competitionId
    JOIN wca_ipy.Seniors AS s ON s.personId = r.personId
    GROUP BY r.personId, c.year
)
SELECT 'Embassador', IFNULL(y0.numComps, 0) AS numComps0, IFNULL(y1.numComps, 0) AS numComps1, IFNULL(y2.numComps, 0) AS numComps2, s.*
FROM SeniorDetails s
LEFT JOIN SeniorYears y0 ON y0.personId = s.personId and y0.year = YEAR(NOW())
LEFT JOIN SeniorYears y1 ON y1.personId = s.personId and y1.year = YEAR(NOW()) - 1
LEFT JOIN SeniorYears y2 ON y2.personId = s.personId and y2.year = YEAR(NOW()) - 2
HAVING numComps1 >= 6 AND numComps0 >= CEIL((MONTH(NOW()) - 1) / 2)
AND ageToday >= 40;

-- Speedsolving.com users to be discovered / scraped from Google
SELECT 'Speedsolving.com' AS label, s.*
FROM SeniorDetails AS s
WHERE usernum = 0;

-- List hidden seniors (typically women)
SELECT 'Hidden' AS label, s.*
FROM SeniorDetails AS s
WHERE hidden = 'Y'
AND sourceId NOT IN ('D', 'H');

-- Imprecise DOBs
SELECT 'Imprecise DOB' AS label, s.*
FROM SeniorDetails AS s
WHERE accuracyId NOT IN ('D', 'M')
ORDER BY accuracyId, personId;

-- Summarise the accuracy of DOB information
SELECT 'Accuracy' AS label, accuracyType, hidden, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails s
GROUP BY accuracyType, hidden
ORDER BY numCompSeniors DESC;

-- Summarise the comment types
SELECT 'Comment' AS label, LEFT(comment, LOCATE(' ', comment) - 1) AS commentType, hidden, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails s
GROUP BY commentType, hidden
ORDER BY numCompSeniors DESC;

-- Summarise the sources
SELECT 'Source' AS label, sourceType, hidden, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails s
GROUP BY sourceType, hidden
ORDER BY numCompSeniors DESC, sourceType, hidden;

-- Summarise people spotted on the internet - Facebook, WCA, Speedsolving, etc
SELECT sourceType, hidden, accuracyType, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Spotted%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY numCompSeniors DESC, sourceType, hidden, accuracyType;

-- Summarise people who pro-actively provided their information (or someone did so on their behalf)
SELECT sourceType, hidden, accuracyType, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Provided%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY numCompSeniors DESC, sourceType, hidden, accuracyType;

-- Summarise people where DOB / YOB was found on the internet - Facebook, Wikipedia, Speedsolving, etc
SELECT sourceType, hidden, accuracyType, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Found%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY numCompSeniors DESC, sourceType, hidden, accuracyType;

-- Summarise people contacted via Facebook
SELECT sourceType, hidden, accuracyType, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Contacted%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY numCompSeniors DESC, sourceType, hidden, accuracyType;

-- Summarise speculative additions - friends of friends, etc.
SELECT sourceType, hidden, accuracyType, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Speculative%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY numCompSeniors DESC, sourceType, hidden, accuracyType;

-- Summarise hidden seniors (typically women)
SELECT sourceType, hidden, accuracyType, SUM(IF(ageToday >= 40, 1, 0)) AS numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numCompSeniors
FROM SeniorDetails AS s
WHERE hidden = 'Y'
GROUP BY sourceType, hidden, accuracyType
ORDER BY numCompSeniors DESC, sourceType, hidden, accuracyType;

-- Count of "active" seniors
SELECT COUNT(*) as numSeniors, SUM(IF(ageLastComp >= 40, 1, 0)) AS numActiveSeniors, SUM(IF(ageLastComp >= 40 AND hidden = 'N', 1, 0)) AS numListedSeniors
FROM SeniorDetails;
