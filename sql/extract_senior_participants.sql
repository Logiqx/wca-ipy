/* 
    Script:   Extract Senior Participants
    Created:  2020-01-13
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract list of recent competitions with senior participation
*/

SELECT DISTINCT r.competitionId, r.personId
FROM Seniors AS p
JOIN wca.Results AS r ON r.personId = p.personId
JOIN wca.Competitions AS c ON c.id = r.competitionId
	AND TIMESTAMPDIFF(YEAR, dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) >= 40
	AND TIMESTAMPDIFF(DAY, UTC_DATE(), STR_TO_DATE(CONCAT(c.year + IF(c.endMonth < c.month, 1, 0), '-', c.endMonth, '-', c.endDay), '%Y-%m-%d')) >= -91
ORDER BY competitionId, personId;
