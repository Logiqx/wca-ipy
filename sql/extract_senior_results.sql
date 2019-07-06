/* 
    Script:   Extract Senior Results
    Created:  2019-07-06
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Private extract to facilitate the production of "Indicative Senior Rankings"
              https://logiqx.github.io/wca-ipy/Indicative_Rankings.html

    Notes:    This extract will never be shared publicly
*/

SELECT eventId, personId, FLOOR(age_at_comp / 10) * 10 AS age_category,
  MIN(best) AS best_single, MIN(IF(average > 0, average, NULL)) AS best_average
FROM
(
  SELECT r.eventId, r.personId, r.best, r.average,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
      DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
  WHERE best > 0
  HAVING age_at_comp >= 40
) AS senior_results
GROUP BY eventId, personId, age_category;
