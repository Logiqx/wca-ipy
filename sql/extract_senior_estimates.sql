/*
    Script:   Extract Senior Estimates
    Created:  2019-12-16
    Author:   Michael George / 2015GEOR02

    Purpose:  Extract the senior estimates
*/

SELECT 'senior_estimates', eventId, ageCategory, estSingles, estAverages
FROM SeniorEstimates
ORDER BY eventId, ageCategory;
