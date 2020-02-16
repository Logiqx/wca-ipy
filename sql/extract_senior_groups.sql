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

    Rails:    The SQL within this comment is more suitable for use within the API controller.

              - Execute for each age category (40, 50, 60 ... 100) and result type (best / average).
              - Calculate averages for each group of 6 records in the result set.
              - If the last group has less than 4 records, return the count but not the average.
              - n.b. cutoff_date = UTC_DATE() minus 12 days

              SELECT eventId, MIN(#{column_name}) AS best
              FROM Persons AS p
              JOIN Results AS r ON r.personId = p.id
              JOIN Competitions AS c ON c.id = r.competitionId AND end_date <= #{cutoff_date}
              WHERE p.year > 0 AND p.year <= YEAR(UTC_DATE()) - #{age_category}
              AND subid = 1
              AND #{column_name} > 0
              AND TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'), start_date) >= #{age_category}
              GROUP BY eventId, personId
              ORDER BY eventId, best
*/

SELECT DATE_ADD(UTC_DATE(), INTERVAL -12 DAY) AS cutoff_date, eventId, "average" AS result, age_category, group_no,
  COUNT(*) AS group_size, IF(COUNT(*) >= 4, FLOOR(AVG(best)), NULL) AS group_avg
FROM
(
  SELECT personId, eventId, age_category, best,
         FLOOR((ROW_NUMBER() OVER (PARTITION BY eventId, age_category ORDER BY best) - 1) / 6) AS group_no
  FROM
  (
    SELECT personId, eventId, age_category, MIN(average) AS best
    FROM
    (
      SELECT r.personId, r.eventId, r.average,
        TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'), start_date) AS age_at_comp
      FROM Persons AS p
      JOIN Results AS r ON r.personId = p.id AND average > 0
      JOIN Competitions AS c ON c.id = r.competitionId AND end_date <= DATE_ADD(UTC_DATE(), INTERVAL -12 DAY)
      WHERE p.year > 0 AND p.year <= YEAR(UTC_DATE()) - 40
      AND p.subid = 1
      HAVING age_at_comp >= 40
    ) AS senior_results
    JOIN
    (
      SELECT 40 AS age_category
      UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100
    ) AS age_categories ON age_category <= age_at_comp
    GROUP BY personId, eventId, age_category
  ) AS senior_bests
) AS group_bests
GROUP BY eventId, age_category, group_no

UNION ALL

SELECT DATE_ADD(UTC_DATE(), INTERVAL -12 DAY) AS cutoff_date, eventId, "single" AS result, age_category, group_no,
  COUNT(*) AS group_size, IF(COUNT(*) >= 4, FLOOR(AVG(best)), NULL) AS group_avg
FROM
(
  SELECT personId, eventId, age_category, best,
         FLOOR((ROW_NUMBER() OVER (PARTITION BY eventId, age_category ORDER BY best) - 1) / 6) AS group_no
  FROM
  (
    SELECT personId, eventId, age_category, MIN(best) AS best
    FROM
    (
      SELECT r.personId, r.eventId, r.best,
        TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'), start_date) AS age_at_comp
      FROM Persons AS p
      JOIN Results AS r ON r.personId = p.id AND best > 0
      JOIN Competitions AS c ON c.id = r.competitionId AND end_date <= DATE_ADD(UTC_DATE(), INTERVAL -12 DAY)
      WHERE p.year > 0 AND p.year <= YEAR(UTC_DATE()) - 40
      AND p.subid = 1
      HAVING age_at_comp >= 40
    ) AS senior_results
    JOIN
    (
      SELECT 40 AS age_category
      UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100
    ) AS age_categories ON age_category <= age_at_comp
    GROUP BY personId, eventId, age_category
  ) AS senior_bests
) AS group_bests
GROUP BY eventId, age_category, group_no;
