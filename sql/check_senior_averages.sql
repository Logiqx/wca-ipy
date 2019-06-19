/* 
    Script:   Check senior averages
    Created:  2019-06-19
    Author:   Michael George / 2015GEOR02

    Purpose:  Check for data integrity issues relating to senior averages
*/

-- Review the effectiveness of upsampling
SELECT s.eventId, numSeniorsModel, SUM(numSeniors) AS numSeniorsActual, SUM(numSeniors) - numSeniorsModel AS diff
FROM wca_ipy.SeniorAverages s
JOIN wca_ipy.EventModels AS e ON e.eventId = s.eventId
GROUP BY eventId
HAVING diff != 0;

-- Difference of less than zero indicates a bug in the code
SELECT a.eventId, a.result, a.numSeniors - IFNULL(k.numSeniors, 0) AS diff
FROM wca_ipy.SeniorAverages a
LEFT JOIN wca_ipy.KnownAveragesLatest k ON k.eventId = a.eventId AND k.result = a.result
HAVING diff < 0;

-- Difference of less than zero indicates non-seniors are present in the "Seniors" table
SELECT a.eventId, a.result, a.numSeniors - IFNULL(k.numSeniors, 0) AS diff
FROM wca_ipy.SeniorAveragesPrevious a
LEFT JOIN wca_ipy.KnownAveragesPrevious k ON k.eventId = a.eventId AND k.result = a.result
HAVING diff < 0;
