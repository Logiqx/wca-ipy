/* 
    Script:   Extract Counts Countries
    Created:  2020-01-27
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract country counts - total number of seniors per event per age category
*/

/*
    Determine WCA counts - not just seniors
*/

-- DROP TEMPORARY TABLE IF EXISTS WcaStats;

CREATE TEMPORARY TABLE WcaStats AS
(
  SELECT eventId, 'average' AS resultType, countryId, COUNT(*) AS numPersons, MAX(countryRank) AS maxRank
  FROM wca.RanksAverage AS r
  JOIN wca.Persons AS p ON p.id = r.personId AND p.subid = 1
  GROUP BY eventId, countryId
 )
 UNION ALL
 (
  SELECT eventId, 'single' AS resultType, countryId, COUNT(*) AS numPersons, MAX(countryRank) AS maxRank
  FROM wca.RanksSingle AS r
  JOIN wca.Persons AS p ON p.id = r.personId AND p.subid = 1
  GROUP BY eventId, countryId
);

ALTER TABLE WcaStats ADD PRIMARY KEY (eventId, resultType, countryId);

/*
    Determine known seniors
*/

SET @runDate = (SELECT MAX(runDate) FROM CountryStats);

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

SELECT t.eventId, t.resultType, t.ageCategory, iso2 AS country, ws.maxRank, ws.numPersons, numSeniors, knownSeniors, numSeniors - knownSeniors AS missingSeniors
FROM
(
	SELECT eventId, resultType, ageCategory, countryId, COUNT(*) AS knownSeniors
    FROM KnownSeniors
    JOIN wca.Persons AS p ON p.id = personId
    GROUP BY eventId, resultType, ageCategory, countryId
) AS t
JOIN wca.Countries AS c ON c.id = t.countryId
LEFT JOIN CountryStats AS cs ON cs.eventId = t.eventId AND cs.resultType = t.resultType AND cs.ageCategory = t.ageCategory AND cs.countryId = t.countryId
LEFT JOIN WcaStats AS ws ON ws.eventId = t.eventId AND ws.resultType = t.resultType AND ws.countryId = t.countryId;
