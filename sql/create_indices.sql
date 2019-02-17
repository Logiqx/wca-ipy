/* 
    Script:   Apply Indices
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply basic indices to the main tables for improved query performance
*/

-- Create indices
CREATE INDEX Person_id ON Persons (id);
CREATE INDEX Results_personId ON Results (personId);
CREATE INDEX RanksAverage_personId ON RanksAverage (personId);
CREATE INDEX RanksSingle_personId ON RanksSingle (personId);
CREATE UNIQUE INDEX Competitions_id ON Competitions (id);

-- Update statistics
ANALYZE TABLE Persons;
ANALYZE TABLE Results;
ANALYZE TABLE RanksAverage;
ANALYZE TABLE RanksSingle;
ANALYZE TABLE Competitions;
