/*
    Script:   Extract Countries
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract countries table
*/

SELECT c.iso2 AS id, c.name, cc.cc AS continent_id
FROM wca.countries AS c
JOIN continent_codes AS cc ON cc.id = c.continent_id
ORDER BY name;
