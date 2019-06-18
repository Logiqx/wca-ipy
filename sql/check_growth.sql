/* 
    Script:   Check growth of WCA community
    Created:  2019-06-18
    Author:   Michael George / 2015GEOR02

    Purpose:  Check how much the WCA community has increased since the extract on 2019-02-01
*/

-- WCA extract date will be used as a cutoff
SET @cutoff = '2019-02-01';

-- Feb counts
DROP TABLE IF EXISTS wca_ipy.EventAverages;
CREATE TABLE wca_ipy.EventAverages AS
SELECT eventId, COUNT(DISTINCT personId) AS numPersons
FROM Results AS r
INNER JOIN Competitions AS c ON r.competitionId = c.id AND DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') < @cutoff
WHERE average > 0
GROUP BY eventId;

-- Calculate ratios
DROP TABLE IF EXISTS wca_ipy.EventRatios;
CREATE TABLE wca_ipy.EventRatios AS
SELECT e1.eventId, IF(e1.eventId IN ('444bf', '555bf'), 1, e2.numPersons / e1.numPersons) AS ratio
FROM wca_ipy.EventAverages e1
JOIN
(
	-- Current results can jsut refer to the rankings for improved query speed
	SELECT eventId, COUNT(DISTINCT personId) AS numPersons
	FROM wca.RanksAverage
	GROUP BY eventId
) AS e2 ON e2.eventId = e1.eventId;

-- Add PK
ALTER TABLE wca_ipy.EventRatios ADD PRIMARY KEY (eventId);

-- Leave at 1.0 for now
UPDATE wca_ipy.EventRatios
SET ratio = 1;

-- Report overall
SELECT *
FROM wca_ipy.EventRatios
ORDER BY ratio DESC;
