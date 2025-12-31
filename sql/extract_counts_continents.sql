/* 
    Script:   Extract Counts Continents
    Created:  2020-01-27
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract continent counts - total number of seniors per event per age category
*/

/*
    Determine WCA counts - not just seniors
*/

-- DROP TEMPORARY TABLE IF EXISTS WcaStats;
-- DROP TEMPORARY TABLE IF EXISTS wca_stats;

CREATE TEMPORARY TABLE wca_stats AS
(
  SELECT event_id, 'average' AS result_type, continent_id, COUNT(*) AS num_persons, MAX(continent_rank) AS max_rank
  FROM wca.ranks_average AS r
  JOIN wca.persons AS p ON p.wca_id = r.person_id AND p.sub_id = 1
  JOIN wca.countries AS c ON c.id = p.country_id
  GROUP BY event_id, continent_id
 )
 UNION ALL
 (
  SELECT event_id, 'single' AS result_type, continent_id, COUNT(*) AS num_persons, MAX(continent_rank) AS max_rank
  FROM wca.ranks_single AS r
  JOIN wca.persons AS p ON p.wca_id = r.person_id AND p.sub_id = 1
  JOIN wca.countries AS c ON c.id = p.country_id
  GROUP BY event_id, continent_id
);

ALTER TABLE wca_stats ADD PRIMARY KEY (event_id, result_type, continent_id);

/*
    Determine known seniors
*/

SET @run_date = (SELECT MAX(run_date) FROM continent_stats);

-- DROP TEMPORARY TABLE IF EXISTS KnownSeniors;
-- DROP TEMPORARY TABLE IF EXISTS known_seniors;

CREATE TEMPORARY TABLE known_seniors AS
SELECT DISTINCT event_id, CONVERT(result_type USING utf8) AS result_type, seq AS age_category, person_id
FROM
(
    SELECT r.event_id, 'average' AS result_type, r.person_id,
        TIMESTAMPDIFF(YEAR, dob, c.start_date) AS age_at_comp
    FROM seniors AS p
    JOIN wca.results AS r ON r.person_id = p.wca_id AND average > 0
    JOIN wca.competitions AS c ON c.id = r.competition_id AND c.end_date < @run_date
    WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
    AND accuracy_id NOT IN ('x', 'y')
    HAVING age_at_comp >= 40
    UNION ALL
    SELECT r.event_id, 'single' AS result_type, r.person_id,
        TIMESTAMPDIFF(YEAR, dob, c.start_date) AS age_at_comp
    FROM seniors AS p
    JOIN wca.results AS r ON r.person_id = p.wca_id AND best > 0
    JOIN wca.competitions AS c ON c.id = r.competition_id AND c.end_date < @run_date
    WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
    AND accuracy_id NOT IN ('x', 'y')
    HAVING age_at_comp >= 40
) AS t
JOIN seq_40_to_100_step_10 ON seq <= age_at_comp;

ALTER TABLE known_seniors ADD PRIMARY KEY (event_id, result_type, age_category, person_id);

/*
    Calculate missing counts
*/

DROP TABLE IF EXISTS MissingContinents;
DROP TABLE IF EXISTS missing_continents;

CREATE TABLE missing_continents AS
SELECT t.event_id, t.result_type, t.age_category, cc.cc AS continent, ws.max_rank, ws.num_persons, num_seniors, known_seniors, num_seniors - known_seniors AS missing_seniors
FROM 
(
    SELECT event_id, result_type, age_category, continent_id, COUNT(*) AS known_seniors
    FROM known_seniors AS ks
    JOIN wca.persons AS p ON p.wca_id = ks.person_id
    JOIN wca.countries AS c ON c.id = p.country_id
    GROUP BY event_id, result_type, age_category, continent_id
) AS t
JOIN continent_codes AS cc ON cc.id = t.continent_id
LEFT JOIN continent_stats AS cs ON cs.event_id = t.event_id AND cs.result_type = t.result_type AND cs.age_category = t.age_category AND cs.continent_id = t.continent_id
LEFT JOIN wca_stats AS ws ON ws.event_id = t.event_id AND ws.result_type = t.result_type AND ws.continent_id = t.continent_id;

ALTER TABLE missing_continents ADD PRIMARY KEY (event_id, result_type, age_category, continent);

/*
    Patch missing counts
*/

-- Count cannot be negative
UPDATE missing_continents
SET missing_seniors = 0
WHERE missing_seniors < 0;

-- Propagate "none missing" from world to continent
UPDATE missing_continents AS mc
JOIN missing_world AS mw ON mw.event_id = mc.event_id AND mw.result_type = mc.result_type AND mw.age_category = mc.age_category
SET mc.missing_seniors = 0
WHERE mc.missing_seniors IS NULL
AND mw.missing_seniors = 0;

-- Propagate "none missing" from younger age categories
UPDATE missing_continents AS mc1
JOIN missing_continents AS mc2 ON mc2.event_id = mc1.event_id AND mc2.result_type = mc1.result_type AND mc2.age_category < mc1.age_category AND mc2.continent = mc1.continent
SET mc1.missing_seniors = 0
WHERE mc1.missing_seniors IS NULL
AND mc2.missing_seniors = 0;

-- Handle supressions - only 1 senior in the WCA DB
UPDATE missing_continents
SET missing_seniors = 0
WHERE missing_seniors IS NULL
AND num_persons >= 40
AND known_seniors > 0;

-- Finish using an estimate of the number of seniors in the continent
UPDATE missing_continents AS mc
JOIN missing_world AS mw ON mw.event_id = mc.event_id AND mw.result_type = mc.result_type AND mw.age_category = mc.age_category
SET mc.missing_seniors = CEIL(mc.num_persons / mw.num_persons * mw.num_seniors) - mc.known_seniors
WHERE mc.missing_seniors IS NULL;

-- Count cannot be negative (patch estimations in last step)
UPDATE missing_continents
SET missing_seniors = 0
WHERE missing_seniors < 0;

/*
    Extract missing counts
*/

SELECT event_id, result_type, age_category, continent, missing_seniors
FROM missing_continents
WHERE missing_seniors IS NOT NULL
ORDER BY event_id, result_type, age_category, continent;
