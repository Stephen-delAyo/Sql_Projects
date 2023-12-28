-- Start by joining location to visits.
/* SELECT 
	loc.province_name,
    loc.town_name,
    v.visit_count,
	v.location_id
FROM visits AS v
JOIN location AS loc
ON v.location_id = loc.location_id;
*/

-- Now, we can join the water_source table on the key shared between water_source and visits.
/* SELECT
	loc.province_name,
    loc.town_name,
    v.visit_count,
	v.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM visits AS v
JOIN location AS loc ON v.location_id = loc.location_id
JOIN water_source AS ws ON ws.source_id = v.source_id;
*/ 

-- Note that there are rows where visit_count > 1. These were the sites our surveyors collected additional information for, but they happened at the
-- same source/location. For example, add this to your query: WHERE visits.location_id = 'AkHa00103'
/* SELECT
	loc.province_name,
    loc.town_name,
    v.visit_count,
	v.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM visits AS v
JOIN location AS loc ON v.location_id = loc.location_id
JOIN water_source AS ws ON ws.source_id = v.source_id
WHERE v.location_id = 'AkHa00103';
*/

-- There you can see what I mean. For one location, there are multiple AkHa00103 records for the same location. If we aggregate, we will include
-- these rows, so our results will be incorrect. To fix this, we can just select rows where visits.visit_count = 1.	
-- Remove WHERE visits.location_id = 'AkHa00103' and add the visits.visit_count = 1 as a filter.
/* SELECT
	loc.province_name,
    loc.town_name,
    v.visit_count,
	v.location_id,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM visits AS v
JOIN location AS loc ON v.location_id = loc.location_id
JOIN water_source AS ws ON ws.source_id = v.source_id
WHERE v.visit_count = 1;
*/

-- Ok, now that we verified that the table is joined correctly, we can remove the location_id and visit_count columns.
/* SELECT
	loc.province_name,
    loc.town_name,
    ws.type_of_water_source,
    ws.number_of_people_served
FROM visits AS v
JOIN location AS loc ON v.location_id = loc.location_id
JOIN water_source AS ws ON ws.source_id = v.source_id
WHERE v.visit_count = 1;
*/

-- Add the location_type column from location and time_in_queue from visits to our results set.
/* SELECT
	loc.province_name,
    loc.town_name,
    ws.type_of_water_source,
    loc.location_type,
    ws.number_of_people_served,
    v.time_in_queue
FROM visits AS v
JOIN location AS loc ON v.location_id = loc.location_id
JOIN water_source AS ws ON ws.source_id = v.source_id
WHERE v.visit_count = 1;
*/

-- Last one! Now we need to grab the results from the well_pollution table.
-- This one is a bit trickier. The well_pollution table contained only data for well. If we just use JOIN, we will do an inner join, so that only records
-- that are in well_pollution AND visits will be joined. We have to use a LEFT JOIN to join theresults from the well_pollution table for well
-- sources, and will be NULL for all of the rest. Play around with the different JOIN operations to make sure you understand why we used LEFT JOIN.
-- This table assembles data from different tables into one to simplify analysis
/* SELECT
	water_source.type_of_water_source,
	location.town_name,
	location.province_name,
	location.location_type,
	water_source.number_of_people_served,
	visits.time_in_queue,
	well_pollution.results
FROM visits
LEFT JOIN well_pollution ON well_pollution.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1;
*/

-- So this table contains the data we need for this analysis. Now we want to analyse the data in the results set. We can either create a CTE, and then
-- query it, or in my case, I'll make it a VIEW so it is easier to share with you. I'll call it the combined_analysis_table.
/* CREATE VIEW combined_analysis_table AS  -- This view assembles data from different tables into one to simplify analysis
SELECT
	water_source.type_of_water_source AS source_type,
	location.town_name,
	location.province_name,
	location.location_type,
	water_source.number_of_people_served AS people_served,
	visits.time_in_queue,
	well_pollution.results
FROM visits
LEFT JOIN well_pollution ON well_pollution.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id
INNER JOIN water_source ON water_source.source_id = visits.source_id
WHERE visits.visit_count = 1;
-- This view creates a "table" that pulls all of the important information from different tables into one. You may notice our query is starting to slow
-- down because it involves a lot of steps, and runs on 60000 rows of data.*/

-- We're building another pivot table! This time, we want to break down our data into provinces or towns and source types. If we understand where
-- the problems are, and what we need to improve at those locations, we can make an informed decision on where to send our repair teams.
/* WITH province_totals AS (    -- This CTE calculates the population of each province
SELECT
	province_name,
	SUM(people_served) AS total_ppl_serv
FROM 
	combined_analysis_table
GROUP BY 
	province_name
)
SELECT
	ct.province_name,
-- These case statements create columns for each type of source.
-- The results are aggregated and percentages are calculated
	ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / pt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN
	province_totals pt ON ct.province_name = pt.province_name
GROUP BY
	ct.province_name
ORDER BY
	ct.province_name;
*/

-- Let's aggregate the data per town now. You might think this is simple, but one little town makes this hard. Recall that there are two towns in Maji
-- Ndogo called Harare. One is in Akatsi, and one is in Kilimani. Amina is another example. So when we just aggregate by town, SQL doesn't distin-
-- guish between the different Harare's, so it combines their results.
-- To get around that, we have to group by province first, then by town, so that the duplicate towns are distinct because they are in different towns.
/* WITH town_totals AS ( -- This CTE calculates the population of each town −− Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
	ct.province_name,
	ct.town_name,
	ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name           -- Since the town names are not unique, we have to join on a composite key
GROUP BY     -- We group by province first, then by town.
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;
*/

