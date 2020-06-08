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
              FROM Competitions
              WHERE results_posted_at IS NULL OR results_posted_at > UTC_DATE()

              - Execute for each age category (40, 50, 60 ... 100) and result type (best / average).
              - Supress results where num_seniors = 1 or num_persons < 40 (see below).
              - n.b. cutoff_date = UTC_DATE() minus 10 days

              SELECT eventId, p.countryId, COUNT(DISTINCT personId) AS num_seniors
              FROM Persons AS p
              JOIN Results AS r ON r.personId = p.id
              JOIN Competitions AS c ON c.id = r.competitionId AND end_date < #{cutoff_date}
              WHERE p.year > 0 AND p.year <= YEAR(UTC_DATE()) - 40
              AND #{column_name} > 0
              AND subid = 1
              AND TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'), start_date) >= 40
              GROUP BY eventId, countryId

              - The following query only needs to be run once per result type (best / average)

              SELECT eventId, countryId, COUNT(*) AS num_persons
              FROM #{table_name} AS r
              JOIN Persons AS p ON p.id = r.personId AND p.subid = 1
              GROUP BY eventId, countryId
*/

-- Note: SELECT * FROM (...) is only for the benefit of phpMyAdmin. It is not required by other SQL clients.

SELECT * FROM
(

WITH possible_seniors AS
(
  SELECT p.id, countryId, DATE(CONCAT_WS('-', p.year, p.month, p.day)) AS dob
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

SELECT t1.*, num_persons, ROUND(100 * num_seniors / num_persons, 2) AS pct_senior
FROM
(
  SELECT cutoff_date, eventId, "average" AS result, age_category, countryId, COUNT(DISTINCT personId) AS num_seniors
  FROM
  (
    SELECT cutoff_date, personId, p.countryId, eventId, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
    FROM possible_seniors AS p
    JOIN Results AS r ON r.personId = p.id
    JOIN Competitions AS c ON c.id = r.competitionId
    JOIN competition_cutoff
    WHERE average > 0
    AND end_date < cutoff_date
    HAVING age_at_comp >= 40
  ) AS senior_results
  JOIN age_categories ON age_category <= age_at_comp
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

UNION ALL

SELECT t1.*, num_persons, ROUND(100 * num_seniors / num_persons, 2) AS pct_senior
FROM
(
  SELECT cutoff_date, eventId, "single" AS result, age_category, countryId, COUNT(DISTINCT personId) AS num_seniors
  FROM
  (
    SELECT cutoff_date, personId, p.countryId, eventId, TIMESTAMPDIFF(YEAR, dob, start_date) AS age_at_comp
    FROM possible_seniors AS p
    JOIN Results AS r ON r.personId = p.id
    JOIN Competitions AS c ON c.id = r.competitionId
    JOIN competition_cutoff
    WHERE best > 0
    AND end_date < cutoff_date
    HAVING age_at_comp >= 40
  ) AS senior_results
  JOIN age_categories ON age_category <= age_at_comp
  GROUP BY eventId, age_category, countryId
) AS t1
JOIN
(
  SELECT eventId, countryId, COUNT(*) AS num_persons
  FROM RanksSingle AS r
  JOIN Persons AS p ON p.id = r.personId AND p.subid = 1
  GROUP BY eventId, countryId
) AS t2 ON t2.eventId = t1.eventId AND t2.countryId = t1.countryId
WHERE num_persons >= 40 AND num_seniors > 1

) AS t;
