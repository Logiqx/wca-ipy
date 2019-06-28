/* 
      Script:   Create lookup tables
      Created:  2019-06-02
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Small lookups
*/

DROP TABLE IF EXISTS wca_ipy.SeniorSources;

CREATE TABLE wca_ipy.SeniorSources
(
     `id` char(1)  NOT NULL,
     `type` varchar(10) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO wca_ipy.SeniorSources VALUES
('C', 'Contacted', 'Contacted via Messenger after being found or spotted'),
('D', 'Derived', 'Derived from other sources (e.g. old WCA statistics)'),
('F', 'Found', 'Found DOB or YOB on Speedsolving.com, Facebook, etc'),
('H', 'Historic', 'Historical sources (e.g. old age statistics or WCA records)'),
('P', 'Provided', 'Provided DOB in person, via a friend, Speedsolving.com, Facebook, etc'),
('S', 'Spotted', 'Spotted profile on Facebook, WCA website, etc');

DROP TABLE IF EXISTS wca_ipy.SeniorAccuracies;

CREATE TABLE wca_ipy.SeniorAccuracies
(
     `id` char(1) COLLATE utf8mb4_unicode_ci NOT NULL,
     `type` varchar(10) COLLATE utf8mb4_unicode_ci,
     `comment` text COLLATE utf8mb4_unicode_ci NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO wca_ipy.SeniorAccuracies VALUES
('D', 'Day', 'Precise DOB'),
('F', 'Fake', 'Fake DOB to exclude earlier competitions'),
('M', 'Month', 'Month of birth - e.g. 1972-07-31 for July 1972'),
('S', 'Synthetic', 'Synthetic DOB based on competition date'),
('U', 'Unknown', 'DOB is unknown but known to be over 40'),
('X', 'Approx', 'Approximate DOB based on age being stated / provided'),
('Y', 'Year', 'Year of birth - e.g. 1972-12-31 for 1972');
