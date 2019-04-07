/* 
    Script:   Over 40's Participation
    Created:  2019-04-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Provide a comprehensive view of the Over-40's participation in competition.
*/

-- Senior competitors with official averages

SELECT eventId, COUNT(*) AS num_averages
FROM
(
  SELECT DISTINCT eventId, personId
  FROM
  (
    SELECT r.eventId, r.personId,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
) AS tmp_persons
GROUP BY eventId
ORDER BY num_averages DESC;

-- Senior competitors with official singles

SELECT eventId, COUNT(*) AS num_singles
FROM
(   
  SELECT DISTINCT eventId, personId
  FROM
  (
    SELECT r.eventId, r.personId,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE best > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
) AS tmp_persons
GROUP BY eventId
ORDER BY num_singles DESC;
