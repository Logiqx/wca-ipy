/* 
    Script:   Aggregated Over 40's Rankings
    Date:     2018-11-27
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Unofficial rankings for the Over 40's exist on GitHub but they are known to be incomplete - https://github.com/Logiqx/wca-ipy.
              This extract will be used to provide participants of the unofficial rankings with a more comprehensive view of how they rank against their peers.
              The data will help us to ascertain how many people are missing from the unofficial rankings and provide general stats for the Over 40's in comp.
            
    Approach: The extract will not disclose any WCA IDs, regardless of whether they already appear in the unoffical rankings on GitHub.
              All consolidated results are modified using truncation / reduction of precision. This is typically to the nearest second.
              
    Notes:    This extract will potentially include personal records preceding the competitor being over 40 but this limitation will be deemed acceptable.
              The age check is a little crude (checking YOB is before 1979) but when considered alongside the limitation above it isn't really significant.
*/


/* 
   Simple count of oldies from "ranksaverage" and "rankssingle"

   1) Use a simple year check to pick out the 40 year olds - i.e. year < 1979 (not really worried about Nov/Dec 1978 being wrong)
*/

SELECT eventId, COUNT(*)
FROM wca.ranksaverage r
INNER JOIN persons p ON p.id = r.personId AND p.year < 1979
GROUP BY eventId
ORDER BY eventId;

SELECT eventId, COUNT(*)
FROM wca.rankssingle r
INNER JOIN persons p ON p.id = r.personId AND p.year < 1979
GROUP BY eventId
ORDER BY eventId;

/* 
   Extract AGGREGATED oldies from "ranksaverage"
   
   1) Output counts of oldies rather than WCA IDs
   2) Leave "best" unchanged for known oldies, regardless of event - i.e. best
   3) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000) * 10000000
   4) Truncate FMC "average" to the nearest move - i.e. FLOOR(best / 100) * 100
   5) Truncate everything else to the nearest second - i.e. FLOOR(best / 100) * 100
   6) Use a simple year check to pick out the 40 year olds - i.e. year < 1979 (not really worried about Nov/Dec 1978 being wrong)
*/

SELECT eventId,
    CASE
        WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best / 10000000) * 10000000
        WHEN eventId IN ('333fm') THEN FLOOR(best / 100) * 100
        ELSE FLOOR(best / 100) * 100
    END AS modifiedBest,
    COUNT(*)
FROM wca.ranksaverage r
INNER JOIN persons p ON p.id = r.personId AND p.year < 1979
GROUP BY eventId, modifiedBest
ORDER BY eventId, modifiedBest;

/* 
   Extract AGGREGATED oldies from "rankssingle"
   
   1) Output counts of oldies rather than WCA IDs
   2) Leave "best" unchanged for known oldies, regardless of event - i.e. best
   3) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000) * 10000000
   4) Leave FMC "single" as a move count - i.e. best
   5) Truncate everything else to the nearest second - i.e. FLOOR(best / 100) * 100
   6) Use a simple year check to pick out the 40 year olds - i.e. year < 1979 (not really worried about Nov/Dec 1978 being wrong)
*/

SELECT eventId,
    CASE
        WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best / 10000000) * 10000000
        WHEN eventId IN ('333fm') THEN best
        ELSE FLOOR(best / 100) * 100
    END AS modifiedBest,
    COUNT(*)
FROM wca.rankssingle r
INNER JOIN persons p ON p.id = r.personId AND p.year < 1979
GROUP BY eventId, modifiedBest
ORDER BY eventId, modifiedBest;
