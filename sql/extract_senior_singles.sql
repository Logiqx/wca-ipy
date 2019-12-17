/* 
    Script:   Extract senior singles
    Created:  2019-06-19
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract senior singles for processing in Python
*/

-- Extract known senior singles
SELECT 'known_senior_singles', eventId, personId, MIN(best) AS bestSingle, ageCategory
FROM
(
  SELECT r.eventId, r.personId, r.best, s.name AS personName, s.countryId,
    FLOOR(TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
  FROM wca.Results AS r
  INNER JOIN wca.Competitions AS c ON r.competitionId = c.id
  INNER JOIN Seniors AS s ON s.personId = r.personId AND YEAR(dob) <= YEAR(CURDATE()) - 40 AND hidden = 'n'
  WHERE best > 0
  HAVING ageCategory >= 40
) AS tmp_results
GROUP BY eventId, personId, ageCategory
ORDER BY eventId, bestSingle, personName;
