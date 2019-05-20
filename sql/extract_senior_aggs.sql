/* 
    Script:   Aggregated Over 40's Rankings
    Created:  2019-02-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Provide a comprehensive view of the Over-40's performances in competition.
            
    Approach: The extract will not disclose any WCA IDs, regardless of whether they are already known.
              All consolidated results are modified using truncation / reduction of precision.
*/

/* 
   Extract AGGREGATED senior results (averages)
   
   1) Output counts of seniors rather than WCA IDs
   2) Truncate everything to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId, FLOOR(best_average / 100) AS modified_average, COUNT(*) AS num_persons
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/public/extract/known_senior_averages_agg.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT eventId, personId, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, modified_average
ORDER BY eventId, modified_average;

/* 
   Extract AGGREGATED senior results (singles)
   
   1) Output counts of seniors rather than WCA IDs
   2) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
   3) Leave FMC "single" as a move count - i.e. best
   4) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId,
  (
    CASE
      WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best_single / 10000000)
      WHEN eventId IN ('333fm') THEN best_single
      ELSE FLOOR(best_single / 100)
    END
  ) AS modified_single, COUNT(*) AS num_persons
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/public/extract/known_senior_singles_agg.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(   
  SELECT eventId, personId, MIN(best) AS best_single
  FROM
  (
    SELECT r.eventId, r.personId, r.best,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE best > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, modified_single
ORDER BY eventId, modified_single;
