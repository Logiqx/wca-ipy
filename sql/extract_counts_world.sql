/* 
    Script:   Extract Counts World
    Created:  2020-01-27
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract worldwide counts - total number of seniors per event per age category
*/

/*
    Determine WCA counts - not just seniors
*/

-- DROP TEMPORARY TABLE IF EXISTS WcaStats;
-- DROP TEMPORARY TABLE IF EXISTS wca_stats;

CREATE TEMPORARY TABLE wca_stats AS
(
  SELECT event_id, 'average' AS result_type, COUNT(*) AS num_persons, MAX(world_rank) AS max_rank
  FROM wca.ranks_average AS r
  GROUP BY event_id
 )
 UNION ALL
 (
  SELECT event_id, 'single' AS result_type, COUNT(*) AS num_persons, MAX(world_rank) AS max_rank
  FROM wca.ranks_single AS r
  GROUP BY event_id
);

ALTER TABLE wca_stats ADD PRIMARY KEY (event_id, result_type);

/*
    Determine known seniors
*/

SET @run_date = (SELECT MAX(run_date) FROM senior_stats);

-- DROP TEMPORARY TABLE IF EXISTS KnownSeniors;
-- DROP TEMPORARY TABLE IF EXISTS known_seniors;

CREATE TEMPORARY TABLE known_seniors AS
SELECT DISTINCT event_id, CONVERT(result_type USING utf8) AS result_type, seq AS age_category, person_id
FROM
(
    SELECT r.event_id, 'average' AS result_type, r.person_id,
        TIMESTAMPDIFF(YEAR, dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM seniors AS p
    JOIN wca.results AS r ON r.person_id = p.wca_id AND average > 0
    JOIN wca.competitions AS c ON c.id = r.competition_id AND STR_TO_DATE(CONCAT(c.year + IF(c.end_month < c.month, 1, 0), '-', c.end_month, '-', c.end_day), '%Y-%m-%d') < @run_date
    WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
    AND accuracy_id NOT IN ('x', 'y')
    HAVING age_at_comp >= 40
    UNION ALL
    SELECT r.event_id, 'single' AS result_type, r.person_id,
        TIMESTAMPDIFF(YEAR, dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM seniors AS p
    JOIN wca.results AS r ON r.person_id = p.wca_id AND best > 0
    JOIN wca.competitions AS c ON c.id = r.competition_id AND STR_TO_DATE(CONCAT(c.year + IF(c.end_month < c.month, 1, 0), '-', c.end_month, '-', c.end_day), '%Y-%m-%d') < @run_date
    WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
    AND accuracy_id NOT IN ('x', 'y')
    HAVING age_at_comp >= 40
) AS t
JOIN seq_40_to_100_step_10 ON seq <= age_at_comp;

ALTER TABLE known_seniors ADD PRIMARY KEY (event_id, result_type, age_category, person_id);

/*
    Calculate missing counts
*/

DROP TABLE IF EXISTS MissingWorld;
DROP TABLE IF EXISTS missing_world;

CREATE TABLE missing_world AS
SELECT t1.event_id, t1.result_type, t1.age_category, max_rank, num_persons, num_seniors, known_seniors, num_seniors - known_seniors AS missing_seniors
FROM 
(
    SELECT event_id, result_type, age_category, COUNT(*) AS known_seniors
    FROM known_seniors
    GROUP BY event_id, result_type, age_category
) AS t1
LEFT JOIN
(
    SELECT event_id, result_type, age_category, SUM(group_size) AS num_seniors
    FROM senior_stats
    WHERE run_date = @run_date
    GROUP BY event_id, result_type, age_category
) AS t2 ON t2.event_id = t1.event_id AND t2.result_type = t1.result_type AND t2.age_category = t1.age_category
LEFT JOIN wca_stats AS ws ON ws.event_id = t1.event_id AND ws.result_type = t1.result_type;

ALTER TABLE missing_world ADD PRIMARY KEY (event_id, result_type, age_category);

/*
    Patch missing counts
*/

-- Count cannot be negative
UPDATE missing_world
SET missing_seniors = 0
WHERE missing_seniors < 0;

/*
    Extract missing counts
*/

SELECT event_id, result_type, age_category, missing_seniors
FROM missing_world
WHERE missing_seniors IS NOT NULL
ORDER BY event_id, result_type, age_category;
