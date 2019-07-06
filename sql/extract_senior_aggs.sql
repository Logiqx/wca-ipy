/* 
    Script:   Extract Senior Results (Aggregated)
    Created:  2019-07-06
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Private extract to facilitate the production of "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html
            
    Notes:    The extracts will not disclose any WCA IDs, regardless of whether they are already known
              All consolidated results are modified using truncation / reduction of precision
              These extracts will never be shared publicly
*/

/*
   Create temporary table(s) containing "senior bests" - one record per person, per event, per age category
   This starts with the query from extract_senior_results.sql
*/

-- First temporary table only contains actual results - "age category" based on "age at competition"
DROP TEMPORARY TABLE IF EXISTS senior_bests_1;
CREATE TEMPORARY TABLE senior_bests_1 AS
SELECT eventId, personId, FLOOR(age_at_comp / 10) * 10 AS age_category,
  MIN(best) AS best_single, MIN(IF(average > 0, average, NULL)) AS best_average
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

-- Second temporary table also contains backdated results - "over 50" also counts as "over 40", etc
DROP TEMPORARY TABLE IF EXISTS senior_bests_2;
CREATE TEMPORARY TABLE senior_bests_2 AS
SELECT eventId, personId, a.age_category, MIN(best_single) AS best_single, MIN(best_average) AS best_average
FROM senior_bests_1 AS s
JOIN (SELECT DISTINCT age_category FROM senior_bests_1) AS a ON a.age_category <= s.age_category
GROUP BY eventId, personId, age_category;

/*
   Extract AGGREGATED senior results (averages)
   1) Output counts of seniors rather than WCA IDs
   2) Truncate everything to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId,
  FLOOR(best_average / 100) AS modified_average,
  age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_bests_2
WHERE best_average > 0
GROUP BY eventId, modified_average, age_category
ORDER BY eventId, modified_average, age_category;

/*
   Extract AGGREGATED senior results (singles)
   1) Output counts of seniors rather than WCA IDs
   2) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
   3) Leave FMC "single" as a move count - i.e. best
   4) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId,
  CASE WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best_single / 10000000)
    WHEN eventId IN ('333fm') THEN best_single
    ELSE FLOOR(best_single / 100)
  END AS modified_single,
  age_category, COUNT(DISTINCT personId) AS num_persons
FROM senior_bests_2
GROUP BY eventId, modified_single, age_category
ORDER BY eventId, modified_single, age_category;
