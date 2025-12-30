/*
    Script:   Extract Senior Countries
    Created:  2020-01-11
    Author:   Michael George / 2015GEOR02

    Purpose:  Simple extract to facilitate the production of "Senior Rankings".
              https://logiqx.github.io/wca-ipy/Senior_Rankings.html

    Notes:    I'd like to be able to report the total number of seniors by region.
              The WHERE clauses roughly halve the result set, removing any potentially PII.
              The filtered / discarded records can be viewed by tweaking the WHERE clauses
              "num_persons >= 40 AND num_seniors > 1" to "(num_persons < 40 OR num_seniors = 1)"

    Rails:    The SQL within this comment is more suitable for use within the API controller.

              - Firstly, determine cutoff_date using the following SQL.

              SELECT MIN(end_date)
              FROM competitions
              WHERE results_posted_at IS NULL OR results_posted_at > UTC_DATE()

              - Execute for each age category (40, 50, 60 ... 100) and result type (best / average).
              - Supress results where num_seniors = 1 or num_persons < 40 (see below).
              - n.b. cutoff_date = UTC_DATE() minus 10 days

              SELECT event_id, p.country_id, COUNT(DISTINCT person_id) AS num_seniors
              FROM persons AS p
              JOIN results AS r ON r.person_id = p.wca_id
              JOIN competitions AS c ON c.id = r.competition_id AND end_date < #{cutoff_date}
              WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
              AND #{column_name} > 0
              AND sub_id = 1
              AND TIMESTAMPDIFF(YEAR, dob, start_date) >= 40
              GROUP BY event_id, country_id

              - The following query only needs to be run once per result type (best / average)

              SELECT event_id, country_id, COUNT(*) AS num_persons
              FROM #{table_name} AS r
              JOIN persons AS p ON p.wca_id = r.person_id AND p.sub_id = 1
              GROUP BY event_id, country_id
*/

-- Note: SELECT * FROM (...) is only for the benefit of phpMyAdmin. It is not required by other SQL clients.

SELECT * FROM
(

WITH possible_seniors AS
(
  SELECT wca_id, country_id, dob
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

SELECT t1.*, num_persons, ROUND(100 * num_seniors / num_persons, 2) AS pct_senior
FROM
(
  SELECT cutoff_date, event_id, "average" AS result, age_category, country_id, COUNT(DISTINCT person_id) AS num_seniors
  FROM
  (
    SELECT cutoff_date, person_id, p.country_id, event_id, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
    FROM possible_seniors AS p
    JOIN results AS r ON r.person_id = p.wca_id
    JOIN competitions AS c ON c.id = r.competition_id
    JOIN competition_cutoff
    WHERE average > 0
    AND end_date < cutoff_date
    HAVING age_at_comp >= 40
  ) AS senior_results
  JOIN age_categories ON age_category <= age_at_comp
  GROUP BY event_id, age_category, country_id
) AS t1
JOIN
(
  SELECT event_id, country_id, COUNT(*) AS num_persons
  FROM ranks_average AS r
  JOIN persons AS p ON p.wca_id = r.person_id AND p.sub_id = 1
  GROUP BY event_id, country_id
) AS t2 ON t2.event_id = t1.event_id AND t2.country_id = t1.country_id
WHERE num_persons >= 40 AND num_seniors > 1

UNION ALL

SELECT t1.*, num_persons, ROUND(100 * num_seniors / num_persons, 2) AS pct_senior
FROM
(
  SELECT cutoff_date, event_id, "single" AS result, age_category, country_id, COUNT(DISTINCT person_id) AS num_seniors
  FROM
  (
    SELECT cutoff_date, person_id, p.country_id, event_id, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
    FROM possible_seniors AS p
    JOIN results AS r ON r.person_id = p.wca_id
    JOIN competitions AS c ON c.id = r.competition_id
    JOIN competition_cutoff
    WHERE best > 0
    AND end_date < cutoff_date
    HAVING age_at_comp >= 40
  ) AS senior_results
  JOIN age_categories ON age_category <= age_at_comp
  GROUP BY event_id, age_category, country_id
) AS t1
JOIN
(
  SELECT event_id, country_id, COUNT(*) AS num_persons
  FROM ranks_single AS r
  JOIN persons AS p ON p.wca_id = r.person_id AND p.sub_id = 1
  GROUP BY event_id, country_id
) AS t2 ON t2.event_id = t1.event_id AND t2.country_id = t1.country_id
WHERE num_persons >= 40 AND num_seniors > 1

) AS t;
