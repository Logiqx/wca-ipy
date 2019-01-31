/* 
    Script:   Aggregated Over 40's Rankings
    Date:     2019-01-31
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Unofficial rankings for the Over 40's exist on GitHub but they are known to be incomplete - https://github.com/Logiqx/wca-ipy.
              This extract will be used to provide participants of the unofficial rankings with a more comprehensive view of how they rank against their peers.
              The data will help us to ascertain how many people are missing from the unofficial rankings and provide general stats for the Over 40's in comp.
            
    Approach: The extract will not disclose any WCA IDs, regardless of whether they already appear in the unoffical rankings on GitHub.
              All consolidated results are modified using truncation / reduction of precision. This is typically to the nearest second.
*/


/* 
   Simple counts of oldies present in "RanksAverage" and "RanksSingle"
*/

SELECT eventId, COUNT(*) AS num_persons,
  SUM(TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"), CURDATE()) >= 40) AS num_oldies
FROM RanksAverage r
INNER JOIN Persons p ON p.id = r.personId
GROUP BY eventId;

SELECT eventId, COUNT(*) AS num_persons,
  SUM(TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"), CURDATE()) >= 40) AS num_oldies
FROM RanksSingle r
INNER JOIN Persons p ON p.id = r.personId
GROUP BY eventId;

/* 
   Extract AGGREGATED oldies from "RanksAverage"
   
   1) Output counts of oldies rather than WCA IDs
   2) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
   3) Truncate FMC "average" to the nearest move - i.e. FLOOR(best / 100)
   4) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId,
  (
    CASE
      WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best_average / 10000000)
      WHEN eventId IN ('333fm') THEN FLOOR(best_average / 100)
      ELSE FLOOR(best_average / 100)
    END
  ) AS modified_average, COUNT(*) AS num_persons
FROM
(
  SELECT eventId, personId, MIN(best) AS best_single, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.best, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) tmp_results
  GROUP BY eventId, personId
) tmp_persons
GROUP BY eventId, modified_average;

/* 
   Extract AGGREGATED oldies from "RanksSingle"
   
   1) Output counts of oldies rather than WCA IDs
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
FROM
(   
  SELECT eventId, personId, MIN(best) AS best_single, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.best, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE best > 0
    HAVING age_at_comp >= 40
  ) tmp_results
  GROUP BY eventId, personId
) tmp_persons
GROUP BY eventId, modified_single;