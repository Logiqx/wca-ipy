/* 
      Script:   Create Senior Details View
      Created:  2019-05-28
      Author:   Michael George / 2015GEOR02
     
      Purpose:  Create view providing useful information about seniors
*/

DROP VIEW IF EXISTS SeniorDetails;
DROP VIEW IF EXISTS senior_details;

CREATE VIEW senior_details AS
SELECT s.wca_id, s.name, s.country_id, s.gender, s.dob, s.hidden, s.deceased,
    MIN(STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS first_comp,
    MAX(STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d')) AS last_comp,
    COUNT(DISTINCT r.competition_id) AS num_comps,
    MAX(TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(LEFT(s.wca_id, 4), '-01-01'), '%Y-%m-%d'), STR_TO_DATE(CONCAT(c.year, '-01-01'), '%Y-%m-%d')) + 1) AS years_competing,
    MIN(TIMESTAMPDIFF(YEAR, s.dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d'))) AS age_first_comp,
    MAX(TIMESTAMPDIFF(YEAR, s.dob, STR_TO_DATE(CONCAT(c.year, '-', c.month, '-', c.day), '%Y-%m-%d'))) AS age_last_comp,
    TIMESTAMPDIFF(YEAR, s.dob, NOW()) AS age_today,
    s.accuracy_id, s.source_id, s.user_status_id,
    sa.type AS accuracy_type, ss.type AS source_type, us.type AS user_status,
    s.user_id, u.current_avatar_id, s.username, s.usernum, s.email, s.facebook, s.youtube, s.comment
FROM seniors AS s
JOIN senior_sources ss ON ss.id = s.source_id
JOIN senior_accuracies sa ON sa.id = s.accuracy_id
JOIN user_statuses us ON us.id = s.user_status_id
JOIN wca.results AS r ON r.person_id = s.wca_id
JOIN wca.competitions AS c ON c.id = r.competition_id
LEFT JOIN wca_dev.users u ON u.id = s.user_id
GROUP BY s.wca_id
ORDER BY last_comp DESC, num_comps DESC, years_competing DESC;
