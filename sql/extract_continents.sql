/*
    Script:   Extract Continents
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract Continents table
*/

SELECT cc.cc AS id, c.name
FROM wca.Continents AS c
JOIN ContinentCodes AS cc ON cc.id = c.id
ORDER BY name;
