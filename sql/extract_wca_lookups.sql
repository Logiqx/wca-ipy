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

SELECT 'wca_lookup_countries', id, name, continentId, iso2
FROM wca.Countries
ORDER BY id;

SELECT 'wca_lookup_continents', id, name
FROM wca.Continents
ORDER BY id;
