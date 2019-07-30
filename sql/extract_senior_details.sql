/* 
    Script:   Extract Over 40s
    Created:  2019-06-19
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract name, country, age category and details for speedsolving.com
*/

-- Extract list of seniors
SELECT t.personId, personName, c.name AS country, IFNULL(s.username, '?') AS username, usernum, MAX(ageCategory) AS ageCategory, hidden, IFNULL(userId, 0) AS userId
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/known_senior_details.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.average, s.name AS PersonName, s.countryId,
    FLOOR(TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN wca_ipy.Seniors AS s ON s.personId = r.personId AND YEAR(dob) <= YEAR(CURDATE()) - 40 AND hidden = 'N'
  HAVING ageCategory >= 40
) AS t
INNER JOIN wca_ipy.Seniors AS s ON s.personId = t.personId
INNER JOIN Countries AS c ON c.id = t.countryId
GROUP BY personId
ORDER BY personName, ageCategory DESC;
