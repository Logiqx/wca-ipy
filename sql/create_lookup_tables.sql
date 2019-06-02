/* 
      Script:   Create lookup tables
      Created:  2019-06-02
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Small lookups
*/

DROP TABLE IF EXISTS SeniorSources;

CREATE TABLE SeniorSources
(
     `id` char(1) CHARACTER SET latin1 NOT NULL,
     `type` varchar(10) CHARACTER SET latin1,
     `comment` text CHARACTER SET latin1 NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO SeniorSources VALUES
('C', 'Contacted', 'Contacted via Messenger after being found or spotted'),
('D', 'Derived', 'Derived from other sources (e.g. old WCA statistics)'),
('F', 'Found', 'Found DOB or YOB on Speedsolving.com, Facebook, etc'),
('P', 'Provided', 'Provided DOB in person, via a friend, Speedsolving.com, Facebook, etc'),
('S', 'Spotted', 'Spotted profile on Facebook, WCA website, etc');

DROP TABLE IF EXISTS SeniorAccuracies;

CREATE TABLE SeniorAccuracies
(
     `id` char(1) CHARACTER SET latin1 NOT NULL,
     `type` varchar(10) CHARACTER SET latin1,
     `comment` text CHARACTER SET latin1 NOT NULL,
     PRIMARY KEY (`id`)
);

INSERT INTO SeniorAccuracies VALUES
('D', 'Day', 'Precise DOB'),
('F', 'Fake', 'Fake DOB to exclude earlier competitions'),
('M', 'Month', 'Month of birth - e.g. 1972-07-31 for July 1972'),
('S', 'Synthetic', 'Synthetic DOB based on competition date'),
('U', 'Unknown', 'DOB is unknown but known to be over 40'),
('X', 'Approx', 'Approximate DOB based on age being stated / provided'),
('Y', 'Year', 'Year of birth - e.g. 1972-12-31 for 1972');
