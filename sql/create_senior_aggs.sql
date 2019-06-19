/* 
    Script:   Create aggregated results
    Created:  2019-06-18
    Author:   Michael George / 2015GEOR02

    Purpose:  Determine how many seniors are likely to have achieved specific results using basic modelling and sampling
*/

-- WCA extract date will be used as a cutoff
SET @cutoff = '2019-02-01';

/* 
   Load the one-off extract from the WCA, created 2019-02-01
*/

DROP TABLE IF EXISTS wca_ipy.SeniorAveragesPrevious;

CREATE TABLE wca_ipy.SeniorAveragesPrevious
(
  `eventId` varchar(6) CHARACTER SET latin1 NOT NULL,
  `result` int(11) NOT NULL,
  `numSeniors` smallint(6) NOT NULL,
   PRIMARY KEY (`eventId`, `result`)
);

LOAD DATA INFILE '/home/jovyan/work/wca-ipy/data/private/feed/senior_averages_agg.csv'
INTO TABLE wca_ipy.SeniorAveragesPrevious FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;

/* 
   Identify known averages relating to the one-off extract
*/

DROP TABLE IF EXISTS wca_ipy.KnownAveragesPrevious;

CREATE TABLE wca_ipy.KnownAveragesPrevious AS
SELECT eventId, FLOOR(best_average / 100) AS result, COUNT(*) AS numSeniors
FROM
(
  SELECT eventId, personId, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id AND DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d') < @cutoff
      -- Excluding these specific competitions is the equivalent of results_posted_at < @cutoff in the WCA developer database
      -- This was established using the WCA developer database which contains additional information about competitions
      AND competitionId NOT IN ('WardenoftheWest2019', 'HongKongCubeDay2019', 'InnerMongoliaWinter2019', 'MindGames2019', 'BursaWinter2019',
                                'CubodeBarro2019', 'KubkvarnaWinter2019', 'NorthStarCubingChallenge2019', 'TaipeiPeaceOpen2019')
    INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, result
ORDER BY eventId, result;

ALTER TABLE wca_ipy.KnownAveragesPrevious ADD PRIMARY KEY(eventId, result);

/* 
   Identify known averages using the very latest results
*/

DROP TABLE IF EXISTS wca_ipy.KnownAveragesLatest;

CREATE TABLE wca_ipy.KnownAveragesLatest AS
SELECT eventId, FLOOR(best_average / 100) AS result, COUNT(*) AS numSeniors
FROM
(
  SELECT eventId, personId, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, result
ORDER BY eventId, result;

ALTER TABLE wca_ipy.KnownAveragesLatest ADD PRIMARY KEY(eventId, result);

/* 
   Sanity Check - rows indicate non-seniors are present in the "Seniors" table
*/

SELECT a.eventId, a.result, a.numSeniors - IFNULL(k.numSeniors, 0) AS diff
FROM wca_ipy.SeniorAveragesPrevious a
LEFT JOIN wca_ipy.KnownAveragesPrevious k ON k.eventId = a.eventId AND k.result = a.result
HAVING diff < 0;

/* 
   Combine the unknown senior averages from 2019-02-01 with the latest known senior averages
*/

DROP TABLE IF EXISTS wca_ipy.SeniorAveragesLatest;

CREATE TABLE wca_ipy.SeniorAveragesLatest AS
SELECT t.eventId, result, SUM(numSeniors) AS numSeniors
FROM
(
  -- Previous senior averages, minus known averages
  SELECT a.eventId, a.result, a.numSeniors - IFNULL(k.numSeniors, 0) AS numSeniors
  FROM wca_ipy.SeniorAveragesPrevious a
  LEFT JOIN wca_ipy.KnownAveragesPrevious k ON k.eventId = a.eventId AND k.result = a.result
  HAVING numSeniors > 0
  UNION ALL
  -- Latest known average
  SELECT *
  FROM wca_ipy.KnownAveragesLatest
) AS t
GROUP BY eventId, result
ORDER BY eventId, result;

/*
   Create simple models for basic upsampling of senior results
*/

DROP TABLE IF EXISTS wca_ipy.EventModels;

CREATE TABLE wca_ipy.EventModels AS
SELECT *,
    IF(numSeniorsDelta > 0, CEIL((numSeniorsLatest + 1) / (numSeniorsDelta + 1)), NULL) AS sampleFrequency
FROM
(
  SELECT n1.eventId,
  	n1.numPersons AS numPersonsPrevious, n2.numPersons AS numPersonsLatest,
	n3.numSeniors AS numSeniorsPrevious, n4.numSeniors AS numSeniorsLatest,
	ROUND(n3.numSeniors * n2.numPersons / n1.numPersons) AS numSeniorsModel,
	ROUND(n3.numSeniors * n2.numPersons / n1.numPersons) - n4.numSeniors AS numSeniorsDelta
  -- Previous WCA averages were pre-calculated using the "Results" table
  FROM wca_ipy.EventStats n1
  JOIN
  (
  	-- Current WCA averages can uses the "Rankings" table for improved query speed
  	SELECT eventId, COUNT(*) AS numPersons
  	FROM wca.RanksAverage
  	GROUP BY eventId
  ) AS n2 ON n2.eventId = n1.eventId
  JOIN
  (
  	-- Previous seniors averages uses the pre-calculated aggregate table
  	SELECT eventId, SUM(numSeniors) AS numSeniors
  	FROM wca_ipy.SeniorAveragesPrevious
  	GROUP BY eventId
  ) AS n3 ON n3.eventId = n1.eventId
  JOIN
  (
  	-- Latest seniors averages uses the pre-calculated aggregate table
  	SELECT eventId, SUM(numSeniors) AS numSeniors
  	FROM wca_ipy.SeniorAveragesLatest
  	GROUP BY eventId
  ) AS n4 ON n4.eventId = n1.eventId
) AS t;
 
ALTER TABLE wca_ipy.EventModels ADD PRIMARY KEY (eventId);

/*
   Create senior results using basic upsampling
*/

DROP TABLE IF EXISTS wca_ipy.SeniorAverages;

CREATE TABLE wca_ipy.SeniorAverages AS
SELECT t.eventId, result, SUM(numSeniors) AS numSeniors
FROM
(
  -- Latest senior averages
  SELECT *
  FROM wca_ipy.SeniorAveragesLatest
  UNION ALL
  -- Additional results created by upsampling
  SELECT a.eventId, result, COUNT(*) AS numSeniors
  FROM
  (
    SELECT eventId, result, ROW_NUMBER() OVER(PARTITION BY eventId ORDER BY result) AS rowId
    FROM wca_ipy.SeniorAveragesLatest a
    JOIN seq_1_to_1000 s ON s.seq <= a.numSeniors
  ) AS a
  JOIN wca_ipy.EventModels e ON e.eventId = a.eventId AND a.rowId % e.sampleFrequency = 0
  GROUP BY eventId, result
) AS t
GROUP BY eventId, result
ORDER BY eventId, result;

/*
   Review the effectiveness of sampling
*/

SELECT s.eventId, numSeniorsModel, SUM(numSeniors) AS numSeniorsActual, SUM(numSeniors) - numSeniorsModel AS diff
FROM wca_ipy.SeniorAverages s
JOIN wca_ipy.EventModels AS e ON e.eventId = s.eventId
GROUP BY eventId
HAVING diff != 0;
