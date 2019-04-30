/* 
    Script:   Alter Persons Table
    Created:  2019-02-19
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Add YMD and username columns to the "Persons" table
*/

-- Add columns as per the non-public WCA database
ALTER TABLE Persons
ADD COLUMN
(
    `year` SMALLINT(5) UNSIGNED NOT NULL DEFAULT 0,
    `month` TINYINT(5) UNSIGNED NOT NULL DEFAULT 0,
    `day` TINYINT(5) UNSIGNED NOT NULL DEFAULT 0
);
