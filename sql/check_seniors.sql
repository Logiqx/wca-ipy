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

-- Copy / paste of code in extract_senior_details.sql
SELECT DISTINCT 'Over-40',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	s.personId, personName, countryId, s.dob, username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 1900 AND p.year <= YEAR(CURDATE()) - 40
  HAVING age_at_comp >= 40
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
GROUP BY s.personId
ORDER BY ageFirstComp DESC, DOB desc;

/*
    Over-50's
*/

-- Copy / paste of code in extract_senior_details.sql
SELECT DISTINCT 'Over-50',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	s.personId, personName, countryId, s.dob, username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 1900 AND p.year <= YEAR(CURDATE()) - 50
  HAVING age_at_comp >= 50
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
GROUP BY s.personId
ORDER BY ageFirstComp DESC, DOB desc;

/*
    Over-60's
*/

-- Copy / paste of code in extract_senior_details.sql
SELECT DISTINCT 'Over-60',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	MAX(age_at_comp) AS ageLastComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	s.personId, personName, countryId, s.dob, username, comment
FROM
(
  SELECT r.eventId, r.personId, r.average, p.name AS personName, p.countryId,
    TIMESTAMPDIFF(YEAR,
      DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
      DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
  FROM Results AS r
  INNER JOIN Competitions AS c ON r.competitionId = c.id
  INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 1900 AND p.year <= YEAR(CURDATE()) - 60
  HAVING age_at_comp >= 60
) AS tmp_results
JOIN Seniors s ON s.personId = tmp_results.personId
GROUP BY s.personId
ORDER BY ageFirstComp DESC, DOB desc;

/*
    Missing DOB
*/

-- All people without a DOB
SELECT 'Missing DOB', ROUND(MIN(average) / 100.0, 2) AS best333,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons p ON id = personId AND subid = 1
JOIN Results AS r ON r.personId = p.id AND r.eventId = '333' AND r.average > 0
WHERE dob IS NULL
GROUP BY id
ORDER BY comment, countryId;

/*
    Delegates
*/

SELECT DISTINCT 'Delegate',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	delegate_status, p.id, p.name, p.countryId, s.username, s.dob, s.comment
FROM Seniors s
JOIN Persons p ON p.id = s.personId AND p.subid = 1
JOIN Results r ON r.personId = p.id
JOIN Competitions c ON c.id = r.competitionId AND c.year >= YEAR(CURDATE()) - 1
JOIN wca_dev.users u ON u.wca_id = s.personId AND delegate_status IS NOT NULL
ORDER BY delegate_status, countryId, id;

/*
    Possible embassadors
*/

WITH cte AS
(
	SELECT p.id, p.name, p.countryId, s.username, s.dob, s.comment, c.year, COUNT(DISTINCT competitionId) AS numComps
	FROM Seniors s
	JOIN Persons p ON p.id = s.personId AND p.subid = 1
	JOIN Results r ON r.personId = p.id
	JOIN Competitions c ON c.id = r.competitionId
	WHERE c.year >= 2017
	GROUP BY p.id, p.name, p.countryId, s.dob, s.username, c.year, s.comment
	HAVING COUNT(DISTINCT competitionId) >= 2
	ORDER BY p.countryId, c.year DESC, COUNT(DISTINCT competitionId) DESC
)
SELECT 'Embassador?',
	TIMESTAMPDIFF(YEAR, c19.dob, DATE_FORMAT(CONCAT(LEFT(c19.id, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, c19.dob, NOW()) AS ageToday,
	c19.id, c19.name, c19.countryId, c19.username, -- c19.dob, c19.comment,
	c19.numComps as numComps2019, IFNULL(c18.numComps, 0) AS numComps2018, IFNULL(c17.numComps, 0) AS numComps2017
FROM cte AS c19
LEFT JOIN cte c18 ON c18.id = c19.id and c18.year = 2018
LEFT JOIN cte c17 ON c17.id = c19.id and c17.year = 2017
WHERE c19.year = 2019;

/*
    Review comments
*/

-- Check for non-standard comments
SELECT 'Non-standard',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment NOT LIKE 'Provided%' AND comment NOT LIKE 'Contacted%' AND comment NOT LIKE 'First%'
AND comment NOT LIKE 'Found%' AND comment NOT LIKE 'Spotted%' AND comment NOT LIKE 'Speculative%';

-- "Provided" indicates that the person (or someone on their behalf) pro-actively provided their information
SELECT 'Provided #1',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment LIKE 'Provided%'
AND NOT (comment LIKE '%qqwref%' OR comment LIKE '%Ron van Bruchem%' OR comment LIKE '%Andy Nicholls%')
ORDER BY comment, countryId, personId;

	-- Some people have provided multiple names
	SELECT 'Provided #2',
		TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
		TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
		id, name, countryId, dob, username, comment
	FROM Seniors s
	JOIN Persons ON id = personId AND subid = 1
	WHERE comment LIKE 'Provided%'
	AND (comment LIKE '%qqwref%' OR comment LIKE '%Ron van Bruchem%' OR comment LIKE '%Andy Nicholls%')
	ORDER BY comment, countryId, personId;

-- People contacted on Facebook
SELECT 'Contacted',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment LIKE 'Contacted%'
ORDER BY comment, countryId, personId;

-- People I added after meeting them at a competition
SELECT 'First',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment LIKE 'First%'
ORDER BY comment, countryId, personId;

-- DOB / YOB that I found on the internet - Facebook, Wikipedia, Speedsolving, etc
SELECT 'Found',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment LIKE 'Found%'
ORDER BY comment, countryId, personId;

-- People that I spotted on the internet - Facebook, Speedsolving, etc
SELECT 'Spotted',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment LIKE 'Spotted%'
ORDER BY comment, countryId, personId;

-- Speculative additions - friends of friends, etc.
SELECT 'Speculative',
	TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(LEFT(s.personId, 4), "-01-01"), "%Y-%m-%d")) AS ageFirstComp,
	TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS ageToday,
	id, name, countryId, dob, username, comment
FROM Seniors s
JOIN Persons ON id = personId AND subid = 1
WHERE comment LIKE 'Speculative%'
ORDER BY countryId, comment, personId;
