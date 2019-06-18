/* 
    Script:   Aggregated Over 40s Rankings
    Created:  2019-02-07
    Author:   Michael George / 2015GEOR02

    Purpose:  Provide a comprehensive view of the over 40s performances in competition.

    Approach: The extract will not disclose any WCA IDs, regardless of whether they are already known.
              All consolidated results are modified using truncation / reduction of precision.
*/

-- WCA extract date will be used as a cutoff
SET @cutoff = '2019-02-01';

/* 
   Extract AGGREGATED senior results (averages)

   1) Output counts of seniors rather than WCA IDs
   2) Truncate everything to the nearest second - i.e. FLOOR(best / 100)
*/

-- Identify the NEW known averages, ignoring the "cutoff"
DROP TABLE IF EXISTS wca_ipy.SeniorAveragesNew;

CREATE TABLE wca_ipy.SeniorAveragesNew AS
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

ALTER TABLE wca_ipy.SeniorAveragesNew ADD PRIMARY KEY(eventId, result);

-- Identify the OLD known averages, prior to the "cutoff" date
DROP TABLE IF EXISTS wca_ipy.SeniorAveragesOld;

CREATE TABLE wca_ipy.SeniorAveragesOld AS
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
      -- Excluding these specific competitions is the equivalent of results_posted_at < @cutoff
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

ALTER TABLE wca_ipy.SeniorAveragesOld ADD PRIMARY KEY(eventId, result);

-- Load the extract from the WCA, created on "cutoff" date (see above)
DROP TABLE IF EXISTS wca_ipy.SeniorAverages;

CREATE TABLE wca_ipy.SeniorAverages
(
  `eventId` varchar(6) CHARACTER SET latin1 NOT NULL,
  `result` int(11) NOT NULL,
  `numSeniors` smallint(6) NOT NULL,
   PRIMARY KEY (`eventId`, `result`)
);

LOAD DATA INFILE '/home/jovyan/work/wca-ipy/data/private/feed/senior_averages_agg.csv'
INTO TABLE wca_ipy.SeniorAverages FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' IGNORE 1 LINES;

-- Sanity Check - results indicate non-seniors being processed
SELECT a.eventId, a.result, a.numSeniors - IFNULL(o.numSeniors, 0) AS numSeniors
FROM wca_ipy.SeniorAverages a
LEFT JOIN wca_ipy.SeniorAveragesOld o ON o.eventId = a.eventId AND o.result = a.result
HAVING numSeniors < 0;

-- Combine the unknown senior averages (unchanged since 2019-02-01) with the known senior averages
SELECT eventId, result, SUM(numSeniors) AS numSeniors
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/senior_averages_agg.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(
  SELECT a.eventId, a.result, a.numSeniors - IFNULL(o.numSeniors, 0) AS numSeniors
  FROM wca_ipy.SeniorAverages a
  LEFT JOIN wca_ipy.SeniorAveragesOld o ON o.eventId = a.eventId AND o.result = a.result
  HAVING numSeniors > 0
  UNION ALL
  SELECT *
  FROM wca_ipy.SeniorAveragesNew
) AS t
GROUP BY eventId, result
ORDER BY eventId, result;

-- Extract known senior averages
SELECT *
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/known_senior_averages_agg.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM wca_ipy.SeniorAveragesNew;

/* 
   Extract AGGREGATED senior results (singles)

   1) Output counts of seniors rather than WCA IDs
   2) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
   3) Leave FMC "single" as a move count - i.e. best
   4) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
*/

-- Identify the NEW known singles, ignoring the "cutoff"
SELECT eventId,
  (
    CASE
      WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best_single / 10000000)
      WHEN eventId IN ('333fm') THEN best_single
      ELSE FLOOR(best_single / 100)
    END
  ) AS result, COUNT(*) AS num_persons
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/private/extract/known_senior_singles_agg.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM
(   
  SELECT eventId, personId, MIN(best) AS numSeniors
  FROM
  (
    SELECT r.eventId, r.personId, r.best,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, '-', p.month, '-', p.day), '%Y-%m-%d'),
        DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.subid = 1 AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE best > 0
    HAVING age_at_comp >= 40
  ) AS tmp_results
  GROUP BY eventId, personId
) AS tmp_persons
GROUP BY eventId, result
ORDER BY eventId, result;
