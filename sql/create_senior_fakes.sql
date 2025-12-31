/*
    Script:   Create Senior Fakes
    Created:  2019-12-22
    Author:   Michael George / 2015GEOR02

    Purpose:  Create artificial / fake results to pad senior rankings
*/

/*
    Create senior_views
*/

DROP TABLE IF EXISTS SeniorViews;
DROP TABLE IF EXISTS senior_views;

CREATE TABLE senior_views
AS
SELECT ROW_NUMBER() OVER (ORDER BY run_date, event_id, result_type, age_category) AS view_id,
    t1.*, t2.*, t3.*, t4.*
FROM
(
    SELECT DISTINCT run_date
    FROM senior_stats
) AS t1
JOIN
(
    SELECT DISTINCT id AS event_id
    FROM wca.events
) AS t2
JOIN
(
    SELECT DISTINCT result_type
    FROM senior_stats
) AS t3
JOIN
(
    SELECT DISTINCT age_category
    FROM senior_stats
) AS t4
ORDER BY run_date, event_id, result_type, age_category;

ALTER TABLE senior_views ADD PRIMARY KEY (view_id);
ALTER TABLE senior_views ADD UNIQUE KEY senior_views_composite_key (run_date, event_id, result_type, age_category);

/*
    Create improved senior stats table, including totals and awareness of neighbouring groups
*/

DROP TABLE IF EXISTS SeniorStatsExtra;
DROP TABLE IF EXISTS senior_stats_extra;

CREATE TABLE senior_stats_extra AS
SELECT sv.view_id, group_no, group_size,
    SUM(group_size) OVER (PARTITION BY view_id ORDER BY group_no) AS tot_seniors,
    LAG(group_result) OVER (PARTITION BY view_id ORDER BY group_no) AS prev_result,
    group_result,
    LEAD(group_result) OVER (PARTITION BY view_id ORDER BY group_no) AS next_result
FROM senior_stats AS ss
JOIN senior_views AS sv ON sv.run_date = ss.run_date AND sv.event_id = ss.event_id AND sv.result_type = ss.result_type AND sv.age_category = ss.age_category
JOIN (SELECT MAX(run_date) AS run_date FROM senior_views) AS t ON t.run_date = ss.run_date;

ALTER TABLE senior_stats_extra ADD PRIMARY KEY (view_id, group_no);

/*
    Create table containing senior bests (averages and singles)
*/

DROP TABLE IF EXISTS SeniorBests;
DROP TABLE IF EXISTS senior_bests;

CREATE TABLE senior_bests AS
SELECT view_id, ROW_NUMBER() OVER (PARTITION BY view_id ORDER BY best, person_id) - 1 AS row_no, person_id, best
FROM
(
    SELECT run_date, event_id, result_type, seq AS age_category, person_id, MIN(best) AS best
    FROM
    (
        SELECT s.run_date, r.event_id, 'average' AS result_type, r.person_id, r.average AS best,
            TIMESTAMPDIFF(YEAR, dob, c.start_date) AS age_at_comp
        FROM seniors AS p
        JOIN (SELECT MAX(run_date) AS run_date FROM senior_stats) AS s
        JOIN wca.results AS r ON r.person_id = p.wca_id AND average > 0
        JOIN wca.competitions AS c ON c.id = r.competition_id AND c.start_date < s.run_date
        WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
        AND accuracy_id NOT IN ('x', 'y')
        HAVING age_at_comp >= 40
        UNION ALL
        SELECT s.run_date, r.event_id, 'single' AS result_type, r.person_id, r.best,
            TIMESTAMPDIFF(YEAR, dob, c.start_date) AS age_at_comp
        FROM seniors AS p
        JOIN (SELECT MAX(run_date) AS run_date FROM senior_stats) AS s
        JOIN wca.results AS r ON r.person_id = p.wca_id AND best > 0
        JOIN wca.competitions AS c ON c.id = r.competition_id AND c.start_date < s.run_date
        WHERE YEAR(dob) <= YEAR(UTC_DATE()) - 40
        AND accuracy_id NOT IN ('x', 'y')
        HAVING age_at_comp >= 40
    ) AS t
    JOIN seq_40_to_100_step_10 ON seq <= age_at_comp
    GROUP BY event_id, result_type, age_category, person_id
) AS t
JOIN senior_views AS sv ON sv.run_date = t.run_date AND sv.event_id = t.event_id AND sv.result_type = t.result_type AND sv.age_category = t.age_category;

ALTER TABLE senior_bests ADD PRIMARY KEY (view_id, row_no);

/*
    Create improved senior bests table, including rolling averages
*/

DROP TEMPORARY TABLE IF EXISTS SeniorBestsExtra;
DROP TEMPORARY TABLE IF EXISTS senior_bests_extra;

