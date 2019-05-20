/* 
    Script:   Check Seniors
    Created:  2019-05-20
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Review seniors from a data quality perspective
*/

DROP VIEW IF EXISTS SeniorDetails;

CREATE VIEW SeniorDetails AS
WITH SeniorResults AS
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
)
SELECT s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"),
		DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM SeniorResults r
JOIN Seniors s ON s.personId = r.personId
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List everyone
SELECT 'Everyone' AS label, s.*
FROM SeniorDetails AS s
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List the Over-50's
SELECT 'Over-50' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 50
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List the Over-60's
SELECT 'Over-60' AS label, s.*
FROM SeniorDetails AS s
WHERE ageLastComp >= 60
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List the delegates appearing in the senior rankings
SELECT 'Delegate' AS label, delegate_status, s.*
FROM SeniorDetails AS s
JOIN wca_dev.users u ON u.wca_id = s.personId AND delegate_status IS NOT NULL
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List the possible "embassadors" for the senior rankings
WITH cte AS
(
	SELECT p.id, p.name, p.countryId, s.username, s.dob, s.accuracy, s.comment, c.year, COUNT(DISTINCT competitionId) AS numComps,
      IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
	FROM Seniors s
	JOIN Persons p ON p.id = s.personId AND p.subid = 1
	JOIN Results r ON r.personId = p.id
	JOIN Competitions c ON c.id = r.competitionId
	WHERE c.year >= 2017
	GROUP BY p.id, p.name, p.countryId, s.dob, s.username, c.year, s.comment
	HAVING COUNT(DISTINCT competitionId) >= 2
)
SELECT 'Embassador',  p.id, p.name, p.countryId,
	MAX(c19.age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, c19.dob, DATE_FORMAT(CONCAT(LEFT(c19.id, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, c19.dob, NOW()) AS ageToday,
	c19.numComps as numComps2019, IFNULL(c18.numComps, 0) AS numComps2018, IFNULL(c17.numComps, 0) AS numComps2017,
	s.username, s.comment
FROM Seniors s
JOIN Persons p ON id = personId AND subid = 1
LEFT JOIN cte c19 ON c19.id = s.personId and c19.year = 2019
LEFT JOIN cte c18 ON c18.id = s.personId and c18.year = 2018
LEFT JOIN cte c17 ON c17.id = s.personId and c17.year = 2017
WHERE c18.numComps >= 8
GROUP BY s.personId
ORDER BY p.countryId;

-- List people who pro-actively provided their information (or someone did so on their behalf)
SELECT LEFT(comment, LOCATE(" ", comment) - 1) AS label, s.*
FROM SeniorDetails AS s
WHERE comment LIKE 'Provided%'
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List people contacted via Facebook
SELECT LEFT(comment, LOCATE(" ", comment) - 1) AS label, s.*
FROM SeniorDetails AS s
WHERE comment LIKE 'Contacted%'
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List people where DOB / YOB was found on the internet - Facebook, Wikipedia, Speedsolving, etc
SELECT LEFT(comment, LOCATE(" ", comment) - 1) AS label, s.*
FROM SeniorDetails AS s
WHERE comment LIKE 'Found%'
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List people spotted on the internet - Facebook, WCA, Speedsolving, etc
SELECT LEFT(comment, LOCATE(" ", comment) - 1) AS label, s.*
FROM SeniorDetails AS s
WHERE comment LIKE 'Spotted%'
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- List speculative additions - friends of friends, etc.
SELECT LEFT(comment, LOCATE(" ", comment) - 1) AS label, s.*
FROM SeniorDetails AS s
WHERE comment LIKE 'Speculative%'
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- Check for non-standard comments
SELECT 'Non-standard', personId, name, countryId, accuracy, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment NOT LIKE 'Provided%' AND comment NOT LIKE 'Contacted%' AND comment NOT LIKE 'Found%' AND comment NOT LIKE 'Spotted%' AND comment NOT LIKE 'Speculative%';

-- Summarise the accuracy of DOB information
SELECT accuracy, COUNT(*)
FROM Seniors
GROUP BY accuracy
ORDER BY COUNT(*) DESC;

-- Unknown DOB means the person is assumed over-40
SELECT 'Unknown DOB' AS label, s.*
FROM SeniorDetails AS s
WHERE dob IS NULL
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- Imprecise DOBs - Y = year, X = approximated year, F = faked
SELECT 'Imprecise DOB' AS label, s.*
FROM SeniorDetails AS s
WHERE accuracy NOT IN ('D', 'M', 'U') -- D = specific date, M = specific month, U = unknown (DOB is NULL)
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- Fake DOBs are typically used to exclude results prior to a certain date
SELECT 'Fake DOB' AS label, s.*
FROM SeniorDetails AS s
WHERE comment LIKE '%fake%'
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;
