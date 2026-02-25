/* 
    Script:   Extract Senior Participants
    Created:  2020-01-13
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Extract list of recent competitions with senior participation
*/

SELECT DISTINCT r.competition_id, r.person_id
FROM seniors AS p
JOIN wca.results AS r ON r.person_id = p.wca_id
JOIN wca.competitions AS c ON c.id = r.competition_id
	AND TIMESTAMPDIFF(YEAR, dob, c.start_date) >= 40
	AND TIMESTAMPDIFF(DAY, UTC_DATE(), c.end_date) >= -91
WHERE hidden <> 'x'
ORDER BY competition_id, wca_id;
