/* 
    Script:   Check System
    Created:  2019-04-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Check server configuration and status
*/

-- InnoDB Buffer Pool
SELECT @@innodb_buffer_pool_size / 1024 / 1024; -- 128 MB -> 2048 MB
SHOW VARIABLES LIKE 'innodb_buffer_pool_instances'; -- 8

-- InnoDB Log Files
SELECT @@innodb_log_file_size / 1024 / 1024;  -- 48 MB -> 512MB
SHOW VARIABLES LIKE 'innodb_log_files_in_group'; -- 2

-- Data Import and Export Operations
SHOW VARIABLES LIKE 'secure_file_priv'; -- NULL -> empty

-- InnoDB Flush Log at Transaction Commit
SHOW VARIABLES LIKE 'innodb_flush_log_at_trx_commit'; -- 1 -> 2 

-- InnoDB Flush Method
SHOW VARIABLES LIKE 'innodb_flush_method'; -- O_DIRECT -> O_DIRECT_NO_FSYNC

-- InnoDB Doublewrite Buffer
SHOW VARIABLES LIKE 'innodb_doublewrite'; -- ON

-- InnoDB Native AIO
SHOW VARIABLES LIKE 'innodb_use_native_aio'; -- ON

-- InnodDB Log Buffer Size
SELECT @@innodb_log_buffer_size / 1024 / 1024;  -- 8MB

-- Auto Commit
SHOW VARIABLES LIKE 'autocommit'; -- ON

-- InnoDB Buffer Pool Dump + Load
SHOW VARIABLES LIKE 'innodb_buffer_pool_dump_at_shutdown'; -- ON
SHOW VARIABLES LIKE 'innodb_buffer_pool_load_at_startup'; -- ON

-- InnoDB File Configuration
SHOW VARIABLES LIKE 'innodb_file_per_table'; -- ON
SHOW VARIABLES LIKE 'innodb_page_size'; -- 16384

-- InnoDB Thread Concurrency (0 = automatic)
SHOW VARIABLES LIKE 'innodb_thread_concurrency'; -- 0

-- InnoDB Engine Status
SHOW ENGINE INNODB STATUS;

-- InnoDB Log Waits (>0 implies the log buffer is too small)
SHOW GLOBAL STATUS  LIKE 'innodb_log_waits'; -- 0

-- InnoDB OS Log Written
SHOW GLOBAL STATUS LIKE 'innodb_os_log_written';

-- InnoDB Data Fsyncs
SHOW GLOBAL STATUS LIKE 'innodb_data_fsyncs';

-- InnoDB Buffer Pool Usage
SELECT CONCAT(FORMAT(DataPages * 100.0 / TotalPages, 2), ' %') AS BufferPoolDataPercentage
FROM
(
	SELECT variable_value DataPages
	FROM information_schema.global_status
	WHERE variable_name = 'Innodb_buffer_pool_pages_data'
) AS A,
(
	SELECT variable_value TotalPages
	FROM information_schema.global_status
	WHERE variable_name = 'Innodb_buffer_pool_pages_total'
) AS B;