-- Temporary tables in SQL are a nice way to store the results of a complex query. We run the query once, and the results are stored as a table. The
-- catch? If you close the database connection, it deletes the table, so you have to run it again each time you start working in MySQL. The benefit is
-- that we can use the table to do more calculations, without running the whole query each time.
/* CREATE TEMPORARY TABLE town_aggregated_water_access
WITH town_totals AS ( -- This CTE calculates the population of each town −− Since there are two Harare towns, we have to group by province_name and town_name
SELECT province_name, town_name, SUM(people_served) AS total_ppl_serv
FROM combined_analysis_table
GROUP BY province_name,town_name
)
SELECT
	ct.province_name,
	ct.town_name,
	ROUND((SUM(CASE WHEN source_type = 'river' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS river,
	ROUND((SUM(CASE WHEN source_type = 'shared_tap' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS shared_tap,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home,
	ROUND((SUM(CASE WHEN source_type = 'tap_in_home_broken' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS tap_in_home_broken,
	ROUND((SUM(CASE WHEN source_type = 'well' THEN people_served ELSE 0 END) * 100.0 / tt.total_ppl_serv), 0) AS well
FROM
	combined_analysis_table ct
JOIN town_totals tt ON ct.province_name = tt.province_name AND ct.town_name = tt.town_name           -- Since the town names are not unique, we have to join on a composite key
GROUP BY     -- We group by province first, then by town.
	ct.province_name,
	ct.town_name
ORDER BY
	ct.town_name;
*/

/*SELECT *
FROM town_aggregated_water_access;*/

/* SELECT
	province_name,
	town_name,
	ROUND(tap_in_home_broken / (tap_in_home_broken + tap_in_home) * 100,0) AS Pct_broken_taps
FROM
	town_aggregated_water_access
*/

/*CREATE TABLE Project_progress (
	Project_id SERIAL PRIMARY KEY,
	source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
	Address VARCHAR(50),
	Town VARCHAR(30),
	Province VARCHAR(30),
	Source_type VARCHAR(50),
	Improvement VARCHAR(50),
	Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
	Date_of_completion DATE,
	Comments TEXT
);*/
-- The explanation to the above query
/* This query creates the Project_progress table:
CREATE TABLE Project_progress (
Project_id SERIAL PRIMARY KEY,
Project_id −− Unique key for sources in case we visit the same

source more than once in the future.

source_id VARCHAR(20) NOT NULL REFERENCES water_source(source_id) ON DELETE CASCADE ON UPDATE CASCADE,
source_id −− Each of the sources we want to improve should exist,

and should refer to the source table. This ensures data integrity.

Address VARCHAR(50), −− Street address
Town VARCHAR(30),
Province VARCHAR(30),
Source_type VARCHAR(50),
Improvement VARCHAR(50), −− What the engineers should do at that place
Source_status VARCHAR(50) DEFAULT 'Backlog' CHECK (Source_status IN ('Backlog', 'In progress', 'Complete')),
Source_status −− We want to limit the type of information engineers can give us, so we
limit Source_status.
− By DEFAULT all projects are in the "Backlog" which is like a TODO list.
− CHECK() ensures only those three options will be accepted. This helps to maintain clean data.

Date_of_completion DATE, −− Engineers will add this the day the source has been upgraded.
Comments TEXT −− Engineers can leave comments. We use a TEXT type that has no limit on char length
);
*/

/* -- SLIDES 29 & 30
SELECT
	location.address,
	location.town_name,
	location.province_name,
	water_source.source_id,
	water_source.type_of_water_source,
	well_pollution.results
FROM
	water_source
LEFT JOIN well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN visits ON water_source.source_id = visits.source_id
INNER JOIN location ON location.location_id = visits.location_id; */

-- SLIDE 33
/* SELECT
	location.address,
	location.town_name,
	location.province_name,
	water_source.source_id,
	water_source.type_of_water_source,
	well_pollution.results
FROM
	water_source
LEFT JOIN
	well_pollution 
ON water_source.source_id = well_pollution.source_id
INNER JOIN
	visits 
ON water_source.source_id = visits.source_id
INNER JOIN
	location 
    ON location.location_id = visits.location_id
WHERE 
	visit_count = 1 
    AND( results != 'Clean'
		OR  type_of_water_source IN ('tap_in_home_broken','river')
			OR type_of_water_source = 'shared_tap' AND time_in_queue >= 30);
*/

-- SLIDE 34
/*SELECT
    location.address,
    location.town_name,
    location.province_name,
    water_source.source_id,
    water_source.type_of_water_source,
    well_pollution.results,
    CASE
        WHEN well_pollution.results = 'Contaminated: Biological' THEN 'Install UV filter'
        WHEN well_pollution.results = 'Contaminated: Chemical' THEN 'Install RO filter'
        WHEN water_source.type_of_water_source = 'river' THEN 'Drill well'
        ELSE NULL
    END AS Improvement
FROM
    water_source
LEFT JOIN
    well_pollution ON water_source.source_id = well_pollution.source_id
INNER JOIN
    visits ON water_source.source_id = visits.source_id
INNER JOIN
    location ON location.location_id = visits.location_id
WHERE
    visits.visit_count = 1
    AND (
        well_pollution.results NOT LIKE 'Clean'
        OR water_source.type_of_water_source IN ('tap_in_home_broken','river')
        OR (water_source.type_of_water_source = 'shared_tap' AND time_in_queue >= 30)
    );
*/