/*
    Script:   Extract Senior Countries
    Created:  2020-01-11
    Author:   Michael George / 2015GEOR02

    Purpose:  Simple extract to facilitate the production of "Senior Rankings".
              https://logiqx.github.io/wca-ipy/Senior_Rankings.html

    Notes:    I'd like to be able to report the total number of seniors by region.
              The WHERE clauses roughly halve the result set, removing any potentially PII.
              The dropped records can be viewed using the commented out WHERE clauses.
*/

SELECT t1.*, num_persons, ROUND(100 * num_seniors / num_persons, 2) AS pct_senior
FROM
(
  SELECT CURDATE() AS run_date, eventId, "average" AS result, age_category, countryId, COUNT(DISTINCT personId) AS num_seniors
  FROM
  (
    SELECT personId, p.countryId, eventId, TIMESTAMPDIFF(YEAR,
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
    UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100
  ) AS age_categories ON age_category <= age_at_comp
  GROUP BY eventId, age_category, countryId
) AS t1
JOIN
(
  SELECT eventId, countryId, COUNT(*) AS num_persons
  FROM RanksAverage AS r
  JOIN Persons AS p ON p.id = r.personId AND p.subid = 1
  GROUP BY eventId, countryId
) AS t2 ON t2.eventId = t1.eventId AND t2.countryId = t1.countryId
WHERE num_persons >= 40 AND num_seniors > 1
-- WHERE (num_persons < 40 OR num_seniors = 1)

UNION ALL

SELECT t1.*, num_persons, ROUND(100 * num_seniors / num_persons, 2) AS pct_senior
FROM
(
  SELECT CURDATE() AS run_date, eventId, "single" AS result, age_category, countryId, COUNT(DISTINCT personId) AS num_seniors
  FROM
  (
    SELECT personId, p.countryId, eventId, TIMESTAMPDIFF(YEAR,
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
    UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100
  ) AS age_categories ON age_category <= age_at_comp
  GROUP BY eventId, age_category, countryId
) AS t1
JOIN
(
  SELECT eventId, countryId, COUNT(*) AS num_persons
  FROM RanksSingle AS r
  JOIN Persons AS p ON p.id = r.personId AND p.subid = 1
  GROUP BY eventId, countryId
) AS t2 ON t2.eventId = t1.eventId AND t2.countryId = t1.countryId
WHERE num_persons >= 40 AND num_seniors > 1;
-- WHERE (num_persons < 40 OR num_seniors = 1);
