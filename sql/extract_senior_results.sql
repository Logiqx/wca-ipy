/* 
    Script:   Extract Over 40s Results
    Created:  2019-02-15
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Private extract to facilitate the production of "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    These extracts will never be shared publicly
*/

-- Extract seniors
SELECT personId, personName, MAX(ageCategory) AS ageCategory
-- INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/known_senior_details.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS PersonName,
    FLOOR(TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
      DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  HAVING ageCategory >= 40
) AS t
GROUP BY personId
ORDER BY personName, personId;

-- Extract senior results (averages)
SELECT eventId, personId, MIN(average) AS bestAverage, ageCategory
-- INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/known_senior_averages.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName,
    FLOOR(TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
      DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE average > 0
  HAVING ageCategory >= 40
) AS t
GROUP BY eventId, personId, ageCategory
ORDER BY eventId, bestAverage, personId, ageCategory DESC;

-- Extract senior results (singles)
SELECT eventId, personId, MIN(best) AS bestSingle, ageCategory
-- INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/known_senior_singles.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT r.eventId, r.personId, r.best, p.name AS personName,
    FLOOR(TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
      DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE best > 0
  HAVING ageCategory >= 40
) AS tmp_results
GROUP BY eventId, personId, ageCategory
ORDER BY eventId, bestSingle, personId, ageCategory DESC;
