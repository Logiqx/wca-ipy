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

ALTER TABLE SeniorStats ADD PRIMARY KEY (runDate, eventId, resultType, ageCategory, groupNo);

/*
    Continent stats
*/

DROP TABLE IF EXISTS ContinentStats;

CREATE TABLE ContinentStats
(
  `runDate` DATE NOT NULL,
  `eventId` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resultType` varchar(7)  COLLATE utf8mb4_unicode_ci NOT NULL,
  `ageCategory` tinyint(2) NOT NULL,
  `continentId` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numSeniors` mediumint(5) NOT NULL,
  `numPersons` mediumint(6) NOT NULL,
  `pctSeniors` decimal(5,2)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/feed/continent_stats.csv'
INTO TABLE ContinentStats FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"';

ALTER TABLE ContinentStats ADD PRIMARY KEY (runDate, eventId, resultType, ageCategory, continentId);
ALTER TABLE ContinentStats ADD INDEX ContinentStatsCompositeKey (eventId, resultType, ageCategory, continentId);

/*
    Country stats
*/

DROP TABLE IF EXISTS CountryStats;

CREATE TABLE CountryStats
(
  `runDate` DATE NOT NULL,
  `eventId` varchar(6) COLLATE utf8mb4_unicode_ci NOT NULL,
  `resultType` varchar(7)  COLLATE utf8mb4_unicode_ci NOT NULL,
  `ageCategory` tinyint(2) NOT NULL,
  `countryId` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numSeniors` mediumint(5) NOT NULL,
  `numPersons` mediumint(6) NOT NULL,
  `pctSeniors` decimal(5,2)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/feed/country_stats.csv'
INTO TABLE CountryStats FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"';

ALTER TABLE CountryStats ADD PRIMARY KEY (runDate, eventId, resultType, ageCategory, countryId);
ALTER TABLE CountryStats ADD INDEX CountryStatsCompositeKey (eventId, resultType, ageCategory, countryId);
