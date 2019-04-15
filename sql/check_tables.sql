/* 
    Script:   Check Tables
    Created:  2019-04-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Check table sizes
*/

SELECT sum(data_length / 1024 / 1024) AS data_length_mb
FROM information_schema.tables AS t
WHERE table_schema='wca'
ORDER BY data_length desc;

SELECT table_name, data_length / 1024 / 1024 AS data_length_mb
FROM information_schema.tables AS t
WHERE table_schema='wca'
ORDER BY data_length desc;

