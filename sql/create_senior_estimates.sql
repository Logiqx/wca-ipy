/*
    Script:   Create Senior Counts
    Created:  2019-12-16
    Author:   Michael George / 2015GEOR02

    Purpose:  Estimate the number of seniors using WCA growth rates and prior knowledge of senior counts
*/

DROP TABLE IF EXISTS SeniorEstimates;

-- Start by calculating estimates
CREATE TABLE SeniorEstimates AS
SELECT rs.eventId, src.ageCategory,
    FLOOR(src.numSingles * rs.numSingles / wrc.numSingles * rs.numSingles / wrc.numSingles) AS estSingles,
    IFNULL(FLOOR(src.numAverages * ra.numAverages / wrc.numAverages * ra.numAverages / wrc.numAverages), 0) AS estAverages,
    src.numSingles AS prevSingles, src.numAverages AS prevAverages, FLOOR(DATEDIFF(CURDATE(), src.cutoffDate) / 7) AS numWeeks
FROM (SELECT eventId, COUNT(DISTINCT personId) AS numSingles FROM wca.RanksSingle GROUP BY eventId) AS rs
LEFT JOIN (SELECT eventId, COUNT(DISTINCT personId) AS numAverages FROM wca.RanksAverage GROUP BY eventId) AS ra ON rs.eventId = ra.eventId
JOIN WcaResultCounts AS wrc ON wrc.eventId = rs.eventId AND wrc.cutoffDate = '2019-12-20'
JOIN SeniorResultCounts AS src ON src.eventId = rs.eventId AND src.cutoffDate = wrc.cutoffDate;

-- Increase estimates where more seniors are already known
UPDATE SeniorEstimates AS e
JOIN
(
    SELECT eventId, age_category, COUNT(DISTINCT personId) AS num_singles, COUNT(DISTINCT IF(average > 0, personId, NULL)) AS num_averages
    FROM
    (
      SELECT r.personId, r.eventId, r.average, TIMESTAMPDIFF(YEAR, dob,
          DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
      FROM Seniors AS s
      JOIN wca.Results AS r ON r.personId = s.personId AND best > 0
      JOIN wca.Competitions AS c ON c.id = r.competitionId
      HAVING age_at_comp >= 40
    ) AS t
    JOIN (SELECT 40 AS age_category UNION ALL SELECT 50 UNION ALL SELECT 60 UNION ALL SELECT 70 UNION ALL SELECT 80 UNION ALL SELECT 90 UNION ALL SELECT 100) AS a ON age_category <= age_at_comp
    GROUP BY eventId, age_category
    ORDER BY eventId, age_category
) AS t ON t.eventId = e.eventId AND t.age_category = e.ageCategory
SET e.estSingles = IF(estSingles > num_singles, estSingles, num_singles),
    e.estAverages = IF(estAverages > num_averages, estAverages, num_averages);