CREATE TEMPORARY TABLE senior_bests_extra AS
SELECT view_id, row_no, person_id, best,
    FLOOR(MIN(best) OVER (PARTITION BY view_id ORDER BY row_no ROWS 5 PRECEDING)) AS rolling_min,
    FLOOR(AVG(best) OVER (PARTITION BY view_id ORDER BY row_no ROWS 5 PRECEDING)) AS rolling_avg
FROM senior_bests;

ALTER TABLE senior_bests_extra ADD PRIMARY KEY (view_id, row_no);
ALTER TABLE senior_bests_extra ADD INDEX senior_bests_extra_rolling_average (view_id, rolling_avg);

/*
    Pre-processing - Patch final group(s) in each view where the 'average' may be NULL
*/

-- Use the slowest results in the WCA to patch the final groups (where necessary)
UPDATE senior_stats_extra AS ss
JOIN senior_views AS sv ON sv.view_id = ss.view_id
JOIN
(
    SELECT event_id, MAX(best) AS max_single, MAX(average) AS max_average
    FROM wca.results AS r
    GROUP BY event_id
) AS t ON t.event_id = sv.event_id
SET ss.group_result = IF(sv.result_type = 'single', max_single, max_average)
WHERE group_result IS NULL;

-- Fix any groups preceding the ones patched by the last query
UPDATE senior_stats_extra AS ss1
JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no + 1
SET ss1.next_result = ss2.group_result
WHERE ss1.next_result IS NULL;

-- Get ready for the actual processing
ALTER TABLE senior_stats_extra ADD
(
    min_row_no smallint(6),
    max_row_no smallint(6),
    min_result int(11),
    max_result int(11),
    step_no tinyint(2)
);

/*
   Step 1 - Process groups with matching averages, using rolling averages of 6
*/

DROP TEMPORARY TABLE IF EXISTS SeniorGroups;
DROP TEMPORARY TABLE IF EXISTS senior_groups;

-- Create temporary table to speed up the step 1 processing
CREATE TEMPORARY TABLE senior_groups AS
SELECT ss.view_id, ss.group_no, sb.row_no, sb.rolling_min, sb.best
FROM senior_stats_extra AS ss
JOIN senior_bests_extra AS sb ON sb.view_id = ss.view_id AND sb.rolling_avg = ss.group_result
WHERE row_no >= group_size - 1;

ALTER TABLE senior_groups ADD INDEX senior_groups (view_id, group_no);

-- Determine most likely groups based on matching rolling averages #1 (required for FMC singles)
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT sg1.view_id, sg1.group_no, MIN(sg1.rolling_min) AS rolling_min, MIN(sg1.best) AS best, MIN(sg1.row_no) AS row_no
    FROM senior_groups AS sg1
    JOIN senior_groups AS sg2 ON sg2.view_id = sg1.view_id AND sg2.group_no = sg1.group_no - 1 AND sg2.row_no = sg1.row_no - 6
    JOIN senior_groups AS sg3 ON sg3.view_id = sg1.view_id AND sg3.group_no = sg1.group_no + 1 AND sg3.row_no = sg1.row_no + 6
    GROUP BY sg1.view_id, sg1.group_no
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET min_row_no = IF(row_no - 5 > 0, row_no - 5, 0), max_row_no = row_no, min_result = rolling_min, max_result = best, step_no = 1
WHERE step_no IS NULL;

-- Determine likely groups based on matching rolling averages #2 (avoiding overlaps with previous group)
UPDATE senior_stats_extra AS ss1
JOIN senior_groups AS sg ON sg.view_id = ss1.view_id AND sg.group_no = ss1.group_no
SET min_row_no = IF(row_no - 5 > 0, row_no - 5, 0), max_row_no = row_no, min_result = rolling_min, max_result = best, step_no = 1
WHERE NOT EXISTS
(
    SELECT 1
    FROM senior_stats_extra AS ss2
    WHERE ss2.view_id = ss1.view_id
    AND ss2.group_no = ss1.group_no - 1
    AND ss2.max_row_no >= IF(row_no - 5 > 0, row_no - 5, 0)
)
AND NOT EXISTS
(
    SELECT 1
    FROM senior_stats_extra AS ss3
    WHERE ss3.view_id = ss1.view_id
    AND ss3.group_no = ss1.group_no + 1
    AND ss3.min_row_no <= row_no
)
AND step_no IS NULL;

-- Reset any overlapping groups
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT ss2.view_id, ss2.group_no
    FROM senior_stats_extra AS ss1
    JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no > ss1.group_no
    WHERE ss2.min_row_no <= ss1.max_row_no
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET min_row_no = NULL, max_row_no = NULL, min_result = NULL, max_result = NULL, step_no = NULL;

