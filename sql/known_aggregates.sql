/* 
    Script:   Aggregated Over 40's Rankings
    Date:     2019-02-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Unofficial rankings for the Over-40's exist on GitHub but they are known to be incomplete - https://github.com/Logiqx/wca-ipy.
              This extract will be used to provide participants of the unofficial rankings with a more comprehensive view of how they rank against their peers.
              The data will help us to ascertain how many people are missing from the unofficial rankings and provide general stats for the Over 40's in comp.
            
    Approach: The extract will not disclose any WCA IDs, regardless of whether they already appear in the unoffical rankings on GitHub.
              All consolidated results are modified using truncation / reduction of precision. This is typically to the nearest second.
*/


/* 
   Create temporary table using data from the unofficial rankings
*/

DROP TEMPORARY TABLE IF EXISTS personsextra;

CREATE TEMPORARY TABLE personsextra
(
     id varchar(10) CHARACTER SET latin1 NULL,
     dob date,
     username varchar(30) CHARACTER SET latin1 NULL
);

INSERT INTO personsextra (id, dob, username)
VALUES
('1982FRID01', '1964-12-31', NULL), -- YOB taken from Wikipedia
('1982PETR01', '1960-11-04', 'Lars Petrus'), -- Located on Speedsolving.com Wiki + Wikipedia 2017-11-25
('1982RAZO01', '1965-03-02', 'guusrs'), -- Located on Speedsolving.com Wiki 2017-11-25
('2003AKIM01', '1965-12-18', NULL), -- Provided by Ron via Facebook Messenger 2018-10-31
('2003BARR01', NULL, NULL), -- Over-40 PB average for 3x3 is 21.44, provided by qqwref on Speedsolving.com 2015-07-15
('2003BLON01', '1969-12-31', 'Michiel van der Blonk'),
('2003BRUC01', '1967-04-20', 'Ron'), -- Located on Speedsolving.com Wiki 2017-11-25
('2003DENN01', '1960-12-28', 'Ton'), -- Provided by Ron via Facebook Messenger 2018-10-31
('2003WESS01', '1930-12-31', 'Rune'), -- approximated year from age
('2003ZBOR02', '1966-12-31', NULL), -- YOB taken from Speedsolving Wiki
('2004BOSS01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2004FEDE01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2004FERN01', '1970-01-01', 'ernesto'), -- Fake DOB to include recent clock results
('2004MASA01', NULL, 'noiusli'),
('2004MCGA01', '1949-12-31', 'Bill'),
('2004ROUX01', '1971-01-20', 'gogozerg'), -- Located on Speedsolving.com Wiki + Wikipedia 2017-07-24
('2004ZIJD01', '1960-01-07', NULL),  -- Provided by Ron via Facebook Messenger 2018-10-31
('2005CAMP01', '1977-09-15', NULL), -- Provided by Dave via PM on Facebook
('2005CHEN02', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005FARK01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005GUST02', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005ISHI01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005JOKS01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005KOCZ01', '1973-10-31', 'Pitzu'), -- Provided by Ron Van Bruchen 2018-10-30 (via Selkie)
('2005KOSE01', '1974-11-18', 'Fumiki'), -- DOB provided by Fumiki on Speedsolving.com 2018-10-30
('2005KURO02', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005PARI01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005THOM01', '1965-07-04', NULL),  -- Provided by Ron via Facebook Messenger 2018-10-31
('2005TOMI01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2005TOMO01', '1933-12-31', NULL), -- approximated year from age
('2005VANH02', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2006ALBA01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2006BERG01', '1929-12-31', NULL), -- approximated year from age
('2006GALE01', '1976-07-05', 'AvGalen'), -- YOB provided by Arnaud on Speedsolving.com 2018-08-07, DOB found on Wiki
('2006HYAK01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2006LOUI01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2006MATH01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2006NORS01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2007BERR01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2007DIAZ01', '1968-09-17', NULL),  -- Provided by Ron via Facebook Messenger 2018-10-31
('2007FEKE01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2007HASH01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2007HUGH01', '1962-03-16', 'Mike Hughey'), -- Located on Speedsolving.com Wiki 2017-11-25
('2007OEYM01', '1964-12-31', 'Crazycubemom'), -- approximated year from age
('2007SANC01', '1974-01-01', 'Cabezuelo'), -- Fake DOB to include FMC
('2008BERG04', '1950-12-31', 'MatsBergsten'),
('2008COUR01', '1970-12-31', 'TMOY'),
('2008ERSK01', NULL, 'MichaelErskine'),
('2008GOUB01', NULL, NULL), -- provided by qqwref on Speedsolving.com 2015-07-15
('2008LIDS01', '1972-12-31', 'Lid'),
('2009JOHN07', '1955-12-31', 'rjohnson_8ball'), -- approximated year from age
('2009PARE02', NULL, 'Luis'),
('2009TIRA01', '1971-12-31', 'superti'), -- approximated year from age
('2010HEIL02', NULL, NULL), -- Suggested by Ron via Facebook Messenger 2018-10-31
('2010SPIE01', '1963-12-31', 'JoSpies'),
('2011BOIS01', NULL, NULL),  -- Provided by Ron via Facebook Messenger 2018-10-31
('2011LAWR01', '1977-09-30', 'speedpicker'), -- provided by Scott at UKC 2018
('2011MICH01', '1920-12-31', NULL), -- approximated year from age
('2011STUA01', '1974-12-31', 'Brest'),
('2011WRIG01', '1969-12-31', 'Selkie'),
('2012OTAN01', NULL, NULL),
('2012PETR01', '1975-05-01', 'Niki_Petrov'), -- provided by Nikolai on Speedsolving 2018-10-17, tweaked month for 5x5x5
('2012PLAC01', '1970-12-31', 'commodore128'),
('2012POOT01', '1969-12-31', 'MarcelP'),
('2012SCHM07', '1971-12-31', 'Schmidt'),
('2012WATA02', '1972-12-31', '4EverCuber'),
('2013ANTI01', '1969-12-31', 'marant69'),
('2013BRAN01', '1958-12-31', 'CarlBrannen'), -- approximated year from age
('2013COLL02', NULL, NULL),
('2013COPP01', '1973-12-31', 'bubbagrub'),
('2013DEAR01', NULL, 'ellwd'),
('2013LEIS01', '1973-12-31', 'RicardoRix'),
('2013MORA02', '1973-06-14', 'moralsh'), -- provided by Raúl on Speedsolving 2017-07-25
('2014DECO01', '1973-12-31', 'EvilGnome6 '),
('2014JANE01', '1974-05-05', NULL), -- Provided by Ron via Facebook Messenger 2018-10-31
('2014PACE01', '1974-12-31', 'h2f'), -- approximated year from age
('2014VIGN02', '1964-12-31', 'vigo64'), -- YOB provided by Ciro on Speedsolving 2018-09-08
('2015ADAM03', '1972-12-31', 'newtonbase'),
('2015BOSW01', '1969-12-31', 'JohnnyReggae'), -- YOB provided by Brent via Speedsolving PM 2018-07-25
('2015CLAR13', '1960-01-01', NULL), -- Steve asked to be added to at WSM 2018, provided age + YOB by e-mail 2019-01-27
('2015GALE01', '1967-08-18', 'Steve Galen'), -- provided by Steve 2018-05-05
('2015GEOR02', '1972-07-04', 'Logiqx'), -- provided by Mike 2017-07-25
('2015GOSL01', '1968-12-31', NULL),
('2015HARR03', '1973-09-11', 'chtiger'), -- provided by Chad on Speedsolving 2017-07-24
('2015JOIN02', NULL, NULL),
('2015NICH04', '1978-10-01', 'Shaky Hands'), -- approved by Facebook Messenger 2018-10-30
('2015PARK24', '1970-12-15', 'openseas'),
('2015PEPP01', NULL, 'SenorJuan'),
('2015PLOW01', NULL, NULL),
('2015PRAT08', '1971-12-31', NULL), -- provided by EvilGnome6 on Speedsolving 2018-07-24
('2015REYE08', '1970-12-31', NULL),
('2015RIVE05', '1967-06-01', 'mark49152'), -- provided by Mark on Speedsolving 2017-07-24 (rough dob)
('2015SPAD01', '1969-12-31', 'cubesp'),
('2015TAYL04', '1971-07-31', NULL), -- http://speedcubing-for-olds.blogspot.com/2016/09/even-older-new-cubes.html
('2016ALAR01', '1976-06-20', 'muchacho'), -- provided by David on Speedsolving 2017-07-25
('2016DUEH02', '1976-11-01', 'SpartanSailor'), -- requested by Jeremy on Speedsolving 2018-01-14
('2016GALE02', '1977-09-27', 'Francesco Galetta'),
('2016GOSL01', '1968-12-31', NULL),
('2016GREE02', '1974-12-31', 'Jason Green'),
('2016LEWI07', '1968-01-20', 'pglewis'), -- provided by Phil on Speedsolving 2017-07-24
('2016PETE06', '1974-12-31', 'rjpcal'),
('2016POPO02', '1967-12-31', 'mitja'),
('2016ZEMD01', NULL, 'David Zemdegs'),
('2017FREG01', '1975-12-31', 'megagoune'),
('2017GRAD03', NULL, NULL), -- suggested by openseas on Speedsolving 2018-01-14
('2017LACH01', '1977-12-31', 'teacher77'),
('2017MAHI02', NULL, NULL), -- Same table at UKC 2018
('2017PALI03', '1965-12-31', NULL), -- approximated year from age
('2017ROSA09', NULL, 'Bruno Rosa'), -- provided by Bruno on Speedsolving 2018-10-31
('2017VIDO02', '1976-12-31', 'Nervous Nico'),
('2018DOYL02', '1938-06-28', 'Old Tom'), -- provided by Tom on Speedsolving
('2018GUTI13', '1970-12-31', 'mafergut'), -- approximated year from age
('2018PRAT13', '1976-05-01', 'Soyale'), -- provided by James on Speedsolving 2018-07-23
('2018SALM01', NULL, NULL), -- suggested by Shaky Hands
('2018VILJ02', '1959-12-31', 'danievil'), -- provided by Danie on Speedsolving 2018-09-26
('2018CUME02', NULL, NULL),
('2019CHIE01', '1970-09-10', 'MCMLXX'), -- provided by Siwasan on Speedsolving 2019-01-21
('2019ONOG01', '1973-12-31', NULL) -- approximated from post by Caner on Senior Cubers Worldwide 2019-01-18
;

/* 
   Apply DOB from temporary table to "Persons"
   
   1) Add year, month, day to Persons table
   2) Apply known year, month, day to the "Persons" table
   3) Apply fake DOB for the remaining seniors
*/

-- Columns as per the private WCA database
ALTER TABLE PERSONS
ADD COLUMN
(
    `year` SMALLINT(5),
    `month` SMALLINT(5),
    `day` SMALLINT(5)
);

-- Default values
UPDATE persons AS p
SET p.year = 0,
    p.month = 0,
    p.day = 0;

-- Use DOB if it is known (or approximated)
UPDATE persons AS p
INNER JOIN PersonsExtra AS pe ON pe.id = p.id AND pe.dob IS NOT NULL
SET p.year = DATE_FORMAT(pe.dob, "%Y"),
    p.month = DATE_FORMAT(pe.dob, "%m"),
    p.day = DATE_FORMAT(pe.dob, "%d");

-- Use 40 years prior to the first WCA competition if DOB is unknown
UPDATE persons AS p
INNER JOIN PersonsExtra AS pe ON pe.id = p.id AND pe.dob IS NULL
SET p.year = 1963,
    p.month = 8,
    p.day = 23;

-- Check years
SELECT p.year, COUNT(*)
FROM Persons AS p
GROUP BY p.year;

/* 
   Extract AGGREGATED seniors from "RanksAverage"
   
   1) Output counts of seniors rather than WCA IDs
   2) Truncate everything to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId, FLOOR(best_average / 100) AS modified_average, COUNT(*) AS num_persons
FROM
(
  SELECT eventId, personId, MIN(best) AS best_single, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.best, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE average > 0
    HAVING age_at_comp >= 40
  ) tmp_results
  GROUP BY eventId, personId
) tmp_persons
GROUP BY eventId, modified_average;

/* 
   Extract AGGREGATED seniors from "RanksSingle"
   
   1) Output counts of seniors rather than WCA IDs
   2) Truncate MBF to "points" only - i.e. FLOOR(best / 10000000)
   3) Leave FMC "single" as a move count - i.e. best
   4) Truncate everything else to the nearest second - i.e. FLOOR(best / 100)
*/

SELECT eventId,
  (
    CASE
      WHEN eventId IN ('333mbf', '333mbo') THEN FLOOR(best_single / 10000000)
      WHEN eventId IN ('333fm') THEN best_single
      ELSE FLOOR(best_single / 100)
    END
  ) AS modified_single, COUNT(*) AS num_persons
FROM
(   
  SELECT eventId, personId, MIN(best) AS best_single, MIN(average) AS best_average
  FROM
  (
    SELECT r.eventId, r.personId, r.best, r.average,
      TIMESTAMPDIFF(YEAR,
        DATE_FORMAT(CONCAT(p.year, "-", p.month, "-", p.day), "%Y-%m-%d"),
        DATE_FORMAT(CONCAT(c.year, "-", c.month, "-", c.day), "%Y-%m-%d")) AS age_at_comp
    FROM Results AS r
    INNER JOIN Competitions AS c ON r.competitionId = c.id
    INNER JOIN Persons AS p ON r.personId = p.id AND p.year > 0 AND p.year <= YEAR(CURDATE()) - 40
    WHERE best > 0
    HAVING age_at_comp >= 40
  ) tmp_results
  GROUP BY eventId, personId
) tmp_persons
GROUP BY eventId, modified_single;
