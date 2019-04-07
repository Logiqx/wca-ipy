/* 
    Script:   Apply Indices
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply indices to the main tables for improved query performance
*/

-- Add primary keys
ALTER TABLE championships ADD PRIMARY KEY(id);
ALTER TABLE Countries ADD PRIMARY KEY(id);
ALTER TABLE Competitions ADD PRIMARY KEY(id);
ALTER TABLE Persons ADD PRIMARY KEY(id, subid);

-- Create unique indices
CREATE UNIQUE INDEX RanksAverage_eventId_personId ON RanksAverage (eventId, personId);
CREATE UNIQUE INDEX RanksAverage_personId_eventId ON RanksAverage (personId, eventId);
CREATE UNIQUE INDEX RanksSingle_eventId_personId ON RanksSingle (eventId, personId);
CREATE UNIQUE INDEX RanksSingle_personId_eventId ON RanksSingle (personId, eventId);

-- Create non-unique indices
CREATE INDEX Results_eventId_personId ON Results (eventId, personId);
CREATE INDEX Results_personId_eventId ON Results (personId, eventId);
CREATE INDEX Scrambles_eventId ON Scrambles (eventId);

-- Update statistics
ANALYZE TABLE championships;
ANALYZE TABLE Countries;
ANALYZE TABLE Competitions;
ANALYZE TABLE Persons;
ANALYZE TABLE RanksAverage;
ANALYZE TABLE RanksSingle;
ANALYZE TABLE Results;
ANALYZE TABLE Scrambles;
