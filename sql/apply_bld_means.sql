/* 
    Script:   Big BLD Means
    Created:  2019-05-01
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Calculate Mo3 for 4BLD and 5BLD
*/

UPDATE Results
SET average = ROUND((value1 + value2 + value3) / 3, 0)
WHERE eventId IN ('444bf','555bf')
AND value1 > 0 AND value2 > 0 AND value3 > 0;
