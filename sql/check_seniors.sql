/*
    Counts relating to the number of senior cubers in each country
*/

-- Countries with the most known oldies - UK + USA
WITH cte1 AS
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM Seniors s
	JOIN Persons p ON p.id = s.personId AND p.subid = 1
	GROUP BY p.countryId
)
SELECT 'Seniors', countryId, numPersons, ROUND(100.0 * numPersons / SUM(numPersons) OVER(), 2) AS pctOverall
FROM cte1
ORDER BY numPersons DESC;

-- Countries with the greatest number of oldies as a percentage of the population - UK + Netherlands
WITH cte1 AS
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM Seniors s
	JOIN Persons p ON p.id = s.personId AND p.subid = 1
	GROUP BY p.countryId
),
cte2 AS
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM Persons p
    WHERE p.subid = 1
	GROUP BY p.countryId
)
SELECT  'Seniors', cte1.countryId, cte1.numPersons AS numSeniorsCountry, cte2.numPersons AS numPersonsCountry, ROUND(100.0 * cte1.numPersons / cte2.numPersons, 2) AS pctSeniors
FROM cte1
JOIN cte2 ON cte2.countryId = cte1.countryId
ORDER BY pctSeniors DESC;

/*
    Everyone
*/

SELECT DISTINCT 'Everyone', s.personId, personName, countryId, accuracy, dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

/*
    Over-50's
*/

SELECT DISTINCT 'Over-50', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 1900
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
-- WHERE accuracy NOT IN ('D', 'M')
GROUP BY s.personId
HAVING ageLastComp >= 50
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

/*
    Over-60's
*/

SELECT DISTINCT 'Over-60', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 1900
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
GROUP BY s.personId
HAVING ageLastComp >= 60
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

/*
    Precisions
*/

SELECT accuracy, COUNT(*)
FROM Seniors
WHERE accuracy IS NOT NULL
GROUP BY accuracy
ORDER BY COUNT(*) DESC;

/*
    Imprecise DOB
*/

SELECT DISTINCT 'Imprecise', s.personId, personName, countryId, accuracy, dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 1900
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
WHERE accuracy NOT IN ('D', 'M')
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

/*
    Unknown DOB
*/

SELECT DISTINCT 'Unknown', s.personId, personName, countryId, accuracy, dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), NOW()) - MAX(age_at_comp) + 1 AS yearsCompeting,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(LEFT(p.id, 4), "-01-01"), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year = 1900
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

/*
    Fake DOB
*/

SELECT DISTINCT 'Fake', s.personId, personName, countryId, accuracy, dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
WHERE comment LIKE '%fake%'
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

/*
    Delegates
*/

SELECT DISTINCT 'Delegate', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	delegate_status, username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
JOIN wca_dev.users u ON u.wca_id = s.personId AND delegate_status IS NOT NULL
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

/*
    Possible embassadors
*/

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

/*
    Review comments
*/

-- Check for non-standard comments
SELECT 'Non-standard', personId, name, countryId, accuracy, dob,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment NOT LIKE 'Provided%' AND comment NOT LIKE 'Contacted%' AND comment NOT LIKE 'Found%' AND comment NOT LIKE 'Spotted%' AND comment NOT LIKE 'Speculative%';

-- "Provided" indicates that the person (or someone on their behalf) pro-actively provided their information
SELECT DISTINCT 'Provided', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
WHERE comment LIKE 'Provided%'
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- People contacted on Facebook
SELECT DISTINCT 'Contacted', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
WHERE comment LIKE 'Contacted%'
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- DOB / YOB that I found on the internet - Facebook, Wikipedia, Speedsolving, etc
SELECT DISTINCT 'Found', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
WHERE comment LIKE 'Found%'
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- People that I spotted on the internet - Facebook, Speedsolving, etc
SELECT DISTINCT 'Spotted', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
WHERE comment LIKE 'Spotted%'
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;

-- Speculative additions - friends of friends, etc.
SELECT DISTINCT 'Speculative', s.personId, personName, countryId, accuracy, s.dob,
	MAX(compYear) AS lastComp, COUNT(DISTINCT compId) as numComps,
	TIMESTAMPDIFF(YEAR, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d"), DATE_FORMAT(CONCAT(MAX(compYear), "-01-01"), "%Y-%m-%d")) + 1 AS yearsCompeting,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId, c.id as compId, c.year AS compYear,
    IF(p.year > 1900, TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")), NULL) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
WHERE comment LIKE 'Speculative%'
GROUP BY s.personId
ORDER BY lastComp DESC, numComps DESC, yearsCompeting DESC;
