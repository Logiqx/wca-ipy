/*
    Script:   Load senior stats
    Created:  2019-12-25
    Author:   Michael George / 2015GEOR02

    Purpose:  Load senior stats
*/

DROP TABLE IF EXISTS SeniorStats;

CREATE TABLE SeniorStats
(
  `runDate` DATE NOT NULL,
  `eventId` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resultType` varchar(7)  COLLATE utf8mb4_unicode_ci NOT NULL,
  `ageCategory` tinyint(2) NOT NULL,
  `groupNo` smallint(4) NOT NULL,
  `groupSize` tinyint(2) NOT NULL,
  `groupResult` int(11)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/feed/senior_stats.csv'
INTO TABLE SeniorStats FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"';

ALTER TABLE SeniorStats ADD UNIQUE KEY SeniorStatsCompositeKey (runDate, eventId, resultType, ageCategory, groupNo);
