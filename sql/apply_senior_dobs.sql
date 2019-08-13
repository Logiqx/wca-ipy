/* 
    Script:   Apply Senior DOBs
    Created:  2019-07-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply senior DOBs to the persons table
*/

-- Start with default YMD of zero
UPDATE Persons AS p
SET p.year = 0,
    p.month = 0,
    p.day = 0;

-- Update DOB if known (or approximated)
UPDATE Persons AS p
INNER JOIN wca_ipy.Seniors AS s ON s.personId = p.id AND s.dob IS NOT NULL
SET p.year = DATE_FORMAT(s.dob, '%Y'),
    p.month = DATE_FORMAT(s.dob, '%m'),
    p.day = DATE_FORMAT(s.dob, '%d');
