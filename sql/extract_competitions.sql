/*
    Script:   Extract Competitions
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract competitions table
*/

SELECT c.id, c.name, c.city_name, c2.iso2 AS country, IFNULL(c.external_website, '') AS external_website, start_date, end_date
FROM wca.competitions AS c
JOIN wca.countries AS c2 ON c2.id = c.country_id
ORDER BY start_date, end_date, name;
