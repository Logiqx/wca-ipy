/* 
    Script:   Extract senior averages
    Created:  2019-06-19
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract senior averages for processing in Python
*/

-- Extract known senior averages
SELECT 'known_senior_averages', eventId, personId, MIN(average) AS bestAverage, ageCategory
FROM
(
  SELECT r.eventId, r.personId, r.average, s.name AS personName, s.countryId,
    FLOOR(TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageCategory
  FROM wca.Results AS r
  INNER JOIN wca.Competitions AS c ON c.id = r.competitionId
  INNER JOIN Seniors AS s ON s.personId = r.personId AND YEAR(dob) <= YEAR(CURDATE()) - 40 AND hidden = 'n'
  WHERE average > 0
  HAVING ageCategory >= 40
) AS t
GROUP BY eventId, personId, ageCategory
ORDER BY eventId, bestAverage, personName, ageCategory DESC;

-- Extract indicative senior averages
SELECT 'senior_averages', eventId, rankNo, r.personId, best_average, age_at_comp
FROM
(
  SELECT eventId, RANK() OVER (PARTITION BY eventId ORDER BY best_average) AS rankNo, personId, hidden, best_average, age_at_comp
  FROM
  (
    SELECT p1.eventId, p1.personId, p1.hidden, p1.best_average, MAX(age_at_comp) AS age_at_comp
    FROM SeniorAveragePrs p1
    JOIN
    (
      -- Overall PR
      SELECT eventId, personId, MIN(best_average) AS best_average
      FROM SeniorAveragePrs AS p
      GROUP BY eventId, personId
    ) p2 ON p2.eventId = p1.eventId AND p2.personId = p1.personId AND p2.best_average = p1.best_average
    GROUP BY eventId, personId
  ) tmp_prs
) AS r
INNER JOIN Seniors AS s ON s.personId = r.personId
WHERE r.hidden = 'n'
ORDER BY eventId, rankNo, name;

-- Extract indicative senior averages (aggregated)
SELECT 'senior_averages_agg', a.*
FROM SeniorAverages AS a
ORDER BY eventId, result;
