/* 
    Script:   Extract Counts World
    Created:  2020-01-27
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract worldwide counts - total number of seniors per event per age category
*/

/*
    Determine WCA counts - not just seniors
*/

-- DROP TEMPORARY TABLE IF EXISTS WcaStats;

CREATE TEMPORARY TABLE WcaStats AS
(
  SELECT eventId, 'average' AS resultType, COUNT(*) AS numPersons, MAX(worldRank) AS maxRank
  FROM wca.RanksAverage AS r
  GROUP BY eventId
 )
 UNION ALL
 (
  SELECT eventId, 'single' AS resultType, COUNT(*) AS numPersons, MAX(worldRank) AS maxRank
  FROM wca.RanksSingle AS r
  GROUP BY eventId
);

ALTER TABLE WcaStats ADD PRIMARY KEY (eventId, resultType);

/*
    Determine known seniors
*/

SET @runDate = (SELECT MAX(runDate) FROM SeniorStats);

-- DROP TEMPORARY TABLE IF EXISTS KnownSeniors;

CREATE TEMPORARY TABLE KnownSeniors AS
SELECT DISTINCT eventId, CONVERT(resultType USING utf8) AS resultType, seq AS ageCategory, personId
FROM
(
    SELECT r.eventId, 'average' AS resultType, r.personId,
        TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM Seniors AS p
    JOIN wca.Results AS r ON r.personId = p.personId AND average > 0
    JOIN wca.Competitions AS c ON c.id = r.competitionId AND DATE_FORMAT(CONCAT(c.year + IF(c.endMonth < c.month, 1, 0), '-', c.endMonth, '-', c.endDay), '%Y-%m-%d') < @runDate
    WHERE YEAR(dob) <= YEAR(CURDATE()) - 40
    HAVING age_at_comp >= 40
    UNION ALL
    SELECT r.eventId, 'single' AS resultType, r.personId,
        TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM Seniors AS p
    JOIN wca.Results AS r ON r.personId = p.personId AND best > 0
    JOIN wca.Competitions AS c ON c.id = r.competitionId AND DATE_FORMAT(CONCAT(c.year + IF(c.endMonth < c.month, 1, 0), '-', c.endMonth, '-', c.endDay), '%Y-%m-%d') < @runDate
    WHERE YEAR(dob) <= YEAR(CURDATE()) - 40
    HAVING age_at_comp >= 40
) AS t
JOIN seq_40_to_100_step_10 ON seq <= age_at_comp;

ALTER TABLE KnownSeniors ADD PRIMARY KEY (eventId, resultType, ageCategory, personId);

/*
    Calculate missing counts
*/

DROP TABLE IF EXISTS MissingWorld;

CREATE TABLE MissingWorld AS
SELECT t1.eventId, t1.resultType, t1.ageCategory, maxRank, numPersons, numSeniors, knownSeniors, numSeniors - knownSeniors AS missingSeniors
FROM 
(
    SELECT eventId, resultType, ageCategory, COUNT(*) AS knownSeniors
    FROM KnownSeniors
    GROUP BY eventId, resultType, ageCategory
) AS t1
LEFT JOIN
(
    SELECT eventId, resultType, ageCategory, SUM(groupSize) AS numSeniors
    FROM SeniorStats
    GROUP BY eventId, resultType, ageCategory
) AS t2 ON t2.eventId = t1.eventId AND t2.resultType = t1.resultType AND t2.ageCategory = t1.ageCategory
LEFT JOIN WcaStats AS ws ON ws.eventId = t1.eventId AND ws.resultType = t1.resultType;

ALTER TABLE MissingWorld ADD PRIMARY KEY (eventId, resultType, ageCategory);

/*
    Patch missing counts
*/

-- Count cannot be negative
UPDATE MissingWorld
SET missingSeniors = 0
WHERE missingSeniors < 0;

/*
    Extract missing counts
*/

SELECT *
FROM MissingWorld
WHERE missingSeniors IS NOT NULL
ORDER BY eventId, resultType, ageCategory;
