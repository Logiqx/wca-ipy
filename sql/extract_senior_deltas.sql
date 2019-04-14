/* 
    Script:   Aggregated Deltas for Over 40's Rankings
    Created:  2019-04-06
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Provide a comprehensive view of the Over-40's performances in competition.
            
    Approach: The extract will not disclose any WCA IDs, regardless of whether they are already known.
              All consolidated results are modified using truncation / reduction of precision.
*/

/* 
   Extract delta for AGGREGATED senior results (averages)
   
   1) Output counts of seniors rather than WCA IDs
   2) Truncate everything to the nearest second - i.e. FLOOR(best / 100)
*/

-- Baseline aggregation uses public database export from 2019-01-30

DROP TEMPORARY TABLE IF EXISTS tmpAggBase;
CREATE TEMPORARY TABLE tmpAggBase AS
SELECT eventId, FLOOR(best_average / 100) AS modified_average, COUNT(*) AS num_persons
FROM
(
  SELECT eventId, personId, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM wca_20190130.Results AS r
    INNER JOIN wca_20190130.Competitions AS c ON r.competitionId = c.id
    INNER JOIN wca.Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, modified_average
ORDER BY eventId, modified_average;

-- New aggregation uses latest public database export

DROP TEMPORARY TABLE IF EXISTS tmpAggNew;
CREATE TEMPORARY TABLE tmpAggNew AS
SELECT eventId, FLOOR(best_average / 100) AS modified_average, COUNT(*) AS num_persons
FROM
(
  SELECT eventId, personId, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM wca.Results AS r
    INNER JOIN wca.Competitions AS c ON r.competitionId = c.id
    INNER JOIN wca.Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, modified_average
ORDER BY eventId, modified_average;

-- Simulate full outer join using a 3rd table
-- Step 1: Create table for new records

DROP TEMPORARY TABLE IF EXISTS tmpAggCmp;
CREATE TEMPORARY TABLE tmpAggCmp AS
SELECT n.eventId, n.modified_average, 0 AS base_num_persons, n.num_persons AS new_num_persons
FROM tmpAggBase b
RIGHT JOIN tmpAggNew n ON b.eventId = n.eventId AND b.modified_average = n.modified_average
WHERE b.eventId IS NULL;

-- Simulate full outer join using a 3rd table
-- Step 2: Select differences and new records

SELECT *
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/known_senior_averages_delta.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT b.eventId, b.modified_average, IFNULL(n.num_persons, 0) - b.num_persons AS diff_of_averages
  FROM tmpAggBase b
  LEFT JOIN tmpAggNew n ON b.eventId = n.eventId AND b.modified_average = n.modified_average
  HAVING diff_of_averages != 0
  UNION ALL
  SELECT c.eventId, c.modified_average, c.new_num_persons AS diff_of_averages
  FROM tmpAggCmp c
  ORDER BY eventId, modified_average
) AS tmp_deltas;
