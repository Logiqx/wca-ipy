/* 
    Script:   Anonymised Over 40's Rankings
    Date:     2018-11-01
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Unofficial rankings for the Over 40's exist on GitHub but they are known to be incomplete - https://github.com/Logiqx/wca-ipy.
              This extract will be used to provide participants of the unofficial rankings with a more comprehensive view of how they rank against their peers.
              The data will help us to ascertain how many people are missing from the unofficial rankings and provide general stats for the Over 40's in comp.
            
    Approach: The extract will not disclose any WCA IDs which do not already appear in the unoffical rankings on GitHub.
              Rankings for the competitors who do not appear in the unoffical rankings will be included in this extract but it will not disclose their WCA IDs.
              To mitigate the risk of times / results being used to identify individuals, results shall be modified using truncation / reduction of precision.
              
    Notes:    This extract will potentially include personal records preceding the competitor being over 40 but this limitation will be deemed acceptable.
              The age check is a little crude (checking YOB is before 1979) but when considered alongside the limitation above it isn't really significant.
*/


/* 
   Create temporary table for the known oldies
   
   Sourced from https://github.com/Logiqx/wca-ipy
*/

DROP TEMPORARY TABLE IF EXISTS oldies;

CREATE TEMPORARY TABLE oldies
(
    personId varchar(10) NOT NULL
);

INSERT INTO oldies (personId) VALUES
('1982FRID01'), ('1982PETR01'), ('1982RAZO01'), ('2003AKIM01'), ('2003BARR01'), ('2003BLON01'), ('2003BRUC01'), ('2003DENN01'), ('2003WESS01'), ('2003ZBOR02'),
('2004BOSS01'), ('2004FEDE01'), ('2004FERN01'), ('2004MASA01'), ('2004MCGA01'), ('2004ROUX01'), ('2004ZIJD01'), ('2005CAMP01'), ('2005CHEN02'), ('2005FARK01'),
('2005GUST02'), ('2005ISHI01'), ('2005JOKS01'), ('2005KOCZ01'), ('2005KOSE01'), ('2005KURO02'), ('2005PARI01'), ('2005THOM01'), ('2005TOMI01'), ('2005TOMO01'),
('2005VANH02'), ('2006ALBA01'), ('2006BERG01'), ('2006GALE01'), ('2006HYAK01'), ('2006LOUI01'), ('2006MATH01'), ('2006NORS01'), ('2007BERR01'), ('2007DIAZ01'),
('2007FEKE01'), ('2007HASH01'), ('2007HUGH01'), ('2007OEYM01'), ('2007SANC01'), ('2008BERG04'), ('2008COUR01'), ('2008ERSK01'), ('2008GOUB01'), ('2008LIDS01'),
('2009JOHN07'), ('2009PARE02'), ('2009TIRA01'), ('2010HEIL02'), ('2010SPIE01'), ('2011BOIS01'), ('2011DINA01'), ('2011LAWR01'), ('2011MICH01'), ('2011STUA01'),
('2011WRIG01'), ('2012OTAN01'), ('2012PETR01'), ('2012PLAC01'), ('2012POOT01'), ('2012SCHM07'), ('2012WATA02'), ('2013ANTI01'), ('2013BRAN01'), ('2013COLL02'),
('2013COPP01'), ('2013DEAR01'), ('2013LEIS01'), ('2013MORA02'), ('2014DECO01'), ('2014JANE01'), ('2014PACE01'), ('2014VIGN02'), ('2015ADAM03'), ('2015BOSW01'),
('2015GALE01'), ('2015GEOR02'), ('2015GOSL01'), ('2015HARR03'), ('2015JOIN02'), ('2015NICH04'), ('2015PARK24'), ('2015PEPP01'), ('2015PLOW01'), ('2015PRAT08'),
('2015REYE08'), ('2015RIVE05'), ('2015SPAD01'), ('2015TAYL04'), ('2016ALAR01'), ('2016DUEH02'), ('2016GALE02'), ('2016GOSL01'), ('2016GREE02'), ('2016LEWI07'),
('2016PETE06'), ('2016POPO02'), ('2016ZEMD01'), ('2017FREG01'), ('2017GRAD03'), ('2017LACH01'), ('2017MAHI02'), ('2017PALI03'), ('2017ROSA09'), ('2017VIDO02'),
('2018DOYL02'), ('2018GUTI13'), ('2018PRAT13'), ('2018SALM01'), ('2018VILJ02');

/* 
   Extract ANONYMISED oldies from "ranksaverage"
   
   1) Only output the WCA ID of known oldies, output NULL for unknown oldies - i.e. o.personId
   2) Leave "best" unchanged for known oldies, regardless of event - i.e. best
   3) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000) * 10000000
   4) Truncate FMC "average" to the nearest move - i.e. FLOOR(best / 100) * 100
   5) Truncate everything else to the nearest second - i.e. FLOOR(best / 100) * 100
   6) Use a simple year check to pick out the 40 year olds - i.e. year < 1979 (not really worried about Nov/Dec 1978 being wrong)
*/

SELECT eventId, o.personId,
    CASE
        WHEN o.personId IS NOT NULL THEN best
        WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best / 10000000) * 10000000
        WHEN eventId IN ('333fm') THEN FLOOR(best / 100) * 100
        ELSE FLOOR(best / 10) * 10
    END AS modifiedBest
FROM wca.ranksaverage r
INNER JOIN persons p ON p.id = r.personId AND p.year < 1979
LEFT JOIN oldies o ON o.personId = r.personId
ORDER BY eventId, worldRank;

/* 
   Extract ANONYMISED oldies from "rankssingle"
   
   1) Only output the WCA ID of known oldies, output NULL for unknown oldies - i.e. i.e. o.personId
   2) Leave "best" unchanged for known oldies, regardless of event - i.e. best
   3) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000) * 10000000
   4) Leave FMC "single" as a move count - i.e. best
   5) Truncate everything else to the nearest second - i.e. FLOOR(best / 100) * 100
   6) Use a simple year check to pick out the 40 year olds - i.e. year < 1979 (not really worried about Nov/Dec 1978 being wrong)
*/

SELECT eventId, o.personId,
    CASE
        WHEN o.personId IS NOT NULL THEN best
        WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best / 10000000) * 10000000
        WHEN eventId IN ('333fm') THEN best
        ELSE FLOOR(best / 100) * 100
    END AS modifiedBest
FROM wca.rankssingle r
INNER JOIN persons p ON p.id = r.personId AND p.year < 1979
LEFT JOIN oldies o ON o.personId = r.personId
ORDER BY eventId, worldRank;
