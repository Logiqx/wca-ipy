/* 
    Script:   Extract Over 40s
    Created:  2019-06-19
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract name, country, age category and details for speedsolving.com
*/

-- Extract list of seniors
SELECT 'known_senior_details', t.personId, personName, c.name AS country, IFNULL(s.username, '?') AS username, usernum, MAX(ageCategory) AS ageCategory, hidden, IFNULL(userId, 0) AS userId
FROM
(
  SELECT r.eventId, r.personId, r.average, s.name AS personName, s.countryId,
    FLOOR(TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
  FROM wca.Results AS r
  INNER JOIN wca.Competitions AS c ON r.competitionId = c.id
  INNER JOIN Seniors AS s ON s.personId = r.personId AND YEAR(dob) <= YEAR(CURDATE()) - 40 AND hidden = 'n'
  HAVING ageCategory >= 40
) AS t
INNER JOIN Seniors AS s ON s.personId = t.personId
INNER JOIN wca.Countries AS c ON c.id = t.countryId
GROUP BY personId
ORDER BY personName, ageCategory DESC;
