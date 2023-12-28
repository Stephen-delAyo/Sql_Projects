-- USE md_water_services;

-- SHOW TABLES;

/* SELECT * 
FROM data_dictionary, 
	employee,
    global_water_access,
    location,
    visits,
    water_quality,
    water_source,
    well_pollution
LIMIT 5; 
*/

/* SELECT *
FROM location 
LIMIT 5;
*/

/* SELECT *
FROM visits
LIMIT 5;
*/

/* SELECT *
FROM water_source
LIMIT 5;
*/ 

/* SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'md_water_services'
*/

-- SELECT * FROM information_schema.tables -- Here i queried for the information schema aslo known as data dictionary
-- WHERE table_schema = 'md_water_services';

-- SELECT DISTINCT type_of_water_source  -- Here, i wrote a SQL query to find all the unique types of water sources.
-- FROM water_source;

/* SELECT *  -- Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min. 
FROM visits
WHERE time_in_queue > 500;
*/

-- SELECT type_of_water_source, source_id
-- FROM water_source;

/* SELECT *
FROM water_source
WHERE source_id IN ('KiRu28935224', 'AkLu01628224', 'AkRu05234224');
*/

/* SELECT *
FROM visits
LIMIT 5;
*/

-- SELECT *
-- FROM water_source;

/* SELECT subjective_quality_score, visit_count -- So please write a query to find records where the subject_quality_score is 10 -- only looking for home taps -- and where the source was visited a second time. What will this tell us?
FROM water_quality  
WHERE subjective_quality_score = 10 AND visit_count >= 2;    
*/

/* SELECT COUNT(DISTINCT subjective_quality_score) AS Total_count,
	   COUNT(DISTINCT visit_count) AS Number_of_visits
FROM water_quality
WHERE subjective_quality_score = 10 AND visit_count >= 2;
*/

/* SELECT *  -- The query checks if the results are labeled as "Clean" but the biological contamination level is greater than 0.01, ensuring there are no errors in the data that could potentially cause harm to people's health.
FROM well_pollution  -- Slide 21
WHERE results = 'Clean' 
AND biological > 0.01;
*/

/* SELECT *   -- To find these descriptions, search for the word Clean with additional characters after it. As this is what separates incorrect descriptions from the records that should have "Clean".
FROM well_pollution  -- Slide 23
WHERE biological > 0.01
AND description LIKE 'Clean%' 
*/    

/* Case 1a: Update descriptions that mistakenly mention
`Clean Bacteria: E. coli` to `Bacteria: E. coli`
Case 1b: Update the descriptions that mistakenly mention
description`Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
Case 2: Update the `result` to `Contaminated: Biological` where
`biological` is greater than 0.01 plus current results is `Clean`
*/

-- Case 1a
/* UPDATE well_pollution
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';  
*/

-- Case 1b
/* UPDATE well_pollution
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia'
*/

-- Case 2
/* UPDATE well_pollution
SET results = 'Contaminated: Biological'
WHERE results = 'Clean' AND biological > 0.01;
*/

/* CREATE TABLE md_water_services.well_pollution_copy  -- HERE, I created a new table from the results set of the query, using The CREATE TABLE new_table AS (query) approach. This method is especially useful for creating backup tables or subsets without the need for a separate CREATE TABLE and INSERT INTO statement.
AS (                                                   -- So, we get a copy of the well_pollution called 'well_pollution_copy
SELECT *
FROM md_water_services.well_pollution
);
*/ 

-- From lines 106 - 118, i updated the well_pollution_copy table to reflect the updates in the original well_pollution table.
/* UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';
*/

/* UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';
*/

/* UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';
*/

/* SELECT *
FROM well_pollution_copy
WHERE description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);
*/

/* UPDATE well_pollution_copy
SET description = 'Bacteria: E. coli'
WHERE description = 'Clean Bacteria: E. coli';

UPDATE well_pollution_copy
SET description = 'Bacteria: Giardia Lamblia'
WHERE description = 'Clean Bacteria: Giardia Lamblia';

UPDATE well_pollution_copy
SET results = 'Contaminated: Biological'
WHERE biological > 0.01 AND results = 'Clean';
*/

-- DROP TABLE md_water_services.well_pollution_copy;

-- SELECT *
-- FROM employee
-- WHERE position = 'Micro Biologist';


/* SELECT source_id, COUNT(*) as number_of_people -- HERE, i want to know What is the source_id of the water source shared by the most number of people
FROM water_source
GROUP BY source_id
ORDER BY number_of_people_served DESC
LIMIT 1;
*/

-- SELECT table_name, column_name
-- FROM data_dictionary
-- WHERE column_name LIKE '%population%';

/* SELECT *
FROM md_water_services.water_quality
WHERE visit_count = 2 
AND subjective_quality_score = 10;
*/

/* SELECT * -- Here, this query will identifies the records with a quality score of 10, visited more than once?
FROM water_quality 
WHERE visit_count >= 2 
AND subjective_quality_score = 10
*/

/* SELECT *
FROM global_water_access
WHERE name = 'Maji Ndogo';
*/

/* SELECT *
FROM employee
WHERE position = 'Civil Engineer' AND (province_name = 'Dahabu' OR address LIKE '%Avenue%');
*/

/* Create a query to identify potentially suspicious field workers based on an anonymous tip. This is the description we are given:
The employee’s phone number contained the digits 86 or 11. 
The employee’s last name started with either an A or an M. 
The employee was a Field Surveyor.
*/
/* SELECT *
FROM employee
WHERE 
    (phone_number LIKE '%86%' OR phone_number LIKE '%11%')
    AND (employee_name LIKE 'A%' OR employee_name LIKE 'M%')
    AND position = 'Field Surveyor';
*/
    
/*SELECT *  -- This is the correct syntax to get the dubious employees
FROM employee
WHERE 
    (phone_number LIKE '%86%' OR phone_number LIKE '%11%')
    AND (
        RIGHT(employee_name, LOCATE(' ', REVERSE(employee_name)) - 1) LIKE 'A%' 
        OR RIGHT(employee_name, LOCATE(' ', REVERSE(employee_name)) - 1) LIKE 'M%'
    )
    AND position = 'Field Surveyor';
*/    

-- A more simplied version syntax 
/* SELECT * 
FROM employee
WHERE 
    (phone_number LIKE '%86%' OR phone_number LIKE '%11%')
    AND 
    (employee_name LIKE '% A%' OR employee_name LIKE '% M%')
    AND 
    position = 'Field Surveyor';
*/

/* SELECT COUNT(*)  -- 4916 records are returned. This query describes the pollution samples that had an insignificant amount of biological contamination.
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;
*/

/* SELECT COUNT(*) 
FROM well_pollution
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);
*/