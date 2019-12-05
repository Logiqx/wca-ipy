/* 
    Script:   Load senior aggregates
    Created:  2019-11-10
    Author:   Michael George / 2015GEOR02

    Purpose:  Load senior averages aggregates 
*/

/* 
   Load the one-off extract from the WCA, created 2019-02-01
*/

DROP TABLE IF EXISTS SeniorAveragesPrevious;

CREATE TABLE SeniorAveragesPrevious
(
  `eventId` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `result` int(11) NOT NULL,
  `numSeniors` smallint(6) NOT NULL,
   PRIMARY KEY (`eventId`, `result`)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/load/senior_averages_agg.csv'
INTO TABLE SeniorAveragesPrevious FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;
