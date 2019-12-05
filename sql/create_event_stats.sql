/* 
    Script:   Create event stats
    Created:  2019-06-19
    Author:   Michael George / 2015GEOR02

    Purpose:  Count the number of competitors for each event at the time of the one-off extract
*/

-- This takes a while to run since it processes most of the results table!

SET @cutoff = '2019-02-01';

DROP TABLE IF EXISTS EventStats;

CREATE TABLE EventStats AS
SELECT eventId, COUNT(DISTINCT personId) AS numPersons
FROM wca.Results AS r
JOIN wca.Competitions AS c ON r.competitionId = c.id AND DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') < @cutoff
WHERE average > 0
GROUP BY eventId;

ALTER TABLE EventStats ADD PRIMARY KEY (eventId);
