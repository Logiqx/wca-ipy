/*
    Script:   Review Senior Fakes
    Created:  2019-12-27
    Author:   Michael George / 2015GEOR02

    Purpose:  Review senior fakes for curiosities
*/

-- Summarise seniors by event
SELECT event_id, result_type, age_category,
    tot_seniors, known_seniors, tot_seniors - known_seniors AS missing_seniors, IFNULL(top_seniors, 0) AS top_seniors,
    ROUND(100 * known_seniors / tot_seniors, 2) AS pct_known_seniors,
    ROUND(100 * (tot_seniors - known_seniors) / tot_seniors, 2) AS pct_missing_seniors,
    ROUND(100 * IFNULL(top_seniors, 0) / tot_seniors, 2) AS pct_top_seniors
FROM
(
    SELECT view_id, MAX(tot_seniors) AS tot_seniors, MAX(tot_rows) AS known_seniors
    FROM senior_stats_extra AS ss1
    GROUP BY view_id
)
AS t1
LEFT JOIN
(
    SELECT ss1.view_id, MAX(tot_rows) AS top_seniors
    FROM senior_stats_extra AS ss1
    WHERE step_no BETWEEN 1 AND 2
    AND num_rows >= group_size - 1
    AND NOT EXISTS
    (
        SELECT 1
        FROM senior_stats_extra AS ss2
        WHERE ss2.view_id = ss1.view_id
        AND ss2.group_no < ss1.group_no
        AND (NOT step_no BETWEEN 1 AND 2 OR num_rows < group_size - 1)
    )
    GROUP BY view_id
) AS t2 ON t2.view_id = t1.view_id
JOIN senior_views AS sv on sv.view_id = t1.view_id
WHERE event_id NOT IN ('magic', 'mmagic', '333mbo')
-- AND age_category = 40 -- can comment out
-- AND result_type = 'average' -- can comment out
ORDER BY event_id, age_category, result_type DESC;

-- Check for matching results (commonplace)

SELECT event_id, result_type, age_category, sb.view_id, best, MIN(row_no), MAX(row_no), COUNT(*)
FROM senior_bests_extra AS sb
JOIN senior_views AS sv ON sv.view_id = sb.view_id
GROUP BY view_id, best
HAVING COUNT(*) > 1;

-- Check for matching rolling averages (typically 333fm single)

SELECT event_id, result_type, age_category, sb.view_id, rolling_avg, MIN(row_no), MAX(row_no), COUNT(*)
FROM senior_bests_extra AS sb
JOIN senior_views AS sv ON sv.view_id = sb.view_id
GROUP BY view_id, rolling_avg
HAVING COUNT(*) > 1;

-- Only min or max row is curious but not significant
SELECT 'Curious row' AS label, sv.*, ss.*
FROM senior_stats_extra AS ss
JOIN senior_views AS sv on sv.view_id = ss.view_id
WHERE (min_row_no IS NULL AND max_row_no IS NOT NULL)
    OR (min_row_no IS NOT NULL AND max_row_no IS NULL);

-- Check where propogation of num_missing had an effect
SELECT 'Incorrect totals' AS label, sv.*, ss.*
FROM senior_stats_extra AS ss
JOIN senior_views AS sv on sv.view_id = ss.view_id
WHERE tot_seniors < tot_rows + tot_missing;

-- Check for rolling averages that haven't been used despite exact match
-- TODO - Investigate 333mbf
SELECT sv.*, ss.*
FROM senior_stats_extra AS ss
JOIN senior_views AS sv ON sv.view_id = ss.view_id
JOIN senior_bests_extra AS sb ON sb.view_id = ss.view_id AND sb.rolling_avg = ss.group_result
WHERE step_no IS NULL;

-- Check for groups with large numbers of missing seniors
SELECT 'Unknowns' AS label, sv.*,
    MIN(num_missing) AS min_num_missing, MAX(num_missing) AS max_num_missing,
    MIN(ss.group_no) AS first_group_no, MIN(ss.tot_seniors) AS first_tot_seniors
FROM senior_stats_extra AS ss
JOIN senior_views AS sv ON sv.view_id = ss.view_id
WHERE num_missing BETWEEN 4 AND 5
-- AND age_category = 50
GROUP BY ss.view_id;

-- Check for fake results outside of sensible range #1
SELECT sv.*, ss.*, sf.*
FROM senior_fakes AS sf
JOIN senior_stats_extra AS ss ON ss.view_id = sf.view_id AND ss.group_no = sf.group_no
JOIN senior_views AS sv ON sv.view_id = sf.view_id
WHERE fake_result < group_result - (group_result - prev_result) * 0.8
OR fake_result > group_result + (next_result - group_result) * 0.8;

-- Check for fake results outside of sensible range #2
SELECT sv.*, ss2.*, sf.*
FROM senior_fakes AS sf
JOIN senior_stats_extra AS ss1 ON ss1.view_id = sf.view_id AND ss1.group_no = sf.group_no
JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no - 1
JOIN senior_views AS sv ON sv.view_id = sf.view_id
WHERE fake_result < ss2.max_result;

-- Check for fake results outside of sensible range #3
SELECT sv.*, ss2.*, sf.*
FROM senior_fakes AS sf
JOIN senior_stats_extra AS ss1 ON ss1.view_id = sf.view_id AND ss1.group_no = sf.group_no
JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no + 1
JOIN senior_views AS sv ON sv.view_id = sf.view_id
WHERE fake_result > ss2.min_result;
