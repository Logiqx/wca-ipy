/*
    Script:   Extract Seniors
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract name, country, age category and details for speedsolving.com
*/

SELECT t.personId, s.name AS personName, c.iso2 AS country, s.username, s.usernum, MAX(t.ageCategory) AS ageCategory, s.hidden, IFNULL(s.userId, 0) AS userId
FROM
(
    SELECT s.personId, FLOOR(TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
    FROM Seniors AS s
    JOIN wca.Results AS r ON r.personId = s.personId
    JOIN wca.Competitions AS c ON c.id = r.competitionId
    HAVING ageCategory >= 40
) AS t
INNER JOIN Seniors AS s ON s.personId = t.personId
INNER JOIN wca.Countries AS c ON c.id = s.countryId
GROUP BY personId
ORDER BY personId;
