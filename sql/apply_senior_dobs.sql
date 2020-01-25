/* 
    Script:   Apply Senior DOBs
    Created:  2019-07-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply senior DOBs to the persons table for testing purposes
*/

-- Start with default YMD of zero
UPDATE wca.Persons AS p
SET p.year = 0,
    p.month = 0,
    p.day = 0;

-- Update DOB if known (or approximated)
UPDATE wca.Persons AS p
INNER JOIN wca_ipy.Seniors AS s ON s.personId = p.id AND s.dob IS NOT NULL
SET p.year = DATE_FORMAT(s.dob, '%Y'),
    p.month = DATE_FORMAT(s.dob, '%m'),
    p.day = DATE_FORMAT(s.dob, '%d');

-- Check age categories
SELECT FLOOR(TIMESTAMPDIFF(YEAR,
	DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
	DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS age_category, COUNT(DISTINCT p.id)
FROM wca.Persons AS p USE INDEX()
JOIN wca.Results AS r ON r.personId = p.id AND best > 0
JOIN wca.Competitions AS c ON c.id = r.competitionId
WHERE p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
AND p.subid = 1
GROUP BY age_category
ORDER BY age_category;
