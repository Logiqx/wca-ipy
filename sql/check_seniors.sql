/* 
      Script:   Check Seniors
      Created:  2019-05-20
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Review seniors from a data quality perspective
*/

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
    SELECT p.id AS personId, c.year, COUNT(DISTINCT competitionId) AS numComps
    FROM Results AS r
    JOIN Competitions AS c ON r.competitionId = c.id
    JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
    GROUP BY p.id, c.year
)
SELECT 'Embassador', IFNULL(y0.numComps, 0) AS numComps0, IFNULL(y1.numComps, 0) AS numComps1, IFNULL(y2.numComps, 0) AS numComps2, s.*
FROM SeniorDetails s
LEFT JOIN SeniorYears y0 ON y0.personId = s.personId and y0.year = YEAR(NOW())
LEFT JOIN SeniorYears y1 ON y1.personId = s.personId and y1.year = YEAR(NOW()) - 1
LEFT JOIN SeniorYears y2 ON y2.personId = s.personId and y2.year = YEAR(NOW()) - 2
HAVING numComps1 >= 6 AND numComps0 >= CEIL((MONTH(NOW()) - 1) / 2);

-- Summarise the sources
SELECT 'Source' AS label, sourceType, COUNT(*) AS numSeniors
FROM SeniorDetails s
GROUP BY sourceType
ORDER BY numSeniors DESC;

-- Summarise the comment types
SELECT 'Comment' AS label, LEFT(comment, LOCATE(' ', comment) - 1) AS commentType, COUNT(*) AS numSeniors
FROM SeniorDetails s
GROUP BY commentType
ORDER BY numSeniors DESC;

-- Summarise people spotted on the internet - Facebook, WCA, Speedsolving, etc
SELECT sourceType, hidden, accuracyType, COUNT(*) AS numSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Spotted%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY sourceType, hidden, numSeniors DESC;

-- Summarise people who pro-actively provided their information (or someone did so on their behalf)
SELECT sourceType, hidden, accuracyType, COUNT(*) AS numSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Provided%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY sourceType, hidden, numSeniors DESC;

-- Summarise people where DOB / YOB was found on the internet - Facebook, Wikipedia, Speedsolving, etc
SELECT sourceType, hidden, accuracyType, COUNT(*) AS numSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Found%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY sourceType, hidden, numSeniors DESC;

-- Summarise people contacted via Facebook
SELECT sourceType, hidden, accuracyType, COUNT(*) AS numSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Contacted%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY sourceType, hidden, numSeniors DESC;

-- Summarise speculative additions - friends of friends, etc.
SELECT sourceType, hidden, accuracyType, COUNT(*) AS numSeniors
FROM SeniorDetails AS s
WHERE comment LIKE 'Speculative%'
GROUP BY sourceType, hidden, accuracyType
ORDER BY sourceType, hidden, numSeniors DESC;

-- Summarise the accuracy of DOB information
SELECT 'Accuracy' AS label, accuracyType, COUNT(*) AS numSeniors
FROM SeniorDetails s
GROUP BY accuracyType
ORDER BY numSeniors DESC;

-- Imprecise DOBs
SELECT 'Imprecise DOB' AS label, s.*
FROM SeniorDetails AS s
WHERE accuracyId NOT IN ('D', 'M', 'S')
ORDER BY accuracyId;

-- Speedsolving.com users to be discovered / scraped from Google
SELECT 'Speedsolving.com' AS label, s.*
FROM SeniorDetails AS s
WHERE usernum = 0;
