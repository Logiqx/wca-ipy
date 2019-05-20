/* 
    Script:   Test Date of Birth
    Created:  2019-02-16
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Test the impact of DOB - e.g. 1st Jan vs 31st Dec
*/

SET @personId = '2015GEOR02';
SET @ageCategory = 50;

SET @year = '1967'; SET @earliest = DATE_FORMAT(CONCAT(@year, "-01-01"), "%Y-%m-%d"); SET @latest = DATE_ADD(DATE_ADD(@earliest, INTERVAL 1 YEAR), INTERVAL -1 DAY);

-- SET @month = '1968-10'; SET @earliest = DATE_FORMAT(CONCAT(@month, "-01"), "%Y-%m-%d"); SET @latest = DATE_ADD(DATE_ADD(@earliest, INTERVAL 1 MONTH), INTERVAL -1 DAY);

SELECT e.id, e.name,
    earliest.best_single AS earliest_single, latest.best_single AS latest_single,
    latest.best_single - earliest.best_single AS diff_single,
    earliest.best_average AS earliest_average, latest.best_average AS latest_average,
    latest.best_average - earliest.best_average AS diff_average
FROM Events AS e
LEFT JOIN
(
  SELECT eventId, MIN(modified_best) AS best_single, MIN(modified_average) AS best_average
  FROM
  (
    SELECT r.eventId,
      (CASE WHEN r.average > 0 THEN r.average ELSE NULL END) AS modified_average,
      (CASE WHEN r.best > 0 THEN r.best ELSE NULL END) AS modified_best,
      TIMESTAMPDIFF(YEAR, DATE_FORMAT(@latest, "%Y-%m-%d"),
                    DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    WHERE personId = @personId
    HAVING age_at_comp >= @ageCategory
  ) AS tmp_results
  GROUP BY eventId
) AS latest ON e.id = latest.eventId
LEFT JOIN
(
  SELECT eventId, MIN(modified_best) AS best_single, MIN(modified_average) AS best_average
  FROM
  (
    SELECT r.eventId,
      (CASE WHEN r.average > 0 THEN r.average ELSE NULL END) AS modified_average,
      (CASE WHEN r.best > 0 THEN r.best ELSE NULL END) AS modified_best,
      TIMESTAMPDIFF(YEAR, DATE_FORMAT(@earliest, "%Y-%m-%d"),
                    DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    WHERE personId = @personId
    HAVING age_at_comp >= @ageCategory
  ) AS tmp_results
  GROUP BY eventId
) AS earliest ON e.id = earliest.eventId
WHERE earliest.best_single IS NOT NULL
ORDER by e.rank;
