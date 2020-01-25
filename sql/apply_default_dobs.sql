/* 
    Script:   Apply default DOBs
    Created:  2020-01-25
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply default DOB to everyone in the WCA database (public export) for testing purposes
*/

-- Reset to WCA defaults
UPDATE Persons
SET year = 1954,
    month = 12,
    day = 4;
