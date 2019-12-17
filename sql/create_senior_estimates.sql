/*
    Script:   Create Senior Counts
    Created:  2019-12-16
    Author:   Michael George / 2015GEOR02

    Purpose:  Estimate the number of seniors using WCA growth rates and prior knowledge of senior counts
*/

DROP TABLE IF EXISTS SeniorEstimates;

-- Start by calculating estimates
CREATE TABLE SeniorEstimates AS
SELECT rs.eventId, s1. ageCategory,
    FLOOR(s1.numSingles * rs.numSingles / w1.numSingles * IF(s2.numAverages, (s1.numAverages / s2.numAverages) / (w1.numAverages / w2.numAverages), 1)) AS estSingles, -- tmp
    IFNULL(FLOOR(s1.numAverages * ra.numAverages / w1.numAverages * IF(s2.numAverages, (s1.numAverages / s2.numAverages) / (w1.numAverages / w2.numAverages), 1)), 0) AS estAverages,
    s1.numSingles AS prevSingles, s1.numAverages AS prevAverages, FLOOR(DATEDIFF(CURDATE(), s1.cutoffDate) / 7) AS numWeeks
FROM (SELECT eventId, COUNT(DISTINCT personId) AS numSingles FROM wca.RanksSingle GROUP BY eventId) AS rs
LEFT JOIN (SELECT eventId, COUNT(DISTINCT personId) AS numAverages FROM wca.RanksAverage GROUP BY eventId) AS ra ON rs.eventId = ra.eventId
JOIN WcaResultCounts w1 ON w1.eventId = rs.eventId AND w1.cutoffDate = '2019-08-10'
JOIN WcaResultCounts w2 ON w2.eventId = rs.eventId AND w2.cutoffDate = '2019-02-01'
JOIN SeniorResultCounts s1 ON s1.eventId = rs.eventId AND s1.cutoffDate = w1.cutoffDate
LEFT JOIN SeniorResultCounts s2 ON s2.eventId = rs.eventId AND s2.cutoffDate = w2.cutoffDate AND s2.ageCategory = s1.ageCategory;

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
