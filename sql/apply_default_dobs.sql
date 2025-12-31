/* 
    Script:   Apply default DOBs
    Created:  2020-01-25
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply default DOB to everyone in the WCA database (public export) for testing purposes
*/

USE wca;

SET SQL_SAFE_UPDATES = 0;

-- Reset to WCA defaults
UPDATE persons
SET dob = '1954-12-04';
