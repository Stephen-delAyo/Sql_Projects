-- DROP TABLE IF EXISTS `auditor_report`;

/* CREATE TABLE `auditor_report` (
`location_id` VARCHAR(32),
`type_of_water_source` VARCHAR(64),
`true_water_source_score` int DEFAULT NULL,
`statements` VARCHAR(255)
);
*/

-- SELECT COUNT(*)
-- FROM auditor_report;

/*SELECT location_id, true_water_source_score
FROM auditor_report;
OR
-- This method is long journey tho
 -- compare the quality scores in the water_quality table to the auditor's scores.
-- grab the location_id and true_water_source_score columns from auditor_report.
SELECT ar.location_id, ar.true_water_source_score
FROM auditor_report AS ar
JOIN visits AS v 
ON ar.location_id = v.location_id;
*/ 

/* -- Now, we join the visits table to the auditor_report table. Make sure to grab subjective_quality_score, record_id and location_id.
SELECT auditor_report.location_id AS audit_location,
	   auditor_report.true_water_source_score,
	   visits.location_id AS visit_location,
	   visits.record_id
FROM auditor_report
JOIN visits
ON auditor_report.location_id = visits.location_id;
*/

-- retrieve the corresponding scores from the water_quality table. We
-- are particularly interested in the subjective_quality_score. To do this, we'll JOIN the visits table and the water_quality table, using the
-- record_id as the connecting key.
/* SELECT ar.location_id AS audit_location,
       ar.true_water_source_score,
       v.location_id AS visit_location,
       v.record_id,
       wq.subjective_quality_score
FROM 
	   auditor_report AS ar
JOIN 
	   visits AS v ON ar.location_id = v.location_id
JOIN 
	   water_quality AS wq ON v.record_id = wq.record_id;
*/

-- It doesn't matter if your columns are in a different format, because we are about to clean this up a bit. Since it is a duplicate, we can drop one of 
-- the location_id columns. Let's leave record_id and rename the scores to surveyor_score and auditor_score to make it clear which scores
-- we're looking at in the results set.
/* SELECT
    ar.location_id AS record_id,
    ar.true_water_source_score AS auditor_score,
    v.location_id AS visit_location,
    v.record_id,
    wq.subjective_quality_score AS surveyor_score
FROM
    auditor_report AS ar
JOIN
    visits AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id;

-- In this updated query, we have retained only one "location_id" column (aliased as "record_id") and renamed the scores as "auditor_score" and "surveyor_score" for clarity in the result set. 
*/

/*-- Ok, let's analyse! A good starting point is to check if the auditor's and exployees' scores agree. There are many ways to do it. We can have a
-- WHERE clause and check if surveyor_score = auditor_score, or we can subtract the two scores and check if the result is 0.
-- USING THE WHERE CLAUSE
SELECT
    ar.location_id AS record_id,
    ar.true_water_source_score AS auditor_score,
    v.location_id AS visit_location,
    v.record_id,
    wq.subjective_quality_score AS surveyor_score
FROM
    auditor_report AS ar
JOIN
    visits AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
WHERE
    ar.true_water_source_score = wq.subjective_quality_score;

-- SUBTRACT THE SCORES AND CHECK IF THE RESULT IS ZERO
SELECT
    ar.location_id AS record_id,
    ar.true_water_source_score AS auditor_score,
    v.location_id AS visit_location,
    v.record_id,
    wq.subjective_quality_score AS surveyor_score
FROM
    auditor_report AS ar
JOIN
    visits AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
WHERE
    ar.true_water_source_score - wq.subjective_quality_score = 0;
-- Both queries will give you the rows where the auditor's and surveyor's scores agree. 
*/

-- You got 2505 rows right? Some of the locations were visited multiple times, so these records are duplicated here. To fix it, we set visits.visit_count = 1 in the WHERE clause. Make sure you reference the alias you used for visits in the join.
-- This query will give you rows where the auditor's and surveyor's scores agree while removing duplicates for locations visited multiple times, with visits.visit_count = 1. 
-- The alias "v" for the "visits" table is correctly referenced in the join and the WHERE clause.
/* SELECT
    ar.location_id AS record_id,
    ar.true_water_source_score AS auditor_score,
    v.location_id AS visit_location,
    v.record_id,
    wq.subjective_quality_score AS surveyor_score
FROM
    auditor_report AS ar
JOIN
    (SELECT * FROM visits WHERE visit_count = 1) AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
WHERE
    ar.true_water_source_score = wq.subjective_quality_score;
*/

