/* 
    Script:   Apply Senior DOBs
    Created:  2019-07-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply senior DOBs to the persons table for testing purposes
*/

USE wca;

SET SQL_SAFE_UPDATES = 0;

-- Start with default YMD of zero
UPDATE persons AS p
SET p.year = 0,
    p.month = 0,
    p.day = 0;

-- Update DOB if known (or approximated)
UPDATE persons AS p
INNER JOIN wca_ipy.seniors AS s ON s.wca_id = p.wca_id AND s.dob IS NOT NULL
SET p.year = DATE_FORMAT(s.dob, '%Y'),
    p.month = DATE_FORMAT(s.dob, '%m'),
    p.day = DATE_FORMAT(s.dob, '%d');

-- Check age categories
SELECT FLOOR(TIMESTAMPDIFF(YEAR,
	STR_TO_DATE(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
	STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS age_category, COUNT(DISTINCT p.wca_id)
FROM persons AS p
JOIN results AS r ON r.person_id = p.wca_id AND best > 0
JOIN competitions AS c ON c.id = r.competition_id
WHERE p.year > 0 AND p.year <= YEAR(UTC_DATE()) - 40
AND p.sub_id = 1
GROUP BY age_category
ORDER BY age_category;
