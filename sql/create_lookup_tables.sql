/* 
      Script:   Create lookup tables
      Created:  2019-06-02
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Small lookups
*/

/*
   Drop tables with FK constraints
*/

DROP TABLE IF EXISTS Seniors;
DROP TABLE IF EXISTS seniors;
DROP TABLE IF EXISTS Juniors;
DROP TABLE IF EXISTS juniors;

/*
   Senior Sources
*/

DROP TABLE IF EXISTS SeniorSources;
DROP TABLE IF EXISTS senior_sources;

CREATE TABLE senior_sources
(
     `id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `type` varchar(10) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO senior_sources VALUES
('c', 'Contacted', 'Contacted via Messenger after being found or spotted'),
('d', 'Derived', 'Derived from other sources (e.g. old WCA statistics)'),
('f', 'Found', 'Found DOB or YOB on Speedsolving.com, Facebook, etc'),
('h', 'Historic', 'Historical sources (e.g. old age statistics or WCA records)'),
('p', 'Provided', 'Provided DOB in person, via a friend, Speedsolving.com, Facebook, etc'),
('s', 'Spotted', 'Spotted profile on Facebook, WCA website, etc');

/*
   Senior Accuracies
*/

DROP TABLE IF EXISTS SeniorAccuracies;
DROP TABLE IF EXISTS senior_accuracies;

CREATE TABLE senior_accuracies
(
     `id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `type` varchar(10) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO senior_accuracies VALUES
('d', 'Day', 'Precise DOB'),
('f', 'Fake', 'Fake DOB to exclude earlier competitions'),
('m', 'Month', 'Month of birth - e.g. 1972-07-31 for July 1972'),
('s', 'Synthetic', 'Synthetic DOB based on competition date'),
('u', 'Unknown', 'DOB is unknown but known to be over 40'),
('x', 'Approx', 'Approximate DOB based on age being stated / provided'),
('y', 'Year', 'Year of birth - e.g. 1972-12-31 for 1972');

/*
   Users Statuses
*/

DROP TABLE IF EXISTS UserStatuses;
DROP TABLE IF EXISTS user_statuses;

CREATE TABLE user_statuses
(
     `id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `type` varchar(12) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO user_statuses VALUES
('c', 'Confirmed', 'User has been confirmed by delegate'),
('u', 'Unconfirmed', 'User has yet to be be confirmed by delegate'),
('r', 'Registered', 'User registered for competition and has been matched via results'),
('p', 'Possible', 'User possible due to match on name and country'),
('n', 'Non-existent', 'User does not exist');

/*
    Continent Codes
*/

DROP TABLE IF EXISTS ContinentCodes;
DROP TABLE IF EXISTS continent_codes;

CREATE TABLE continent_codes
(
     `id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
     `cc` char(2) COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO continent_codes VALUES
('_Africa', 'AF'),
('_Asia', 'AS'),
('_Europe', 'EU'),
('_Multiple Continents', 'MC'),
('_North America', 'NA'),
('_Oceania', 'OC'),
('_South America', 'SA');
