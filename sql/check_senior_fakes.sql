/*
    Script:   Check Senior Fakes
    Created:  2019-12-27
    Author:   Michael George / 2015GEOR02

    Purpose:  Check senior fakes for processing errors
*/

/*
   Sanity checks
*/

-- NULL group_result implies pre-processing was incomplete
SELECT 'Poor pre-processing' AS label, sv.*, ss.*
FROM senior_stats_extra AS ss
JOIN senior_views AS sv ON sv.view_id = ss.view_id
WHERE group_result IS NULL;

-- Check num_rows always matches row numbers
SELECT 'Incorrect num_rows' AS label, sv.*, ss.*
FROM senior_stats_extra AS ss
JOIN senior_views AS sv on sv.view_id = ss.view_id
WHERE num_rows != max_row_no - min_row_no + 1;

-- Check last row
SELECT 'Incorrect totals' AS label, sv.*, ss.*
FROM senior_stats_extra AS ss
JOIN senior_views AS sv on sv.view_id = ss.view_id
WHERE next_result IS NULL
AND tot_seniors != tot_rows + tot_missing;

-- Check totals of the two tables
SELECT 'Incorrect count' AS label, sv.*, t1.view_id, t1.tot_rows, t2.num_persons
FROM
(
    SELECT ss.view_id, SUM(num_rows) AS tot_rows
    FROM senior_stats_extra AS ss
    GROUP BY view_id
) AS t1
JOIN
(
    SELECT view_id, COUNT(DISTINCT wca_id) AS num_persons
    FROM senior_bests
    GROUP BY view_id
) AS t2 ON t2.view_id = t1.view_id
JOIN senior_views AS sv ON sv.view_id = t1.view_id
WHERE NOT tot_rows = num_persons;

-- List exceptions
/*
SELECT 'Missing result' AS label, sv.*, sb.row_no, sb.wca_id, sb.best
FROM senior_bests_extra AS sb
JOIN senior_views AS sv ON sv.view_id = sb.view_id
LEFT JOIN senior_stats_extra AS ss ON ss.view_id = sb.view_id AND row_no BETWEEN min_row_no AND max_row_no
WHERE ss.view_id IS NULL;
*/

-- Check for change in tot_missing
SELECT 'tot_missing' AS label, sv.*, ss2.*
FROM senior_stats_extra AS ss1
JOIN senior_stats_extra AS ss2 ON ss2.view_id = ss1.view_id AND ss2.group_no = ss1.group_no + 1
JOIN senior_views AS sv ON sv.view_id = ss1.view_id
WHERE ss2.tot_missing < ss1.tot_missing;

-- ???
SELECT 'tot_missing' AS label, sv.*, t.*
FROM
(
    SELECT *, MAX(tot_missing) OVER (PARTITION BY view_id ORDER BY group_no) AS max_tot_missing
    FROM senior_stats_extra
) AS t
JOIN senior_views AS sv ON sv.view_id = t.view_id
WHERE t.max_tot_missing > t.tot_missing
ORDER BY t.view_id, group_no;

-- Evaluate Overall Counts
SELECT 'Overall count' AS label, t.view_id, event_id, result_type, age_category, SUM(group_size) AS expected_recs, num_recs
FROM
(
    SELECT view_id, COUNT(*) AS num_recs
    FROM
    (
        SELECT view_id, fake_result AS best, 'fake' AS label
        FROM senior_fakes
        UNION ALL
        SELECT view_id, best, 'real' AS label
        FROM senior_bests
    ) AS t
    GROUP BY view_id
) AS t
JOIN senior_stats_extra AS ss ON ss.view_id = t.view_id
JOIN senior_views AS sv ON sv.view_id = t.view_id
GROUP BY view_id
HAVING num_recs != expected_recs;

-- Check types of fakes

SELECT 'Unexpected exact' AS label, sv.*, sf.*, ss.*
FROM senior_fakes AS sf
JOIN senior_stats_extra AS ss ON ss.view_id = sf.view_id AND ss.group_no = sf.group_no
JOIN senior_views AS sv on sv.view_id = ss.view_id
WHERE fake_id = 'FAKE_EXACT'
AND (ss.step_no != 2 OR ss.num_missing != 1 OR ss.num_rows != ss.group_size - 1 OR ss.group_size < 4);

SELECT 'Unexpected range' AS label, sv.*, sf.*, ss.*
FROM senior_fakes AS sf
JOIN senior_stats_extra AS ss ON ss.view_id = sf.view_id AND ss.group_no = sf.group_no
JOIN senior_views AS sv on sv.view_id = ss.view_id
WHERE fake_id = 'FAKE_RANGE'
AND NOT (ss.step_no != 2 OR ss.num_missing != 1 OR ss.num_rows != ss.group_size - 1 OR ss.group_size < 4);
