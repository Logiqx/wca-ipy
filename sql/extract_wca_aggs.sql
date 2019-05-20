/* 
    Script:   Aggregated Rankings
    Created:  2019-02-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  This extract will be used to create overall percentile rankings.
            
    Approach: All consolidated results are modified using truncation / reduction of precision.
*/

/* 
   Extract AGGREGATED results from 'RanksAverage'
   
   1) Output counts rather than WCA IDs
   2) Truncate everything to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId, FLOOR(best / 100) AS modified_average, COUNT(*) AS num_persons
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/public/extract/wca_averages_agg.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM RanksAverage
GROUP BY eventId, modified_average
ORDER BY eventId, modified_average;

/* 
   Extract AGGREGATED results from 'RanksSingle'
   
   1) Output counts rather than WCA IDs
   2) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
   3) Leave FMC "single" as a move count - i.e. best
   4) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId,
  (
    CASE
      WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best / 10000000)
      WHEN eventId IN ('333fm') THEN best
      ELSE FLOOR(best / 100)
    END
  ) AS modified_single, COUNT(*) AS num_persons
INTO OUTFILE '/home/jovyan/work/wca-ipy/data/public/extract/wca_singles_agg.csv' FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
FROM RanksSingle
GROUP BY eventId, modified_single
ORDER BY eventId, modified_single;
