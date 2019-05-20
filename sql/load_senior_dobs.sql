/*
    Script:   Apply known DOBs to the "Persons" table
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02

    Purpose:  Unofficial rankings for the Over-40's - https://github.com/Logiqx/wca-ipy.
*/

DROP TABLE IF EXISTS Seniors;

CREATE TABLE Seniors
(
     `personId` varchar(10) CHARACTER SET latin1 NOT NULL,
     `accuracy` char(1) NOT NULL,
     `dob` date,
     `username` varchar(30) CHARACTER SET latin1 NULL,
     `comment` text CHARACTER SET latin1 NOT NULL,
     PRIMARY KEY (`personId`)
);

LOAD DATA INFILE '/home/jovyan/work/wca-ipy/data/private/load/seniors.csv'
INTO TABLE Seniors FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"';

-- Start with default YMD of zero
UPDATE Persons AS p
SET p.year = 0,
    p.month = 0,
    p.day = 0;

-- Update DOB if known (or approximated)
UPDATE Persons AS p
INNER JOIN Seniors AS s ON s.personId = p.id AND s.dob IS NOT NULL
SET p.year = DATE_FORMAT(s.dob, "%Y"),
    p.month = DATE_FORMAT(s.dob, "%m"),
    p.day = DATE_FORMAT(s.dob, "%d");

-- Use 19th century for any seniors where DOB is unknown
UPDATE Persons AS p
INNER JOIN Seniors AS s ON s.personId = p.id AND s.dob IS NULL
SET p.year = 1900,
    p.month = 1,
    p.day = 1;
