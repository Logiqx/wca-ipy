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
    Extract counts
*/

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