/* -- Here, i counted the number of records after removing the duplicates with the above query
SELECT COUNT(*)
FROM (
    SELECT
        ar.location_id AS audit_location,
        ar.true_water_source_score AS auditor_score,
        v.location_id AS visit_location,
        v.record_id AS record_id_auditor,
        wq.subjective_quality_score AS surveyor_score
    FROM
        auditor_report AS ar
    JOIN
        (SELECT * FROM visits WHERE visit_count = 1) AS v ON ar.location_id = v.location_id
    JOIN
        water_quality AS wq ON v.record_id = wq.record_id
    WHERE
        ar.true_water_source_score = wq.subjective_quality_score
) AS subquery;
*/


/* -- This query will return the records where the auditor's and surveyor's scores do not agree, helping you identify the 102 records that are incorrect.
SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    v.location_id AS visit_location,
    v.record_id AS record_id_auditor,
    wq.subjective_quality_score AS surveyor_score
FROM
    auditor_report AS ar
JOIN
    (SELECT * FROM visits WHERE visit_count = 1) AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
WHERE
    ar.true_water_source_score <> wq.subjective_quality_score;
*/

-- So, to do this, we need to grab the type_of_water_source column from the water_source table and call it survey_source, using the
-- source_id column to JOIN. Also select the type_of_water_source from the auditor_report table, and call it auditor_source.
/* SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    ar.type_of_water_source AS auditor_source,
    v.location_id AS visit_location,
    v.record_id AS record_id,
    wq.subjective_quality_score AS surveyor_score,
    ws.type_of_water_source AS survey_source
FROM
    auditor_report AS ar
JOIN
    (SELECT * FROM visits WHERE visit_count = 1) AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
JOIN
    water_source AS ws ON v.source_id = ws.source_id
WHERE
    ar.true_water_source_score <> wq.subjective_quality_score;


-- Once you're done, remove the columns and JOIN statement for water_sources again.
/* SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    ar.type_of_water_source AS auditor_source,
    v.location_id AS visit_location,
    v.record_id AS record_id,
    wq.subjective_quality_score AS surveyor_score
FROM
    auditor_report AS ar
JOIN
    (SELECT * FROM visits WHERE visit_count = 1) AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
WHERE
    ar.true_water_source_score <> wq.subjective_quality_score;
*/

-- JOIN the assigned_employee_id for all the people on our list from the visits
-- table to our query. Remember, our query shows the 102 incorrect records, so when we join the employee data, we can see which
-- employees made these incorrect records.
/* SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    ar.type_of_water_source AS auditor_source,
    v.record_id AS record_id,
    v.assigned_employee_id AS employee_id
FROM
    auditor_report AS ar
JOIN
    (SELECT * FROM visits WHERE visit_count = 1) AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
JOIN
    water_source AS ws ON v.source_id = ws.source_id
WHERE
    ar.true_water_source_score <> wq.subjective_quality_score;
*/

-- So now we can link the incorrect records to the employees who recorded them. The ID's don't help us to identify them. We have employees' names
-- stored along with their IDs, so let's fetch their names from the employees table instead of the ID's.
/* SELECT
    ar.location_id AS audit_location,
    ar.true_water_source_score AS auditor_score,
    ar.type_of_water_source AS auditor_source,
    e.employee_name AS employee_name,
    v.record_id AS record_id,
    v.assigned_employee_id AS employee_id
FROM
    auditor_report AS ar
JOIN
    (SELECT * FROM visits WHERE visit_count = 1) AS v ON ar.location_id = v.location_id
JOIN
    water_quality AS wq ON v.record_id = wq.record_id
JOIN
    water_source AS ws ON v.source_id = ws.source_id
JOIN 
	employee AS e ON e.assigned_employee_id = v.assigned_employee_id
WHERE
    ar.true_water_source_score <> wq.subjective_quality_score;
*/


-- Well this query is massive and complex, so maybe it is a good idea to save this as a CTE, so when we do more analysis, we can just call that CTE like it was a table. 
-- Call it something like Incorrect_records. Once you are done, check if this query SELECT * FROM Incorrect_records, gets the same table back.
-- Now that we defined Incorrect_records, we can query it like any other table.
-- Let's first get a unique list of employees from this table.
-- Define the CTE "Incorrect_records"
/* WITH incorrect_records AS (
  SELECT
   auditor_report.location_id AS audit_location,
   auditor_report.true_water_source_score AS auditor_score,
   visits.record_id,
   auditor_report.type_of_water_source AS auditor_source,
   employee.employee_name AS employee_name,
   employee.assigned_employee_id AS employee_id
FROM
   auditor_report
JOIN (SELECT * FROM visits WHERE visit_count = '1') AS visits ON auditor_report.location_id = visits.location_id
JOIN
   water_quality
ON water_quality.record_id = visits.record_id
JOIN
  employee
ON  employee.assigned_employee_id = visits.assigned_employee_id

WHERE
  true_water_source_score <> subjective_quality_score
  )
SELECT * FROM incorrect_records;


-- Next, let's try to calculate how many mistakes each employee made. So basically we want to count how many times their name is in Incorrect_records list, and then group them by name, right?
SELECT
    e.employee_name AS employee_name,
    COUNT(e.assigned_employee_id) AS number_of_mistakes
FROM
    auditor_report ar
JOIN
    (SELECT * FROM visits WHERE visit_count = '1') v ON ar.location_id = v.location_id
JOIN
    water_quality wq ON wq.record_id = v.record_id
JOIN
    employee e ON e.assigned_employee_id = v.assigned_employee_id
WHERE
    ar.true_water_source_score <> wq.subjective_quality_score
GROUP BY
    e.assigned_employee_id;
*/


