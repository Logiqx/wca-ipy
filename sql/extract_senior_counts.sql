/*
    Script:   Extract Senior Counts
    Created:  2020-02-20
    Author:   Michael George / 2015GEOR02

    Purpose:  Simple extract to facilitate the production of "Senior Rankings".
              https://logiqx.github.io/wca-ipy/

    Notes:    Simple counts for each event / age category
*/

-- Note: SELECT * FROM (...) is only for the benefit of phpMyAdmin. It is not required by other SQL clients.

SELECT * FROM
(

WITH possible_seniors AS
(
  SELECT p.id, DATE(CONCAT_WS('-', p.year, p.month, p.day)) AS dob
  FROM Persons AS p USE INDEX()
  WHERE p.year > 0 AND p.year <= YEAR(UTC_DATE()) - 40
  AND p.subid = 1
),

competition_cutoff AS
(
  SELECT DATE_ADD(UTC_DATE(), INTERVAL -10 DAY) AS cutoff_date
),

age_categories(age_category) AS
(
  SELECT 40 AS age_category UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100
)

SELECT cutoff_date, eventId, "average" AS result, age_category, COUNT(DISTINCT personId) AS num_seniors
FROM
(
  SELECT cutoff_date, personId, eventId, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
  FROM possible_seniors AS p
  JOIN Results AS r ON r.personId = p.id
  JOIN Competitions AS c ON c.id = r.competitionId
  JOIN competition_cutoff
  WHERE average > 0
  AND end_date < cutoff_date
  HAVING age_at_comp >= 40
) AS senior_results
JOIN age_categories ON age_category <= age_at_comp
GROUP BY eventId, age_category

UNION ALL

SELECT cutoff_date, eventId, "single" AS result, age_category, COUNT(DISTINCT personId) AS num_seniors
FROM
(
  SELECT cutoff_date, personId, eventId, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
  FROM possible_seniors AS p
  JOIN Results AS r ON r.personId = p.id
  JOIN Competitions AS c ON c.id = r.competitionId
  JOIN competition_cutoff
  WHERE best > 0
  AND end_date < cutoff_date
  HAVING age_at_comp >= 40
) AS senior_results
JOIN age_categories ON age_category <= age_at_comp
GROUP BY eventId, age_category

) AS t;
