/* 
    Script:   Extract Future Comps
    Created:  2019-07-30
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract list of future competitions
*/

SELECT c.id, c.name, c.cityName, c2.name AS country,
	DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') AS start_date,
    DATE_FORMAT(CONCAT(c.year + IF(endMonth < c.month, 1, 0), '-', c.endMonth, '-', c.endDay), '%Y-%m-%d') AS end_date
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/future_competitions.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM Competitions AS c
JOIN Countries AS c2 ON c2.id = c.countryId
HAVING end_date >= CURDATE()
ORDER BY start_date, end_date, name;
