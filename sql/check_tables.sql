/* 
    Script:   Check Tables
    Created:  2019-04-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Check table sizes
*/

SELECT table_schema, ROUND(sum(data_length / 1024 / 1024), 2) AS data_length_mb
FROM information_schema.tables
WHERE table_schema IN ('wca', 'wcastats')
GROUP BY table_schema;

SELECT table_schema, table_name, ROUND(data_length / 1024 / 1024, 2) AS data_length_mb
FROM information_schema.tables
WHERE table_schema IN ('wca', 'wcastats')
ORDER BY data_length desc, table_schema;

SELECT table_name, database_name, index_name,
	ROUND(stat_value *
		CASE
			WHEN table_name LIKE '%16' THEN 16384
			WHEN table_name LIKE '%8' THEN 8192
			WHEN table_name LIKE '%4' THEN 4096
			WHEN table_name LIKE '%2' THEN 2048
			WHEN table_name LIKE '%1' THEN 1024
            WHEN database_name = 'wcastats' THEN 8192
			ELSE @@innodb_page_size
		END / 1024 / 1024, 2) size_in_mb
FROM mysql.innodb_index_stats
WHERE stat_name = 'size' AND database_name IN ('wca', 'wcastats') AND table_name like 'Scrambles%'
ORDER BY table_name, database_name, size_in_mb DESC;

SELECT * FROM information_schema.statistics WHERE table_schema = 'wcastats';