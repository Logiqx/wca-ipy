/* 
    Script:   Check Coverage
    Created:  2019-05-20
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Check how many seniors have been identified by country
*/

-- Countries with the most known oldies - UK + USA
WITH cte1 AS
(
	SELECT countryId, COUNT(*) AS numSeniors
	FROM wca_ipy.Seniors
	GROUP BY countryId
)
SELECT countryId, numSeniors, ROUND(100.0 * numSeniors / SUM(numSeniors) OVER(), 2) AS pctOverall
FROM cte1
ORDER BY numSeniors DESC;

-- Countries with the greatest number of oldies as a percentage of the population - UK + Netherlands
WITH cte1 AS
(
	SELECT countryId, COUNT(*) AS numSeniors
	FROM wca_ipy.Seniors
	GROUP BY countryId
),
cte2 AS
(
	SELECT p.countryId, COUNT(*) AS numPersons
	FROM Persons p
    WHERE p.subid = 1
	GROUP BY p.countryId
)
SELECT cte1.countryId, numSeniors, numPersons, ROUND(100.0 * numSeniors / numPersons, 2) AS pctSeniors
FROM cte1
JOIN cte2 ON cte2.countryId = cte1.countryId
ORDER BY pctSeniors DESC;
