/* 
      Script:   Create Senior Details View
      Created:  2019-05-28
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Create view providing useful information about seniors
*/

DROP VIEW IF EXISTS SeniorDetails;

CREATE VIEW SeniorDetails AS
SELECT s.personId, s.name, s.countryId, s.gender, s.dob, s.hidden, s.deceased,
    MIN(DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS firstComp,
    MAX(DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS lastComp,
    COUNT(DISTINCT r.competitionId) AS numComps,
    MAX(TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), '-01-01'), '%Y-%m-%d'), DATE_FORMAT(CONCAT(c.year, '-01-01'), '%Y-%m-%d')) + 1) AS yearsCompeting,
    MIN(TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d'))) AS ageFirstComp,
    MAX(TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d'))) AS ageLastComp,
    TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
    s.accuracyId, s.sourceId, s.userStatusId,
    sa.type AS accuracyType, ss.type AS sourceType, us.type AS userStatus,
    s.userId, u.avatar, s.username, s.usernum, s.email, s.facebook, s.youtube, s.comment
FROM Seniors AS s
JOIN SeniorSources ss ON ss.id = s.sourceId
JOIN SeniorAccuracies sa ON sa.id = s.accuracyId
JOIN UserStatuses us ON us.id = s.userStatusId
JOIN wca.Results AS r ON r.personId = s.personId
JOIN wca.Competitions AS c ON c.id = r.competitionId
LEFT JOIN wca_dev.users u ON u.id = s.userId
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;
