/*
    Script:   Load senior result counts
    Created:  2019-12-15
    Author:   Michael George / 2015GEOR02

    Purpose:  Load counts of senior results into the database
*/

DROP TABLE IF EXISTS SeniorResultCounts;

CREATE TABLE SeniorResultCounts
(
  `cutoffDate` DATE NOT NULL,
  `eventId` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ageCategory` tinyint(2) NOT NULL,
  `numSingles` mediumint(6),
  `numAverages` mediumint(6) NOT NULL,
   PRIMARY KEY (`cutoffDate`, `eventId`, `ageCategory`)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/load/senior_result_counts.csv'
INTO TABLE SeniorResultCounts FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 0 LINES;
