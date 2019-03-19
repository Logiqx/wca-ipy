/* 
    Script:   Extract Over 40's Results
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Unofficial rankings for the Over-40's - https://github.com/Logiqx/wca-ipy.
*/

-- Extract seniors
SELECT p.id AS personId, p.name AS personName, c.name AS country, IFNULL(p.username, '?') AS username
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/known_senior_details.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM Persons AS p
INNER JOIN Countries AS c ON p.countryId = c.id
WHERE p.subid = 1
AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
ORDER BY personName;

-- Extract senior results (averages)
SELECT eventId, personId, MIN(average) AS best_average
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/known_senior_averages.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, p.username,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE average > 0
  HAVING age_at_comp >= 40
) AS tmp_results
GROUP BY eventId, personId
ORDER BY eventId, best_average, personId;

-- Extract senior results (singles)
SELECT eventId, personId, MIN(best) AS best_single
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/known_senior_singles.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.best, p.name AS personName, p.countryId, p.username,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE best > 0
  HAVING age_at_comp >= 40
) AS tmp_results
GROUP BY eventId, personId
ORDER BY eventId, best_single, personId;
