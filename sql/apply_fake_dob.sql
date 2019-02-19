/* 
    Script:   Apply Fake DOBs to the "Persons" table
    Created:  2019-02-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply fake DOB to everyone in the WCA database (public export) for testing purposes
            
    Approach: Allocate a year between 1977 to 2011 to ensure that around 5% are over-40 
*/

-- Apply random DOB between 1977-01-01 and 2011-12-28
UPDATE Persons
SET year = FLOOR(1977 + RAND() * 35),
    month = FLOOR(1 + RAND() * 12),
    day = FLOOR(1 + RAND() * 28);

-- Check years
SELECT year, COUNT(*)
FROM Persons
GROUP BY year;
