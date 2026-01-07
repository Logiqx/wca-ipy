/*
    Script:   Extract Senior Groups
    Created:  2019-12-02
    Author:   Michael George / 2015GEOR02

    Purpose:  Simple extract to facilitate the production of "Senior Rankings".
              https://logiqx.github.io/wca-ipy/Senior_Rankings.html

    Notes:    Written specifically for MySQL 8.0 as it requires the window function ROW_NUMBER().
              The extracts do not disclose any actual results, only means for groups of seniors.
              A group size of 6 seniors has been chosen because it typically relates to >500 persons.
              A group mean of NULL is returned if the last group contains less than 4 seniors.
              It is NOT practicable to determine which persons have contributed to the group means.
*/

-- Note: SELECT * FROM (...) is only for the benefit of phpMyAdmin. It is not required by other SQL clients.

SELECT * FROM
(

WITH possible_seniors AS
(
  SELECT wca_id, dob
  FROM persons USE INDEX()
  WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
  AND sub_id = 1
),

competition_cutoff AS
(
  SELECT DATE_ADD(UTC_DATE(), INTERVAL -10 DAY) AS cutoff_date
),

age_categories(age_category) AS
(
  SELECT 40 AS age_category UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100
)

SELECT cutoff_date, event_id, "average" AS result, age_category, group_no,
  COUNT(*) AS group_size, IF(COUNT(*) >= 4, FLOOR(AVG(best)), NULL) AS group_avg
FROM
(
  SELECT cutoff_date, event_id, age_category, best,
         FLOOR((ROW_NUMBER() OVER (PARTITION BY event_id, age_category ORDER BY best) - 1) / 6) AS group_no
  FROM
  (
    SELECT cutoff_date, person_id, event_id, age_category, MIN(average) AS best
    FROM
    (
      SELECT cutoff_date, person_id, event_id, average, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
      FROM possible_seniors AS p
      JOIN results AS r ON r.person_id = p.wca_id
      JOIN competitions AS c ON c.id = r.competition_id
      JOIN competition_cutoff
      WHERE average > 0
      AND end_date < cutoff_date
      HAVING age_at_comp >= 40
    ) AS senior_results
    JOIN age_categories ON age_category <= age_at_comp
    GROUP BY person_id, event_id, age_category
  ) AS senior_bests
) AS group_bests
GROUP BY event_id, age_category, group_no

UNION ALL

SELECT cutoff_date, event_id, "single" AS result, age_category, group_no,
  COUNT(*) AS group_size, IF(COUNT(*) >= 4, FLOOR(AVG(best)), NULL) AS group_avg
FROM
(
  SELECT cutoff_date, event_id, age_category, best,
         FLOOR((ROW_NUMBER() OVER (PARTITION BY event_id, age_category ORDER BY best) - 1) / 6) AS group_no
  FROM
  (
    SELECT cutoff_date, person_id, event_id, age_category, MIN(best) AS best
    FROM
    (
      SELECT cutoff_date, person_id, event_id, best, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
      FROM possible_seniors AS p
      JOIN results AS r ON r.person_id = p.wca_id
      JOIN competitions AS c ON c.id = r.competition_id
      JOIN competition_cutoff
      WHERE best > 0
      AND end_date < cutoff_date
      HAVING age_at_comp >= 40
    ) AS senior_results
    JOIN age_categories ON age_category <= age_at_comp
    GROUP BY person_id, event_id, age_category
  ) AS senior_bests
) AS group_bests
GROUP BY event_id, age_category, group_no

) AS t;
