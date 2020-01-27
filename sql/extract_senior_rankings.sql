/* 
    Script:   Extract Senior Results
    Created:  2020-01-06
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract senior rankings - combining actual results and 'fake' results
*/

/*
    Start by determining the rankings for all events / age categories
*/

-- DROP TEMPORARY TABLE IF EXISTS SeniorRanks;

CREATE TEMPORARY TABLE SeniorRanks AS
SELECT eventId, resultType, ageCategory, personId, best, RANK() OVER (PARTITION BY eventId, resultType, ageCategory ORDER BY best) AS rankNo
FROM
(
    -- Additional brackets added for clarity
    (
        -- Actual results
        SELECT eventId, resultType, seq AS ageCategory, personId, MIN(best) AS best
        FROM
        (
            SELECT r.eventId, 'average' AS resultType, r.personId, r.average AS best,
                TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
            FROM Seniors AS p
            JOIN wca.Results AS r ON r.personId = p.personId AND average > 0
            JOIN wca.Competitions AS c ON c.id = r.competitionId
            WHERE YEAR(dob) <= YEAR(CURDATE()) - 40
            HAVING age_at_comp >= 40
            UNION ALL
            SELECT r.eventId, 'single' AS resultType, r.personId, r.best,
                TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS age_at_comp
            FROM Seniors AS p
            JOIN wca.Results AS r ON r.personId = p.personId AND best > 0
            JOIN wca.Competitions AS c ON c.id = r.competitionId
            WHERE YEAR(dob) <= YEAR(CURDATE()) - 40
            HAVING age_at_comp >= 40
        ) AS t
        JOIN seq_40_to_100_step_10 ON seq <= age_at_comp
        GROUP BY eventId, resultType, ageCategory, personId
    )
    UNION ALL
    (
        -- Fake results
        SELECT sv.eventId, sv.resultType, sv.ageCategory, fakeId AS personId, fakeResult AS best
        FROM SeniorFakes AS sf
        JOIN SeniorViews AS sv ON sv.viewId = sf.viewId
    )
) AS t;

/*
    Finish up by appending the competition id and sorting the rankings
*/

SELECT eventId, resultType, ageCategory, personId, best, rankNo, competitionId, ageAtComp
FROM
(
    -- Additional brackets added for clarity
    (
        -- Actual results
        SELECT eventId, resultType, ageCategory, personId, best, rankNo, personName, competitionId, ageAtComp
        FROM
        (
            SELECT sr.*, s.name AS personName, c.id AS competitionId,
                FLOOR(TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageAtComp,
                ROW_NUMBER() OVER (PARTITION BY sr.eventId, sr.resultType, sr.ageCategory, sr.personId ORDER BY c.year, c.month, c.day) AS rowNo
            FROM Seniors AS s
            JOIN SeniorRanks AS sr ON sr.personId = s.personId
            JOIN wca.Results AS r ON r.eventId = sr.eventId AND r.personId = sr.personId AND r.average = sr.best
            JOIN wca.Competitions AS c ON c.id = r.competitionId
            WHERE resultType = 'average'
            HAVING ageAtComp >= sr.ageCategory
            UNION ALL
            SELECT sr.*, s.name AS personName, c.id AS competitionId,
                FLOOR(TIMESTAMPDIFF(YEAR, dob, DATE_FORMAT(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) / 10) * 10 AS ageAtComp,
                ROW_NUMBER() OVER (PARTITION BY sr.eventId, sr.resultType, sr.ageCategory, sr.personId ORDER BY c.year, c.month, c.day) AS rowNo
            FROM Seniors AS s
            JOIN SeniorRanks AS sr ON sr.personId = s.personId
            JOIN wca.Results AS r ON r.eventId = sr.eventId AND r.personId = sr.personId AND r.best = sr.best
            JOIN wca.Competitions AS c ON c.id = r.competitionId
            WHERE resultType = 'single'
            HAVING ageAtComp >= sr.ageCategory
        ) AS t
        WHERE rowNo = 1
    )
    UNION ALL
    (
        -- Fake results
        SELECT sr.*, personId AS personName, 'WC2003' AS competitionId, sr.ageCategory AS ageAtComp
        FROM SeniorRanks AS sr
        WHERE personId LIKE 'FAKE%'
    )
) AS t
ORDER BY eventId, resultType DESC, ageCategory, best, personName;
