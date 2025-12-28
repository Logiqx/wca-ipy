/* 
    Script:   Apply Fake DOBs
    Created:  2019-02-07
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Apply fake DOB to everyone in the WCA database (public export) for testing purposes
            
    Approach: Generate random numbers and allocate to age categories resembling actual WCA data
*/

-- Apply random DOB
UPDATE persons
SET year = FLOOR(
      YEAR(NOW()) - 1 -
      (
        CASE
          WHEN RAND() * 10000 < 1 THEN 80
          WHEN RAND() * 10000 < 5 THEN 70
          WHEN RAND() * 10000 < 10 THEN 60
          WHEN RAND() * 10000 < 50 THEN 50
          WHEN RAND() * 10000 < 100 THEN 40
          WHEN RAND() * 10000 < 200 THEN 30
          WHEN RAND() * 10000 < 400 THEN 20
          ELSE 10
        END
      ) - RAND() * 10),
    month = FLOOR(1 + RAND() * 12),
    day = FLOOR(1 + RAND() * 28);

-- Check age categories
SELECT FLOOR((YEAR(NOW()) - year) / 10) * 10 AS age_category, COUNT(*)
FROM persons
GROUP BY age_category
ORDER BY age_category;
