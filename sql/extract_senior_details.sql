/* 
    Script:   Extract Over 40's Results
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Unofficial rankings for the Over-40's - https://github.com/Logiqx/wca-ipy.
*/

-- Extract seniors
SELECT DISTINCT t.personId, personName, c.name AS country, IFNULL(s.username, '?') AS username, ageCategory
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/public/extract/known_senior_details.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS PersonName, p.countryId,
    FLOOR(IF(p.year = 1900, 40, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d"))) / 10) * 10 AS ageCategory
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  HAVING ageCategory >= 40
) AS t
INNER JOIN Seniors AS s ON s.personId = t.personId
INNER JOIN Countries AS c ON c.id = t.countryId
ORDER BY personName, ageCategory;

-- Extract senior results (averages)
SELECT eventId, personId, MIN(average) AS bestAverage, ageCategory
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/public/extract/known_senior_averages.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId,
    FLOOR(IF(p.year = 1900, 40, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d"))) / 10) * 10 AS ageCategory
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE average > 0
  HAVING ageCategory >= 40
) AS t
GROUP BY eventId, personId, ageCategory DESC
ORDER BY eventId, bestAverage, personId;

-- Extract senior results (singles)
SELECT eventId, personId, MIN(best) AS bestSingle, ageCategory
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/public/extract/known_senior_singles.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.best, p.name AS personName, p.countryId,
    FLOOR(IF(p.year = 1900, 40, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d"))) / 10) * 10 AS ageCategory
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE best > 0
  HAVING ageCategory >= 40
) AS tmp_results
GROUP BY eventId, personId, ageCategory DESC
ORDER BY eventId, bestSingle, personId;
