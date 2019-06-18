/*
    Script:   Apply known DOBs to the "Persons" table
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02

    Purpose:  Unofficial rankings for the over 40s - https://github.com/Logiqx/wca-ipy.
*/

DROP TABLE IF EXISTS wca_ipy.Seniors;

CREATE TABLE wca_ipy.Seniors
(
     `personId` varchar(10) CHARACTER SET latin1 NOT NULL,
     `sourceId` char(1) NOT NULL DEFAULT 'U',
     `hidden` char(1) NOT NULL DEFAULT 'Y',
     `accuracyId` char(1) NOT NULL,
     `dob` date,
     `username` varchar(30) CHARACTER SET latin1,
     `usernum` mediumint NOT NULL DEFAULT 0,
     `comment` text CHARACTER SET latin1 NOT NULL,
     PRIMARY KEY (`personId`),
     FOREIGN KEY (`sourceId`) REFERENCES SeniorSources(`id`),
     FOREIGN KEY (`accuracyId`) REFERENCES SeniorAccuracies(`id`)
);

LOAD DATA INFILE '/home/jovyan/work/wca-ipy/data/private/load/seniors.csv'
INTO TABLE wca_ipy.Seniors FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"';

-- Start with default YMD of zero
UPDATE Persons AS p
SET p.year = 0,
    p.month = 0,
    p.day = 0;

-- Update DOB if known (or approximated)
UPDATE Persons AS p
INNER JOIN wca_ipy.Seniors AS s ON s.personId = p.id AND s.dob IS NOT NULL AND hidden = 'N'
SET p.year = DATE_FORMAT(s.dob, '%Y'),
    p.month = DATE_FORMAT(s.dob, '%m'),
    p.day = DATE_FORMAT(s.dob, '%d');

-- Use 19th century for any seniors where DOB is unknown
UPDATE Persons AS p
INNER JOIN wca_ipy.Seniors AS s ON s.personId = p.id AND s.dob IS NULL AND hidden = 'N'
SET p.year = 1900,
    p.month = 1,
    p.day = 1;

-- Add name and country to seniors
ALTER TABLE wca_ipy.Seniors ADD COLUMN
(
  `name` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `countryId` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `gender` char(1) COLLATE utf8mb4_unicode_ci DEFAULT ''
);

-- Populate name and country on seniors
UPDATE wca_ipy.Seniors s
JOIN Persons p ON p.id = s.personId AND p.subid = 1
SET s.name = p.name, s.countryId = p.countryId, s.gender = p.gender;
