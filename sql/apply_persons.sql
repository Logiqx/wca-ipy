/*
    Script:   Apply Persons
    Created:  2019-11-10
    Author:   Michael George / 2015GEOR02

    Purpose:  Apply name and country to seniors table
*/

-- Populate name and country on seniors
UPDATE wca_ipy.Seniors s
JOIN Persons p ON p.id = s.personId AND p.subid = 1
SET s.name = p.name, s.countryId = p.countryId, s.gender = p.gender;