-- SOLUTION TO SLIDES 19 & 20
/* CREATE VIEW Incorrect_records AS (
SELECT
	auditor_report.location_id,
	visits.record_id,
	employee.employee_name,
	auditor_report.true_water_source_score AS auditor_score,
	wq.subjective_quality_score AS employee_score,
	auditor_report.statements AS statements
FROM auditor_report
JOIN
	visits ON auditor_report.location_id = visits.location_id
JOIN
	water_quality AS wq ON visits.record_id = wq.record_id
JOIN
	employee ON employee.assigned_employee_id = visits.assigned_employee_id
WHERE visits.visit_count =1
AND auditor_report.true_water_source_score != wq.subjective_quality_score);
-- Now, calling SELECT * FROM Incorrect_records gives us the same result as the CTE did.
SELECT * FROM Incorrect_records;
*/

/*-- SLIDE 21
-- Next, we convert the query error_count, we made earlier, into a CTE. Test it to make sure it gives the same result again, using SELECT * FROM Incorrect_records. 
-- On large queries like this, it is better to build the query, and test each step, because fixing errors becomes harder as the query grows.
WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT employee_name,
	   COUNT(employee_name) AS number_of_mistakes
FROM 
	Incorrect_records    -- Incorrect_records is a view that joins the audit report to the database for records where the auditor and employees scores are different                   
GROUP BY
	employee_name)
-- Query
SELECT * FROM error_count;
*/

-- Now calculate the average of the number_of_mistakes in error_count. You should get a single value.
/* WITH error_count AS (
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        employee_name
)
SELECT AVG(number_of_mistakes) AS avg_error_count
FROM error_count;
*/

-- SLIDE 22
-- To find the employees who made more mistakes than the average person, we need the employee's names, the number of mistakes each one made, and filter the employees with an above-average number of mistakes.
-- HINT: Use SELECT AVG(mistake_count) FROM error_count as a custom filter in the WHERE part of our query.
/* WITH error_count AS (
    SELECT
        employee_name,
        COUNT(employee_name) AS number_of_mistakes
    FROM
        Incorrect_records
    GROUP BY
        employee_name
)
SELECT
    ec.employee_name,
    ec.number_of_mistakes
FROM
    error_count AS ec
WHERE
    ec.number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count);*/ 
-- In the above query:
-- We define the "error_count" CTE to calculate the number of mistakes made by each employee.
-- In the main query, we select employee names and the number of mistakes from the "error_count" CTE.
-- In the WHERE clause, we filter the results to include only those employees with a number of mistakes greater than the average number of mistakes calculated using the subquery.
-- This query will give you the names and the number of mistakes for employees who made more mistakes than the average person.

-- SLIDE 23
-- Firstly, let's add the statements column to the Incorrect_records CTE. Then pull up all of the records where the employee_name is in the
-- suspect list. HINT: Use SELECT employee_name FROM suspect_list as a subquery in WHERE.
/* WITH error_count AS ( -- This CTE calculates the number of mistakes each employee made
SELECT
	employee_name,
	COUNT(employee_name) AS number_of_mistakes
FROM
	Incorrect_records
GROUP BY
	employee_name),
	suspect_list AS (-- This CTE SELECTS the employees with above−average mistakes
SELECT
	employee_name,
	number_of_mistakes
FROM
	error_count
WHERE
	number_of_mistakes > (SELECT AVG(number_of_mistakes) FROM error_count))
-- This query filters all of the records where the "corrupt" employees gathered data.
SELECT
	employee_name,
	location_id,
	statements
FROM
	Incorrect_records
WHERE
	employee_name in (SELECT employee_name FROM suspect_list);
*/

/* -- Filter records with statements containing the word "cash"
SELECT
    employee_name,
    location_id,
    statements
FROM
    Incorrect_records
WHERE
    statements LIKE '%cash%';
*/



/* SELECT 
	employee_name,
    statements
FROM 
	Incorrect_records
WHERE 
	statements LIKE '%Suspicion%';
*/    