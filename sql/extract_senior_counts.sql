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
  SELECT p.wca_id, DATE(CONCAT_WS('-', p.year, p.month, p.day)) AS dob
  FROM persons AS p USE INDEX()
  WHERE p.year > 0 AND p.year <= YEAR(UTC_DATE()) - 40
  AND p.sub_id = 1
),

competition_cutoff AS
(
  SELECT DATE_ADD(UTC_DATE(), INTERVAL -10 DAY) AS cutoff_date
),

age_categories(age_category) AS
(
  SELECT 40 AS age_category UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100
)

SELECT cutoff_date, event_id, "average" AS result, age_category, COUNT(DISTINCT person_id) AS num_seniors
FROM
(
  SELECT cutoff_date, person_id, event_id, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
  FROM possible_seniors AS p
  JOIN results AS r ON r.person_id = p.wca_id
  JOIN competitions AS c ON c.id = r.competition_id
  JOIN competition_cutoff
  WHERE average > 0
  AND end_date < cutoff_date
  HAVING age_at_comp >= 40
) AS senior_results
JOIN age_categories ON age_category <= age_at_comp
GROUP BY event_id, age_category

UNION ALL

SELECT cutoff_date, event_id, "single" AS result, age_category, COUNT(DISTINCT person_id) AS num_seniors
FROM
(
  SELECT cutoff_date, person_id, event_id, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
  FROM possible_seniors AS p
  JOIN results AS r ON r.person_id = p.wca_id
  JOIN competitions AS c ON c.id = r.competition_id
  JOIN competition_cutoff
  WHERE best > 0
  AND end_date < cutoff_date
  HAVING age_at_comp >= 40
) AS senior_results
JOIN age_categories ON age_category <= age_at_comp
GROUP BY event_id, age_category

) AS t;
