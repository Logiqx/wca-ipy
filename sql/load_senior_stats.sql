/*
    Script:   Load senior stats
    Created:  2019-12-25
    Author:   Michael George / 2015GEOR02

    Purpose:  Load senior stats
*/

/*
    Worldwide stats
*/

DROP TABLE IF EXISTS SeniorStats;
DROP TABLE IF EXISTS senior_stats;

CREATE TABLE senior_stats
(
  `run_date` DATE NOT NULL,
  `event_id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `result_type` varchar(7)  COLLATE utf8mb4_unicode_ci NOT NULL,
  `age_category` tinyint(2) NOT NULL,
  `group_no` smallint(4) NOT NULL,
  `group_size` tinyint(2) NOT NULL,
  `group_result` int(11)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/feed/senior_stats.csv'
INTO TABLE senior_stats FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;

ALTER TABLE senior_stats ADD PRIMARY KEY (run_date, event_id, result_type, age_category, group_no);

/*
    Continent stats
*/

DROP TABLE IF EXISTS ContinentStats;
DROP TABLE IF EXISTS continent_stats;

CREATE TABLE continent_stats
(
  `run_date` DATE NOT NULL,
  `event_id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `result_type` varchar(7)  COLLATE utf8mb4_unicode_ci NOT NULL,
  `age_category` tinyint(2) NOT NULL,
  `continent_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `num_seniors` mediumint(5) NOT NULL,
  `num_persons` mediumint(6) NOT NULL,
  `pct_seniors` decimal(5,2)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/feed/continent_stats.csv'
INTO TABLE continent_stats FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;

ALTER TABLE continent_stats ADD PRIMARY KEY (run_date, event_id, result_type, age_category, continent_id);
ALTER TABLE continent_stats ADD INDEX continent_stats_composite_key (event_id, result_type, age_category, continent_id);

/*
    Country stats
*/

DROP TABLE IF EXISTS CountryStats;
DROP TABLE IF EXISTS country_stats;

CREATE TABLE country_stats
(
  `run_date` DATE NOT NULL,
  `event_id` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `result_type` varchar(7)  COLLATE utf8mb4_unicode_ci NOT NULL,
  `age_category` tinyint(2) NOT NULL,
  `country_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `num_seniors` mediumint(5) NOT NULL,
  `num_persons` mediumint(6) NOT NULL,
  `pct_seniors` decimal(5,2)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/feed/country_stats.csv'
INTO TABLE country_stats FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;

ALTER TABLE country_stats ADD PRIMARY KEY (run_date, event_id, result_type, age_category, country_id);
ALTER TABLE country_stats ADD INDEX country_stats_composite_key (event_id, result_type, age_category, country_id);
