/*
    Script:   Apply known DOBs to the "Persons" table
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02

    Purpose:  Unofficial rankings for the over 40s - https://github.com/Logiqx/wca-ipy.
*/

DROP TABLE IF EXISTS Seniors;
DROP TABLE IF EXISTS seniors;

CREATE TABLE seniors
(
     `wca_id` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
     `dob` date NOT NULL,
     `hidden` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'y',
     `deceased` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'n',
     `accuracy_id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `source_id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'u',
     `user_status_id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'n',
     `user_id` int(11) DEFAULT NULL,
     `username` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
     `usernum` mediumint NOT NULL DEFAULT 0,
     `email` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
     `facebook` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
     `youtube` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`wca_id`),
     FOREIGN KEY (`accuracy_id`) REFERENCES senior_accuracies(`id`),
     FOREIGN KEY (`source_id`) REFERENCES senior_sources(`id`),
     FOREIGN KEY (`user_status_id`) REFERENCES user_statuses(`id`)
);

LOAD DATA LOCAL INFILE '/home/jovyan/work/wca-ipy-private/data/private/load/seniors.csv'
INTO TABLE seniors CHARACTER SET utf8 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;

-- Add name and country to seniors
ALTER TABLE seniors ADD COLUMN
(
  `name` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `gender` char(1) COLLATE utf8mb4_unicode_ci DEFAULT ''
);

-- Populate name and country on seniors
UPDATE seniors s
JOIN wca.persons p ON p.wca_id = s.wca_id AND p.sub_id = 1
SET s.name = p.name, s.country_id = p.country_id, s.gender = p.gender;
