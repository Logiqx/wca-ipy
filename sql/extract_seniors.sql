/*
    Script:   Extract Seniors
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract name, country, age category and details for speedsolving.com
*/

UPDATE seniors AS s
JOIN wca.persons AS p ON p.wca_id = s.wca_id AND p.sub_id = 1
SET s.name = p.name, s.country_id = p.country_id, s.gender = p.gender;

SELECT s.wca_id, s.name AS person_name, c.iso2 AS country, s.ss_user_name, s.ss_user_num,
		FLOOR(TIMESTAMPDIFF(YEAR, dob, NOW()) / 10) * 10 AS age_category,
		s.hidden, IFNULL(s.user_id, 0) AS user_id, s.deceased
FROM seniors AS s
INNER JOIN wca.countries AS c ON c.id = s.country_id
HAVING age_category >= 40
ORDER BY wca_id;
