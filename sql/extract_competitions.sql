/*
    Script:   Extract Competitions
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract Competitions table
*/

SELECT c.id, c.name, c.cityName, c2.iso2 AS country, IFNULL(c.external_website, '') AS external_website,
    DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') AS start_date,
    DATE_FORMAT(CONCAT(c.year + IF(endMonth < c.month, 1, 0), '-', c.endMonth, '-', c.endDay), '%Y-%m-%d') AS end_date
FROM wca.Competitions AS c
JOIN wca.Countries AS c2 ON c2.id = c.countryId
ORDER BY start_date, end_date, name;
