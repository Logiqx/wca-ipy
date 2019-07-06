/* 
    Script:   Extract Senior Results (Aggregated)
    Created:  2019-07-06
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Private extract to facilitate the production of "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html
            
    Approach: All consolidated results are modified using truncation / reduction of precision:
              1) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
              2) Leave FMC "single" as a move count - i.e. best
              3) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)

    Notes:    The extracts will not disclose any WCA IDs, regardless of whether they are already known
              These extracts will never be shared publicly
*/

DROP TEMPORARY TABLE IF EXISTS senior_prs;
CREATE TEMPORARY TABLE senior_prs AS
SELECT eventId, personId, FLOOR(age_at_comp / 10) * 10 AS age_category,
  MIN(CASE WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best / 10000000) WHEN eventId IN ('333fm') THEN best ELSE FLOOR(best / 100) END) AS modified_single,
  MIN(IF(average > 0, FLOOR(average / 100), NULL)) AS modified_average
FROM
(
  SELECT r.eventId, r.personId, r.best, r.average,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
      DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE best > 0
  HAVING age_at_comp >= 40
) AS senior_results
GROUP BY eventId, personId, age_category;

-- Combine multiple queries for different age categories
SELECT eventId, modified_average, 40 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 40
GROUP BY eventId, modified_average
UNION ALL
SELECT eventId, modified_average, 50 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 50
GROUP BY eventId, modified_average
UNION ALL
SELECT eventId, modified_average, 60 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 60
GROUP BY eventId, modified_average
UNION ALL
SELECT eventId, modified_average, 70 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 70
GROUP BY eventId, modified_average
UNION ALL
SELECT eventId, modified_average, 80 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 80
GROUP BY eventId, modified_average
UNION ALL
SELECT eventId, modified_average, 90 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 90
GROUP BY eventId, modified_average
ORDER BY eventId, modified_average, age_category;

-- Combine multiple queries for different age categories
SELECT eventId, modified_single, 40 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 40
GROUP BY eventId, modified_single
UNION ALL
SELECT eventId, modified_single, 50 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 50
GROUP BY eventId, modified_single
UNION ALL
SELECT eventId, modified_single, 60 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 60
GROUP BY eventId, modified_single
UNION ALL
SELECT eventId, modified_single, 70 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 70
GROUP BY eventId, modified_single
UNION ALL
SELECT eventId, modified_single, 80 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 80
GROUP BY eventId, modified_single
UNION ALL
SELECT eventId, modified_single, 90 AS age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_prs
WHERE age_category >= 90
GROUP BY eventId, modified_single
ORDER BY eventId, modified_single, age_category;
