/* 
    Script:   Create senior singles
    Created:  2019-06-19
    Author:   Michael George / 2015GEOR02

    Purpose:  Determine how many seniors are likely to have achieved specific results using basic modelling and sampling
*/

/* 
   Create aggregation of known singles using the very latest results
*/

DROP TABLE IF EXISTS KnownSinglesLatest;

CREATE TABLE KnownSinglesLatest AS
SELECT eventId,
  (
    CASE
      -- Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
      WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best_single / 10000000)
      -- Leave FMC "single" as a move count - i.e. best
      WHEN eventId IN ('333fm') THEN best_single
      -- Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
      ELSE FLOOR(best_single / 100)
    END
  ) AS result, COUNT(*) AS numSeniors
FROM
(   
  SELECT eventId, personId, MIN(best) AS best_single
  FROM
  (
    SELECT r.eventId, r.personId, r.best,
      TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM wca.Results AS r
    INNER JOIN wca.Competitions AS c ON r.competitionId = c.id
    INNER JOIN Seniors AS s ON s.personId = r.personId AND YEAR(dob) <= YEAR(CURDATE()) - 40 AND hidden = 'N'
    WHERE best > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, result
ORDER BY eventId, result;

ALTER TABLE KnownSinglesLatest ADD PRIMARY KEY(eventId, result);
