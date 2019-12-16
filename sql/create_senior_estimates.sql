/*
    Script:   Create Senior Counts
    Created:  2019-12-16
    Author:   Michael George / 2015GEOR02

    Purpose:  Estimate the number of seniors using WCA growth rates and prior knowledge of senior counts
*/

DROP TABLE IF EXISTS SeniorEstimates;

CREATE TABLE SeniorEstimates AS
SELECT rs.eventId, s1. ageCategory,
    FLOOR(s1.numSingles * rs.numSingles / w1.numSingles * IF(s2.numAverages, (s1.numAverages / s2.numAverages) / (w1.numAverages / w2.numAverages), 1)) AS estSingles, -- tmp
    IFNULL(FLOOR(s1.numAverages * ra.numAverages / w1.numAverages * IF(s2.numAverages, (s1.numAverages / s2.numAverages) / (w1.numAverages / w2.numAverages), 1)), 0) AS estAverages,
    s1.numSingles AS prevSingles, s1.numAverages AS prevAverages, FLOOR(DATEDIFF(CURDATE(), s1.cutoffDate) / 7) AS numWeeks
FROM (SELECT eventId, COUNT(DISTINCT personId) AS numSingles FROM wca.RanksSingle GROUP BY eventId) AS rs
LEFT JOIN (SELECT eventId, COUNT(DISTINCT personId) AS numAverages FROM wca.RanksAverage GROUP BY eventId) AS ra ON rs.eventId = ra.eventId
JOIN wca_ipy.WcaResultCounts w1 ON w1.eventId = rs.eventId AND w1.cutoffDate = '2019-08-10'
JOIN wca_ipy.WcaResultCounts w2 ON w2.eventId = rs.eventId AND w2.cutoffDate = '2019-02-01'
JOIN wca_ipy.SeniorResultCounts s1 ON s1.eventId = rs.eventId AND s1.cutoffDate = w1.cutoffDate
LEFT JOIN wca_ipy.SeniorResultCounts s2 ON s2.eventId = rs.eventId AND s2.cutoffDate = w2.cutoffDate AND s2.ageCategory = s1.ageCategory;
