/* 
      Script:   Create Senior Details View
      Created:  2019-05-28
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Create View providing useful information about seniors
*/

DROP VIEW IF EXISTS SeniorDetails;

CREATE VIEW SeniorDetails AS
WITH SeniorResults AS
(
    SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId,
		DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') AS compDate, c.year AS compYear,
        IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
            DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
            DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')), NULL) AS age_at_comp
    FROM Results AS r
    JOIN Competitions AS c ON r.competitionId = c.id
    JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
)
SELECT s.personId, personName, countryId, sourceId, ss.type AS SourceType, hidden, accuracyId, sa.type AS accuracyType, s.dob,
    MIN(compDate) AS firstComp, MAX(compDate) AS lastComp, COUNT(DISTINCT compId) as numComps,
    TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), '-01-01'), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(MAX(compYear), '-01-01'), '%Y-%m-%d')) + 1 AS yearsCompeting,
    TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), '-01-01'), '%Y-%m-%d')) AS ageFirstComp,
    MAX(age_at_comp) AS ageLastComp,
    TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
    u.id AS userId, username, usernum, s.comment
FROM SeniorResults r
JOIN Seniors s ON s.personId = r.personId
JOIN SeniorSources ss ON ss.id = s.sourceId
JOIN SeniorAccuracies sa ON sa.id = s.accuracyId
LEFT JOIN wca_dev.users u ON u.wca_id= r.personId
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;
