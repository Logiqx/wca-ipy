/* 
    Script:   Extract WCA lookups
    Created:  2019-11-26
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract WCA lookup tables
*/

SELECT 'wca_lookup_events', id, name, format
FROM wca.Events
WHERE `rank` < 900
ORDER BY `rank`;

SELECT 'wca_lookup_countries', iso2 AS id, name, cc AS continentId
FROM wca.Countries AS c
JOIN ContinentCodes AS cc ON cc.id = c.continentId
ORDER BY name;

SELECT 'wca_lookup_continents', cc AS id, name
FROM wca.Continents AS c
JOIN ContinentCodes AS cc ON cc.id = c.id
ORDER BY name;
