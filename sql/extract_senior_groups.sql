/*
    Script:   Extract Senior Groups
    Created:  2019-12-02
    Author:   Michael George / 2015GEOR02

    Purpose:  Simple extract to facilitate the production of "Indicative Senior Rankings".
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    Written specifically for MySQL 8.0 as it requires the window function ROW_NUMBER().
              The extracts do not disclose any actual results, only means for groups of seniors.
              A group size of 6 seniors has been chosen because it typically relates to >500 persons.
              A group mean of NULL is returned if the last group contains less than 4 seniors.
              It is NOT practicable to determine which persons have contributed to the group means.
*/

/*
   Extract senior group means (averages)
*/

SELECT eventId, age_category, group_no, COUNT(*) AS group_size, IF(COUNT(*) >= 4, FLOOR(AVG(best)), NULL) AS group_avg
FROM
(
  SELECT personId, eventId, age_category, best, FLOOR((ROW_NUMBER() OVER (PARTITION BY eventId, age_category ORDER BY best) - 1) / 6) AS group_no
  FROM
  (
    SELECT personId, eventId, age_category, MIN(average) AS best
    FROM
    (
      SELECT r.personId, r.eventId, r.average, TIMESTAMPDIFF(YEAR,
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
    GROUP BY personId, eventId, age_category
  ) AS senior_bests
) AS group_bests
GROUP BY eventId, age_category, group_no;

/*
   Extract senior group means (singles)
*/

SELECT eventId, age_category, group_no, COUNT(*) AS group_size, IF(COUNT(*) >= 4, FLOOR(AVG(best)), NULL) AS group_avg
FROM
(
  SELECT personId, eventId, age_category, best, FLOOR((ROW_NUMBER() OVER (PARTITION BY eventId, age_category ORDER BY best) - 1) / 6) AS group_no
  FROM
  (
    SELECT personId, eventId, age_category, MIN(best) AS best
    FROM
    (
      SELECT r.personId, r.eventId, r.best, TIMESTAMPDIFF(YEAR,
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
    GROUP BY personId, eventId, age_category
  ) AS senior_bests
) AS group_bests
GROUP BY eventId, age_category, group_no;
