/*
    Script:   Extract Events
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract Events table
*/

SELECT id, name, format
FROM wca.Events AS e
WHERE e.rank < 900
ORDER BY e.rank;
