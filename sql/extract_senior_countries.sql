/*
    Script:   Extract Senior Countries
    Created:  2020-01-11
    Author:   Michael George / 2015GEOR02

    Purpose:  Simple extract to facilitate the production of "Senior Rankings".
              https://logiqx.github.io/wca-ipy/Senior_Rankings.html

    Notes:    I'd like to be able to report the total number of seniors by region.
*/

SELECT CURDATE() AS run_date, eventId, "average" AS result, age_category, countryId, COUNT(DISTINCT personId) AS num_seniors
FROM
(
  SELECT p.id AS personId, p.countryId, r.eventId, r.average, TIMESTAMPDIFF(YEAR,
	DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
	DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
  FROM Persons AS p USE INDEX()
  JOIN Results AS r ON r.personId = p.id AND average > 0
  JOIN Competitions AS c ON c.id = r.competitionId
  WHERE p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  AND p.subid = 1
  HAVING age_at_comp >= 40
) AS senior_results
JOIN
(
  SELECT 40 AS age_category
  UNION ALL SELECT 50
  UNION ALL SELECT 60
  UNION ALL SELECT 70
  UNION ALL SELECT 80
  UNION ALL SELECT 90
  UNION ALL SELECT 100
) AS age_categories ON age_category <= age_at_comp
GROUP BY countryId, eventId, age_category

UNION ALL

SELECT CURDATE() AS run_date, eventId, "single" AS result, age_category, countryId, COUNT(DISTINCT personId) AS num_seniors
FROM
(
  SELECT p.id AS personId, p.countryId, r.eventId, r.average, TIMESTAMPDIFF(YEAR,
	DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
	DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
  FROM Persons AS p USE INDEX()
  JOIN Results AS r ON r.personId = p.id AND best > 0
  JOIN Competitions AS c ON c.id = r.competitionId
  WHERE p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  AND p.subid = 1
  HAVING age_at_comp >= 40
) AS senior_results
JOIN
(
  SELECT 40 AS age_category
  UNION ALL SELECT 50
  UNION ALL SELECT 60
  UNION ALL SELECT 70
  UNION ALL SELECT 80
  UNION ALL SELECT 90
  UNION ALL SELECT 100
) AS age_categories ON age_category <= age_at_comp
GROUP BY countryId, eventId, age_category;
