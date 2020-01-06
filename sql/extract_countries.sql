/*
    Script:   Extract Countries
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract Countries table
*/

SELECT c.iso2 AS id, c.name, cc.cc AS continentId
FROM wca.Countries AS c
JOIN ContinentCodes AS cc ON cc.id = c.continentId
ORDER BY name;
