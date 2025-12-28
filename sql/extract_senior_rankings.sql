/* 
    Script:   Extract Senior Results
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract senior rankings - combining actual results and 'fake' results
*/

/*
    Start by determining the rankings for all events / age categories
*/

-- DROP TEMPORARY TABLE IF EXISTS SeniorRanks;
-- DROP TEMPORARY TABLE IF EXISTS senior_ranks;

CREATE TEMPORARY TABLE senior_ranks AS
SELECT event_id, result_type, age_category, person_id, best, RANK() OVER (PARTITION BY event_id, result_type, age_category ORDER BY best) AS rank_no
FROM
(
    -- Additional brackets added for clarity
    (
        -- Actual results
        SELECT event_id, result_type, seq AS age_category, person_id, MIN(best) AS best
        FROM
        (
            SELECT r.event_id, 'average' AS result_type, r.person_id, r.average AS best,
                TIMESTAMPDIFF(YEAR, dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
            FROM seniors AS p
            JOIN wca.results AS r ON r.person_id = p.wca_id AND average > 0
            JOIN wca.competitions AS c ON c.id = r.competition_id
            WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
            HAVING age_at_comp >= 40
            UNION ALL
            SELECT r.event_id, 'single' AS result_type, r.person_id, r.best,
                TIMESTAMPDIFF(YEAR, dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
            FROM seniors AS p
            JOIN wca.results AS r ON r.person_id = p.wca_id AND best > 0
            JOIN wca.competitions AS c ON c.id = r.competition_id
            WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
            HAVING age_at_comp >= 40
        ) AS t
        JOIN seq_40_to_100_step_10 ON seq <= age_at_comp
        GROUP BY event_id, result_type, age_category, person_id
    )
    UNION ALL
    (
        -- Fake results
        SELECT sv.event_id, sv.result_type, sv.age_category, fake_id AS person_id, fake_result AS best
        FROM senior_fakes AS sf
        JOIN senior_views AS sv ON sv.view_id = sf.view_id
    )
) AS t;

/*
    Finish up by appending the competition id and sorting the rankings
*/

SELECT event_id, result_type, age_category, person_id, best, rank_no, competition_id, age_at_comp
FROM
(
    -- Additional brackets added for clarity
    (
        -- Actual results
        SELECT event_id, result_type, age_category, person_id, best, rank_no, person_name, competition_id, age_at_comp
        FROM
        (
            SELECT sr.*, s.name AS person_name, c.id AS competition_id,
                FLOOR(TIMESTAMPDIFF(YEAR, dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS age_at_comp,
                ROW_NUMBER() OVER (PARTITION BY sr.event_id, sr.result_type, sr.age_category, sr.person_id ORDER BY c.year, c.month, c.day) AS row_no
            FROM seniors AS s
            JOIN senior_ranks AS sr ON sr.person_id = s.wca_id
            JOIN wca.results AS r ON r.event_id = sr.event_id AND r.person_id = sr.person_id AND r.average = sr.best
            JOIN wca.competitions AS c ON c.id = r.competition_id
            WHERE result_type = 'average'
            HAVING age_at_comp >= sr.age_category
            UNION ALL
            SELECT sr.*, s.name AS person_name, c.id AS competition_id,
                FLOOR(TIMESTAMPDIFF(YEAR, dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS age_at_comp,
                ROW_NUMBER() OVER (PARTITION BY sr.event_id, sr.result_type, sr.age_category, sr.person_id ORDER BY c.year, c.month, c.day) AS row_no
            FROM seniors AS s
            JOIN senior_ranks AS sr ON sr.person_id = s.wca_id
            JOIN wca.results AS r ON r.event_id = sr.event_id AND r.person_id = sr.person_id AND r.best = sr.best
            JOIN wca.competitions AS c ON c.id = r.competition_id
            WHERE result_type = 'single'
            HAVING age_at_comp >= sr.age_category
        ) AS t
        WHERE row_no = 1
    )
    UNION ALL
    (
        -- Fake results
        SELECT sr.*, person_id AS person_name, 'WC2003' AS competition_id, sr.age_category AS age_at_comp
        FROM senior_ranks AS sr
        WHERE person_id LIKE 'FAKE%'
    )
) AS t
ORDER BY event_id, result_type DESC, age_category, best, person_name;
