/* 
    Script:   Check Coverage
    Created:  2019-05-20
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Check how many seniors have been identified by country
*/

-- Percentage coverage
SELECT a.eventId, a.result, numPersons, totPersons, numSeniors, totSeniors, numKnowns, totKnowns,
	ROUND(100 * totKnowns / totSeniors, 2) AS pctCoverage
FROM Events AS e
JOIN (
	SELECT eventId, result, numPersons, SUM(numPersons) OVER (PARTITION BY eventId ORDER BY result) AS totPersons
	FROM
	(
		SELECT eventId, FLOOR(best / 100) AS result, COUNT(*) AS numPersons
		FROM RanksAverage
		GROUP BY eventId, result
	) AS r
) AS a ON a.eventId = e.id
LEFT JOIN
(
	SELECT eventId, result, numSeniors, SUM(numSeniors) OVER (PARTITION BY eventId ORDER BY result) AS totSeniors
    FROM wca_ipy.SeniorAverages
) AS s ON s.eventId = a.eventId AND s.result = a.result
LEFT JOIN
(
	SELECT eventId, result, numSeniors AS numKnowns, SUM(numSeniors) OVER (PARTITION BY eventId ORDER BY result) AS totKnowns
	FROM
	(
		SELECT eventId, FLOOR(best_average / 100) AS result, COUNT(*) AS numSeniors
		FROM
		(
		  SELECT eventId, personId, MIN(average) AS best_average
		  FROM
		  (
			SELECT r.eventId, r.personId, r.average,
			  TIMESTAMPDIFF(YEAR, s.dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
			FROM Results AS r
			INNER JOIN Competitions AS c ON r.competitionId = c.id
			INNER JOIN wca_ipy.Seniors AS s ON s.personId = r.personId AND YEAR(dob) <= YEAR(CURDATE()) - 40 AND hidden = 'n'
			WHERE average > 0
			HAVING age_at_comp >= 40
		  ) AS tmp_results
		  GROUP BY eventId, personId
		) AS tmp_persons
		GROUP BY eventId, result
    ) AS tmp_aggs
) AS k ON k.eventId = a.eventId AND k.result = a.result
HAVING pctCoverage IS NOT NULL
ORDER BY e.rank, result;

-- Countries with the most known oldies - USA, Japan, Spain
SELECT countryId, numSeniors, ROUND(100.0 * numSeniors / SUM(numSeniors) OVER(), 2) AS pctOverall
FROM
(
	SELECT countryId, COUNT(*) AS numSeniors
	FROM wca_ipy.SeniorDetails
    WHERE ageLastComp >= 40
	GROUP BY countryId
) AS s
ORDER BY numSeniors DESC;

-- Countries with the greatest number of oldies as a percentage of the population - Netherlands + Japan
SELECT s.countryId, numSeniors, numPersons, ROUND(100.0 * numSeniors / numPersons, 2) AS pctSeniors
FROM
(
	SELECT countryId, COUNT(*) AS numSeniors
	FROM wca_ipy.SeniorDetails
    WHERE ageLastComp >= 40
	GROUP BY countryId
) AS s
JOIN
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM Persons p
    WHERE p.subid = 1
	GROUP BY p.countryId
) AS p ON p.countryId = s.countryId
ORDER BY pctSeniors DESC;