-- Reset any groups where a gap (invalid) is present before the next group - rare but important!
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT ss2.view_id, ss2.group_no
    FROM senior_stats_extra AS ss1
    JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no + 1
    WHERE ss2.min_row_no > ss1.max_row_no + 1
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET min_row_no = NULL, max_row_no = NULL, min_result = NULL, max_result = NULL, step_no = NULL;

-- Reset any excessively wide groups
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT ss1.view_id, ss1.group_no
    FROM senior_stats_extra AS ss1
    JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no - 1
    JOIN senior_stats_extra AS ss3 ON ss3.view_id = ss1.view_id AND ss3.group_no = ss1.group_no + 1
    WHERE ss1.min_result < ss1.group_result - (ss1.group_result - ss1.prev_result) * 0.8
    AND ss2.prev_result IS NOT NULL AND ss2.step_no IS NULL
    AND NOT ss3.step_no <=> 1
    UNION
    SELECT ss1.view_id, ss1.group_no
    FROM senior_stats_extra AS ss1
    JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no + 1
    JOIN senior_stats_extra AS ss3 ON ss3.view_id = ss1.view_id AND ss3.group_no = ss1.group_no - 1
    WHERE ss1.max_result > ss1.group_result + (ss1.next_result - ss1.group_result) * 0.8
    AND ss2.next_result IS NOT NULL AND ss2.step_no IS NULL
    AND NOT ss3.step_no <=> 1
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET min_row_no = NULL, max_row_no = NULL, min_result = NULL, max_result = NULL, step_no = NULL;

/*
   Step 2 - Process groups sandwiched between groups identified in step 1
*/

-- Propagate max row to next group
UPDATE senior_stats_extra AS ss1
JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no - 1 AND ss2.max_row_no IS NOT NULL
SET ss1.min_row_no = ss2.max_row_no + 1
WHERE ss1.min_row_no IS NULL;

-- Propagate min row to previous group
UPDATE senior_stats_extra AS ss1
JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no + 1 AND ss2.min_row_no IS NOT NULL
SET ss1.max_row_no = ss2.min_row_no - 1
WHERE ss1.max_row_no IS NULL;

-- Process fully enclosed groups, including first and last groups
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT ss.view_id, group_no, MIN(row_no) AS min_row_no, MAX(row_no) AS max_row_no, MIN(best) AS min_result, MAX(best) AS max_result
    FROM senior_stats_extra AS ss
    JOIN senior_bests_extra AS sb ON sb.view_id = ss.view_id
        AND (sb.row_no >= ss.min_row_no OR prev_result IS NULL) AND (sb.row_no <= ss.max_row_no OR next_result IS NULL)
    WHERE step_no IS NULL
    GROUP BY view_id, group_no
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET ss.min_row_no = t.min_row_no, ss.max_row_no = t.max_row_no, ss.min_result = t.min_result, ss.max_result = t.max_result, step_no = 2;

/*
   Step 3 - Process groups with a single known boundary
*/

-- Process groups with undefined max row (includes first groups)
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT ss.view_id, ss.group_no, MIN(row_no) AS min_row_no, MAX(row_no) AS max_row_no, MIN(best) AS min_result, MAX(best) AS max_result
    FROM senior_stats_extra AS ss
    JOIN senior_bests_extra AS sb ON sb.view_id = ss.view_id
        AND (row_no >= min_row_no OR prev_result IS NULL) AND best <= (group_result + next_result) / 2
    WHERE step_no IS NULL
    GROUP BY view_id, group_no
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET ss.min_row_no = t.min_row_no, ss.max_row_no = t.max_row_no, ss.min_result = t.min_result, ss.max_result = t.max_result, ss.step_no = 3;

-- Process groups with undefined min row (includes final groups)
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT ss.view_id, ss.group_no, MIN(row_no) AS min_row_no, MAX(row_no) AS max_row_no, MIN(best) AS min_result, MAX(best) AS max_result
    FROM senior_stats_extra AS ss
    JOIN senior_bests_extra AS sb ON sb.view_id = ss.view_id
        AND best > (prev_result + group_result) / 2 AND (row_no <= max_row_no OR next_result IS NULL)
    WHERE step_no IS NULL
    GROUP BY view_id, group_no
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET ss.min_row_no = t.min_row_no, ss.max_row_no = t.max_row_no, ss.min_result = t.min_result, ss.max_result = t.max_result, ss.step_no = 3;

/*
   Step 4 - Soft match where prev and next groups unknown, including first and last groups
*/

UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT ss.view_id, ss.group_no, MIN(row_no) AS min_row_no, MAX(row_no) AS max_row_no, MIN(best) AS min_result, MAX(best) AS max_result
    FROM senior_stats_extra AS ss
    JOIN senior_bests_extra AS sb ON sb.view_id = ss.view_id AND min_row_no IS NULL AND max_row_no IS NULL
        AND (best > (prev_result + group_result) / 2 OR prev_result IS NULL) AND (best <= (group_result + next_result) / 2 OR next_result IS NULL)
    WHERE step_no IS NULL
    GROUP BY view_id, group_no
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET ss.min_row_no = t.min_row_no, ss.max_row_no = t.max_row_no, ss.min_result = t.min_result, ss.max_result = t.max_result, ss.step_no = 4;

/*
    Post processing - Calculate averages, totals, counts, etc.
*/

ALTER TABLE senior_stats_extra ADD
(
    tot_result bigint(12),
    avg_result int(11),
    num_rows smallint(6),
    num_missing smallint(6),
    tot_rows smallint(6),
    tot_missing smallint(6)
);

UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT t.*, SUM(num_rows) OVER (PARTITION BY view_id ORDER BY group_no) AS tot_rows
    FROM
    (
        SELECT ss.view_id, ss.group_no, SUM(best) AS tot_result, FLOOR(AVG(best)) AS avg_result, COUNT(person_id) AS num_rows
        FROM senior_stats_extra AS ss
        LEFT JOIN senior_bests_extra AS sb ON sb.view_id = ss.view_id AND row_no BETWEEN min_row_no AND max_row_no
        GROUP BY ss.view_id, ss.group_no
    ) AS t
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET ss.tot_result = t.tot_result, ss.avg_result = t.avg_result, ss.num_rows = t.num_rows, ss.tot_rows = t.tot_rows,
    ss.num_missing = ss.group_size - t.num_rows, ss.tot_missing = ss.tot_seniors - t.tot_rows;

-- Patch step_no where last group has a matching average (i.e. essentially step 1 but <6 rows)
UPDATE senior_stats_extra
SET step_no = 1
WHERE next_result IS NULL
AND avg_result = group_result
AND num_rows = group_size
AND group_size >= 4
AND step_no > 1;

-- Ensure that total missing is not negative
UPDATE senior_stats_extra
SET tot_missing = 0
WHERE tot_missing < 0;

-- Transfer total missing from later groups to earlier groups, where it is a smaller number
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT view_id, group_no, MIN(tot_missing) OVER (PARTITION BY view_id ORDER BY group_no RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS tot_missing
    FROM senior_stats_extra
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET ss.tot_missing = t.tot_missing
WHERE ss.tot_missing > t.tot_missing;

-- Fix number missing for the first group, ensuring consistency with total missing
UPDATE senior_stats_extra AS ss
SET num_missing = tot_missing
WHERE prev_result IS NULL
AND num_missing != tot_missing;

-- Fix number missing for all other groups, ensuring consistency with total missing
UPDATE senior_stats_extra AS ss
JOIN
(
    SELECT view_id, group_no, tot_missing - LAG(tot_missing) OVER (PARTITION BY view_id ORDER BY group_no) AS num_missing
    FROM senior_stats_extra
) AS t ON t.view_id = ss.view_id AND t.group_no = ss.group_no
SET ss.num_missing = t.num_missing
WHERE ss.num_missing != t.num_missing;

/*
    Generate artificial / fake results for missing seniors
*/

DROP TABLE IF EXISTS SeniorFakes;
DROP TABLE IF EXISTS senior_fakes;

CREATE TABLE senior_fakes AS
(
    -- Most artificial results are created using ranges and intervals
    SELECT view_id, CAST(fake_result AS unsigned integer) AS fake_result, group_no, num_missing, CONVERT('FAKE_RANGE' USING utf8) AS fake_id
    FROM
    (
        SELECT view_id,
            ROUND((group_result - fake_range / 2 + fake_interval / 2) + fake_interval * seq) AS fake_result,
            group_no, num_missing
        FROM
        (
            SELECT *,
                IFNULL(IF(group_result - prev_result < next_result - group_result OR next_result IS NULL,
                    group_result - prev_result, next_result - group_result), 0) AS fake_range,
                IFNULL(IF(group_result - prev_result < next_result - group_result OR next_result IS NULL,
                    group_result - prev_result, next_result - group_result), 0) / num_missing AS fake_interval
            FROM senior_stats_extra
            WHERE NOT (step_no = 2 AND num_missing = 1 AND num_rows = group_size - 1 AND group_size >= 4)
        ) AS t
        JOIN seq_0_to_5 ON seq < num_missing
    ) AS t
)
UNION ALL
(
    -- A small number of artificial results can be exactly calculated
    SELECT view_id, CAST(group_result * group_size - tot_result AS unsigned integer) AS fake_result, group_no, num_missing, CONVERT('FAKE_EXACT' USING utf8) AS fake_id
    FROM senior_stats_extra
    WHERE step_no = 2
    AND num_missing = 1
    AND num_rows = group_size - 1
    AND group_size >= 4
);
