/*
    Script:   Extract Events
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract Events table
*/

SELECT id, name, `rank`, format
FROM wca.events AS e
WHERE `rank` < 900
ORDER BY `rank`;
