/* 
      Script:   Create Senior Details View
      Created:  2019-05-28
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Create View providing useful information about seniors
*/

DROP VIEW IF EXISTS SeniorDetails;

CREATE VIEW SeniorDetails AS
SELECT r.personId, s.name, s.countryId, s.gender, s.sourceId, ss.type AS sourceType, s.hidden, s.accuracyId, sa.type AS accuracyType, s.dob,
    MIN(DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS firstComp,
    MAX(DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS lastComp,
    COUNT(DISTINCT r.competitionId) AS numComps,
    MAX(TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), '-01-01'), '%Y-%m-%d'), DATE_FORMAT(CONCAT(c.year, '-01-01'), '%Y-%m-%d')) + 1) AS yearsCompeting,
    MIN(TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d'))) AS ageFirstComp,
    MAX(TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d'))) AS ageLastComp,
    TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
    u.id AS userId, avatar, username, usernum, t.status, s.comment
FROM Seniors AS s
JOIN Results AS r ON r.personId = s.personId
JOIN Competitions AS c ON c.id = r.competitionId
JOIN SeniorSources ss ON ss.id = s.sourceId
JOIN SeniorAccuracies sa ON sa.id = s.accuracyId
LEFT JOIN SeniorStatuses t ON t.personId = s.personId
LEFT JOIN wca_dev.users u ON u.wca_id = s.personId
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;
