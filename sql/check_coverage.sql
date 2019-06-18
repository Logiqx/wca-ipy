/* 
    Script:   Check Coverage
    Created:  2019-05-20
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Check how many seniors have been identified by country
*/

-- Countries with the most known oldies - UK + USA
WITH cte1 AS
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM wca_ipy.Seniors s
	JOIN wca.Persons p ON p.id = s.personId AND p.subid = 1
	GROUP BY p.countryId
)
SELECT countryId, numPersons, ROUND(100.0 * numPersons / SUM(numPersons) OVER(), 2) AS pctOverall
FROM cte1
ORDER BY numPersons DESC;

-- Countries with the greatest number of oldies as a percentage of the population - UK + Netherlands
WITH cte1 AS
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM wca_ipy.Seniors s
	JOIN wca.Persons p ON p.id = s.personId AND p.subid = 1
	GROUP BY p.countryId
),
cte2 AS
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM wca.Persons p
    WHERE p.subid = 1
	GROUP BY p.countryId
)
SELECT cte1.countryId, cte1.numPersons AS numSeniorsCountry, cte2.numPersons AS numPersonsCountry, ROUND(100.0 * cte1.numPersons / cte2.numPersons, 2) AS pctSeniors
FROM cte1
JOIN cte2 ON cte2.countryId = cte1.countryId
ORDER BY pctSeniors DESC;
