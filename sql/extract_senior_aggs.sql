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
*/

DROP TEMPORARY TABLE IF EXISTS senior_bests;
CREATE TEMPORARY TABLE senior_bests AS
SELECT personId, eventId, age_category, MIN(best) AS best_single, MIN(IF(average > 0, average, NULL)) AS best_average
FROM
(
  SELECT r.personId, r.eventId, r.best, r.average, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
      DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
  FROM Persons AS p
  JOIN Results AS r ON r.personId = p.id AND best > 0
  JOIN Competitions AS c ON c.id = r.competitionId
  WHERE p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  AND p.subid = 1
  HAVING age_at_comp >= 40
) AS t
JOIN (SELECT 40 AS age_category UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100) AS a ON age_category <= age_at_comp
GROUP BY personId, eventId, age_category;

/*
   Extract AGGREGATED senior results (averages)
   1) Output counts of seniors rather than WCA IDs
   2) Truncate everything to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId, age_category,
  FLOOR(best_average / 100) AS modified_average,
  COUNT(*) AS num_persons
FROM senior_bests
WHERE best_average > 0
GROUP BY eventId, age_category, modified_average
ORDER BY eventId, age_category, modified_average;

/*
   Extract AGGREGATED senior results (singles)
   1) Output counts of seniors rather than WCA IDs
   2) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
   3) Leave FMC "single" as a move count - i.e. best
   4) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId, age_category,
  (
    CASE WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best_single / 10000000)
      WHEN eventId IN ('333fm') THEN best_single
      ELSE FLOOR(best_single / 100)
    END
  ) AS modified_single,
  COUNT(*) AS num_persons
FROM senior_bests
GROUP BY eventId, age_category, modified_single
ORDER BY eventId, age_category, modified_single;
