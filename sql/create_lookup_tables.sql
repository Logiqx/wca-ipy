/* 
      Script:   Create lookup tables
      Created:  2019-06-02
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Small lookups
*/

/*
   Senior Sources
*/

DROP TABLE IF EXISTS SeniorSources;

CREATE TABLE SeniorSources
(
     `id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `type` varchar(10) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO SeniorSources VALUES
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

CREATE TABLE SeniorAccuracies
(
     `id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `type` varchar(10) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO SeniorAccuracies VALUES
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

CREATE TABLE UserStatuses
(
     `id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `type` varchar(12) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO UserStatuses VALUES
('c', 'Confirmed', 'User has been confirmed by delegate'),
('u', 'Unconfirmed', 'User has yet to be be confirmed by delegate'),
('r', 'Registered', 'User registered for competition and has been matched via results'),
('p', 'Possible', 'User possible due to match on name and country'),
('n', 'Non-existent', 'User does not exist');
