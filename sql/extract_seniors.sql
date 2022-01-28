/*
    Script:   Extract Seniors
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract name, country, age category and details for speedsolving.com
*/

UPDATE Seniors AS s
JOIN wca.Persons AS p ON p.id = s.personId AND p.subid = 1
SET s.name = p.name, s.countryId = p.countryId, s.gender = p.gender;

SELECT s.personId, s.name AS personName, c.iso2 AS country, s.username, s.usernum,
		FLOOR(TIMESTAMPDIFF(YEAR, dob, NOW()) / 10) * 10 AS ageCategory,
		s.hidden, IFNULL(s.userId, 0) AS userId, s.deceased
FROM Seniors AS s
INNER JOIN wca.Countries AS c ON c.id = s.countryId
HAVING ageCategory >= 40
ORDER BY personId;
