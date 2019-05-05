/* 
    Script:   Create user
    Created:  2019-05-05
    Author:   Michael George / 2015GEOR02
   
    Purpose:  Create the WCA user and grant permissions
*/

-- Create WCA user
CREATE USER wca IDENTIFIED BY 'change.me';

-- Enable reading / writing of files on the server host
GRANT FILE ON *.* TO wca;

-- Grant access to the latest WCA database
GRANT ALL ON wca.* TO wca;

-- Grant access to the historical WCA database
GRANT ALL ON wca_20190130.* TO wca;
