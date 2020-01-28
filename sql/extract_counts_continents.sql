/* 
    Script:   Extract Counts Continents
    Created:  2020-01-27
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract continent counts - total number of seniors per event per age category
*/

/*
    Determine WCA counts - not just seniors
*/

-- DROP TEMPORARY TABLE IF EXISTS WcaStats;

CREATE TEMPORARY TABLE WcaStats AS
(
  SELECT eventId, 'average' AS resultType, continentId, COUNT(*) AS numPersons, MAX(continentRank) AS maxRank
  FROM wca.RanksAverage AS r
  JOIN wca.Persons AS p ON p.id = r.personId AND p.subid = 1
  JOIN wca.Countries AS c ON c.id = p.countryId
  GROUP BY eventId, continentId
 )
 UNION ALL
 (
  SELECT eventId, 'single' AS resultType, continentId, COUNT(*) AS numPersons, MAX(continentRank) AS maxRank
  FROM wca.RanksSingle AS r
  JOIN wca.Persons AS p ON p.id = r.personId AND p.subid = 1
  JOIN wca.Countries AS c ON c.id = p.countryId
  GROUP BY eventId, continentId
);

ALTER TABLE WcaStats ADD PRIMARY KEY (eventId, resultType, continentId);

/*
    Determine known seniors
*/

SET @runDate = (SELECT MAX(runDate) FROM ContinentStats);

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

DROP TABLE IF EXISTS MissingContinents;

CREATE TABLE MissingContinents AS
SELECT t.eventId, t.resultType, t.ageCategory, cc.cc AS continent, ws.maxRank, ws.numPersons, numSeniors, knownSeniors, numSeniors - knownSeniors AS missingSeniors
FROM 
(
    SELECT eventId, resultType, ageCategory, continentId, COUNT(*) AS knownSeniors
    FROM KnownSeniors
    JOIN wca.Persons AS p ON p.id = personId
    JOIN wca.Countries AS c ON c.id = p.countryId
    GROUP BY eventId, resultType, ageCategory, continentId
) AS t
JOIN ContinentCodes AS cc ON cc.id = t.continentId
LEFT JOIN ContinentStats AS cs ON cs.eventId = t.eventId AND cs.resultType = t.resultType AND cs.ageCategory = t.ageCategory AND cs.continentId = t.continentId
LEFT JOIN WcaStats AS ws ON ws.eventId = t.eventId AND ws.resultType = t.resultType AND ws.continentId = t.continentId;

ALTER TABLE MissingContinents ADD PRIMARY KEY (eventId, resultType, ageCategory, continent);

/*
    Patch missing counts
*/

-- Count cannot be negative
UPDATE MissingContinents
SET missingSeniors = 0
WHERE missingSeniors < 0;

-- Propagate "none missing" from world to continent
UPDATE MissingContinents AS mc
JOIN MissingWorld AS mw ON mw.eventId = mc.eventId AND mw.resultType = mc.resultType AND mw.ageCategory = mc.ageCategory
SET mc.missingSeniors = 0
WHERE mc.missingSeniors IS NULL
AND mw.missingSeniors = 0;

-- Propagate "none missing" from younger age categories
UPDATE MissingContinents AS mc1
JOIN MissingContinents AS mc2 ON mc2.eventId = mc1.eventId AND mc2.resultType = mc1.resultType AND mc2.ageCategory < mc1.ageCategory AND mc2.continent = mc1.continent
SET mc1.missingSeniors = 0
WHERE mc1.missingSeniors IS NULL
AND mc2.missingSeniors = 0;

-- Handle supressions - only 1 senior in the WCA DB
UPDATE MissingContinents
SET missingSeniors = 0
WHERE missingSeniors IS NULL
AND numPersons >= 40
AND knownSeniors > 0;

-- Finish using an estimate of the number of seniors in the continent
UPDATE MissingContinents AS mc
JOIN MissingWorld AS mw ON mw.eventId = mc.eventId AND mw.resultType = mc.resultType AND mw.ageCategory = mc.ageCategory
SET mc.missingSeniors = CEIL(mc.numPersons / mw.numPersons * mw.numSeniors) - mc.knownSeniors
WHERE mc.missingSeniors IS NULL;

-- Count cannot be negative (patch estimations in last step)
UPDATE MissingContinents
SET missingSeniors = 0
WHERE missingSeniors < 0;

/*
    Extract missing counts
*/

SELECT *
FROM MissingContinents
WHERE missingSeniors IS NOT NULL
ORDER BY eventId, resultType, ageCategory, continent;
