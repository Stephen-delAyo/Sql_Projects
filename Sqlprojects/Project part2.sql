-- SELECT * 
-- FROM data_dictionary;

-- SHOW TABLES;

-- SELECT employee_name
-- FROM employee

-- SELECT REPLACE(employee_name, ' ','.') -- Replace the space with a full stop
-- FROM employee;

/*The provided SQL query is used to manipulate the "employee_name" column data from the "employee" table. Here's an explanation of what the query does:
1. `SELECT`: This is the SQL statement that retrieves data from the database.
2. `LOWER()`: This is a string function that converts all characters in a string to lowercase. In this case, it is applied to the result of the `REPLACE()` function to ensure that the output is in lowercase.
3. `REPLACE(employee_name, ' ','.')`: This is another string function. It replaces all spaces (' ') in the "employee_name" column with periods ('.'). For example, if "employee_name" contains "John Doe," this function would replace the space with a period, resulting in "John.Doe."
So, the query processes the "employee_name" column values by first replacing spaces with periods and then converting the entire result to lowercase. The query will return the modified "employee_name" values in all lowercase letters with spaces replaced by periods.
For example, if you have an "employee_name" like "John Doe," the query will return "john.doe."
*/
-- SELECT LOWER(REPLACE(employee_name, ' ','.')) -- Make it all lower case
-- FROM employee;

-- We then use CONCAT() to add the rest of the email address:
-- SELECT CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), '@ndogowater.gov') AS new_email -- add it all together
-- FROM employee;

-- Quick win! Since you have done this before, you can go ahead and UPDATE the email column this time with the email addresses. Just make sure to check if it worked!
/*UPDATE employee
SET email = CONCAT(LOWER(REPLACE(employee_name, ' ', '.')), 
			'@ndogowater.gov')
*/            
  
-- SELECT LENGTH(phone_number)  -- Here, i wanted to know the length of the phone numbers
-- FROM employee;               -- This query returns 13 characters which shows that there is an extra character. You should TRIM this

-- SELECT TRIM(BOTH FROM phone_number) AS cleaned_phone_number
-- FROM employee;

-- SELECT LENGTH(phone_number)
-- FROM employee;

-- SELECT TRIM(phone_number) AS trimmed_phone_number
-- FROM employee;

-- SELECT TRIM(phone_number) AS trimmed_phone_number
-- FROM employee;

/*SELECT phone_number, 
	TRIM(phone_number) as trimmed_phone_number
FROM employee;
*/

/*SELECT 
  phone_number, 
  ASCII(SUBSTRING(phone_number, 1, 1)) as ascii_value_first_char,
  ASCII(SUBSTRING(phone_number, -1, 1)) as ascii_value_last_char
FROM 
  employee;
*/

/* SELECT town_name,  -- Use the employee table to count how many of our employees live in each town.
		COUNT(employee_name) Number_of_employees
FROM employee
GROUP BY town_name;
*/

/*SELECT assigned_employee_id, COUNT(*) AS number_of_visits  -- Let's first look at the number of records each employee collected. So find the correct table, figure out what function to use and how to group, orderand limit the results to only see the top 3 employee_ids with the highest number of locations visited.
FROM visits
WHERE assigned_employee_id IN (0, 1, 2)
GROUP BY assigned_employee_id;
*/

/*Now, i want you to make a note of the top 3 assigned_employee_id and use them to create a query that looks up the employee's info. 
Since you're a pro at findingstuff in a database now, you can figure this one out. You should have a column of names, email addresses and phone numbers for our top dogs.
To achieve this, you'll need to execute two SQL queries: 
one to retrieve the top 3 assigned_employee_id with the highest number of locations visited, 
and another to fetch the detailed information (names, email addresses, phone numbers) of these employees.*/
-- QUERY 1
/*SELECT assigned_employee_id
FROM visits
GROUP BY assigned_employee_id
ORDER BY COUNT(*) DESC
LIMIT 3;*/
-- QUERY 2 which involves using the ID's fetched from the above query to retrieve the employees details
/*SELECT employee_name, email, phone_number
FROM employee                                  -- This syntax did not work for me bcos mt version of MySQL does nt yet support LIMIT & IN/ALL/ANY/SOME subquery. So i am going to create a view and use JOINS
WHERE assigned_employee_id IN (SELECT assigned_employee_id
                      FROM visits
                      GROUP BY assigned_employee_id
                      ORDER BY COUNT(*) DESC
                      LIMIT 3);
*/

-- Used view and JOIN to identify the top 3 assigned_employee_id and use them to create a query that looks up the employee's info.
/*CREATE VIEW TopEmployees AS
SELECT assigned_employee_id
FROM visits
GROUP BY assigned_employee_id
ORDER BY COUNT(*) DESC
LIMIT 3;
--------------------------
SELECT e.employee_name, e.email, e.phone_number
FROM employee e
INNER JOIN TopEmployees te ON e.assigned_employee_id = te.assigned_employee_id;
*/

-- Looking at the location table, let’s focus on the province_name, town_name and location_type to understand where the water sources are in Maji Ndogo.
-- Create a query that counts the number of records per town
/*SELECT town_name, COUNT(*) AS records_per_town
FROM location
WHERE province_name = 'Maji Ndogo'
GROUP BY town_name
ORDER BY records_per_town DESC;
*/

/*SELECT province_name, COUNT(*) AS records_per_province
FROM location
WHERE location_type = 'Water Source'
GROUP BY province_name;
*/

/* 1. Create a result set showing:
• province_name
• town_name
• An aggregated count of records for each town (consider naming this records_per_town).
• Ensure your data is grouped by both province_name and town_name.
2. Order your results primarily by province_name. Within each province, further sort the towns by their record counts in descending order.

SELECT province_name, town_name, COUNT(*) AS records_per_town
FROM location
GROUP BY province_name, town_name
ORDER BY province_name, records_per_town DESC;

THE EXPLANATION FOR THE ABOVE QUERY IS:
SELECT province_name, town_name, COUNT(*) AS records_per_town: This part of the statement specifies that we want to retrieve the name of each province and town, along with the total count of records for each town (named "records_per_town"). The COUNT(*) function calculates the number of records for each group created by the GROUP BY clause.
FROM location: Specifies the "location" table from which to retrieve the records.
GROUP BY province_name, town_name: This clause groups the selected records first by "province_name" and then by "town_name", which means the COUNT(*) function will count the number of records for each unique combination of province and town.
ORDER BY province_name, records_per_town DESC: This clause orders the results first by "province_name" in ascending order (the default), and within each province, it sorts the towns based on their record counts in descending order.
The result will be a list of provinces, with towns within those provinces ordered by the number of records, from most to least. This aligns with the requirements specified.

-- Finally, look at the number of records for each location type
SELECT location_type, COUNT(*) AS number_of_records
FROM location
GROUP BY location_type;
----------------------------------
SELECT 23740 / (15910 + 23740) * 100
*/

-- SELECT *
-- FROM water_source;

/* Number of people that were surveyed in total. 39650
SELECT COUNT(*) AS total_people_surveyed
FROM water_source;
*/

/* How many wells, taps and rivers are there?
count how many of each of the different water source types there are, and remember to sort them.
The explanation behind the query:
SELECT type_of_water_source, COUNT(*) AS number_of_sources: This tells the database to count all rows grouped by the "type_of_water_source" and to label this count as "number_of_sources."
FROM water_source: Specifies the "water_source" table from which to pull the data.
GROUP BY type_of_water_source: Groups the count results by each unique "type_of_water_source."
ORDER BY number_of_sources DESC: Orders the results by "number_of_sources" in descending order so that the type with the most occurrences appears first.
This query will return a list of water source types along with the count of how many times each appears in the "water_source" table, sorted from the most frequent to the least [3, 6].
---------------------------------------------------------------------------------
SELECT type_of_water_source, COUNT(*) AS number_of_sources
FROM water_source
GROUP BY type_of_water_source
ORDER BY number_of_sources DESC;
*/

/* What is the average number of people that are served by each water source? Remember to make the numbers easy to read.
The explanation of the query:
SELECT type_of_water_source, FORMAT(AVG(number_of_people_served), 0) AS average_people_served: This part of the statement specifies that we want to select the type of water source, and for each type, calculate the average number of people served. The FORMAT function is used here to round the average number to the nearest whole number, making it easier to read.
FROM water_source: This specifies the "water_source" table from which to retrieve the data.
GROUP BY type_of_water_source: This groups the data by the "type_of_water_source," meaning the average will be calculated separately for each type of water source.
This query will return a list of water source types along with the average number of people served by each, with the numbers formatted as whole numbers for readability. Please note that the specific formatting function and its syntax might vary depending on the SQL database you're using
------------------------------------------------------------------------------------
SELECT type_of_water_source, 
       FORMAT(AVG(number_of_people_served), 0) AS average_people_served
FROM water_source
GROUP BY type_of_water_source;
*/


/* -- Now let’s calculate the total number of people served by each type of water source in total, to make it easier to interpret, order them so the most people served by a source is at the top.
SELECT type_of_water_source, 
       SUM(number_of_people_served) AS total_people_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY total_people_served DESC;
*/

/*Get the percentage out of the total number of people survery(27,628,140) of people per source
Explanation:
SUM(number_of_people_served) calculates the total number of people served by each water source type.
The total number of people served by each type is then divided by 27,628,140 (the total number of people surveyed) to find the proportion.
This proportion is multiplied by 100 to convert it into a percentage.
The ROUND function is used to limit the result to two decimal places for readability.
GROUP BY type_of_water_source groups the results by the type of water source.
ORDER BY percentage_served DESC ensures that the list is ordered from the highest percentage to the lowest.
This query will give you the percentage of the surveyed population served by each type of water source, presented in a sorted list from the most served to the least
--------------------------------------------------------------------------------------------
SELECT type_of_water_source, 
       ROUND((SUM(number_of_people_served) / 27628140) * 100, 2) AS percentage_people_per_source
FROM water_source
GROUP BY type_of_water_source
ORDER BY percentage_people_per_source DESC;
*/

/* -- Round off the above decimals to 0
SELECT type_of_water_source, 
       ROUND((SUM(number_of_people_served) / 27628140) * 100, 0) AS percentage_served
FROM water_source
GROUP BY type_of_water_source
ORDER BY percentage_served DESC;
*/

-- SELECT CONCAT(day(time_of_record), " ", monthname(time_of_record), " ", year(time_of_record)) 
-- FROM visits;

/* Write a query that ranks each type of source based on how many people in total use it. RANK() should tell you we are going to need a window function to do this, so let's think through the problem.
We will need the following columns:
- Type of sources 
- Total people served grouped by the types 
- A rank based on the total people served, grouped by the types
Explanation:
type_of_water_source: is selected so we know which type of water source each record pertains to.
SUM(number_of_people_served) AS total_people_served: calculates the total number of people served for each type of water source.
RANK() OVER (ORDER BY SUM(number_of_people_served) DESC): assigns a rank to each type of water source based on the total number of people served, with the source serving the most people ranked first.
GROUP BY type_of_water_source: ensures the aggregation is done for each unique type of water source
----------------------------------------------------------------------
SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS total_people_served,
    RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) as Rank_by_population
FROM water_source
GROUP BY type_of_water_source;
*/

/* -- Remove tap_in_home from the ranking. 
-- So use a window function on the total people served column, converting it into a rank.
Explanation:
The WHERE clause: is used to exclude records where the type_of_water_source is 'tap_in_home'.
type_of_water_source: is selected so we know which type of water source each record pertains to.
SUM(number_of_people_served) AS total_people_served: calculates the total number of people served for each type of water source, excluding 'tap_in_home'.
RANK() OVER (ORDER BY SUM(number_of_people_served) DESC): assigns a rank to each type of water source based on the total number of people served, with the source serving the most people ranked first. This is done after 'tap_in_home' types have been excluded.
GROUP BY type_of_water_source: ensures the aggregation is done for each unique type of water source, not including 'tap_in_home' [3], [6].
This query will give you a list of water source types (excluding 'tap_in_home'), the total number of people each serves, and a ranking, with 1 being the type that serves the most people.
---------------------------------------------------
SELECT 
    type_of_water_source,
    SUM(number_of_people_served) AS total_people_served,
    RANK() OVER (ORDER BY SUM(number_of_people_served) DESC) as Rank_by_population
FROM water_source
WHERE type_of_water_source != 'tap_in_home'
GROUP BY type_of_water_source;
*/

/* Fix shared taps first, then wells, and so on. 
But the next question is, which shared taps or wells should be fixed first? We can use the same logic; the most used sources should really be fixed first.
So create a query to do this, and keep these requirements in mind:
1. The sources within each type should be assigned a rank.
2. Limit the results to only improvable sources.
3. Think about how to partition, filter and order the results set.
4. Order the results to see the top of the list.

----------------------------------------------------------
SELECT: This statement is used to specify the data you want to fetch from the database. In this case, you're retrieving the source_id, type_of_water_source, and number_of_people_served columns from the water_source table.
RANK() OVER (PARTITION BY type_of_water_source ORDER BY number_of_people_served DESC): This function is a window function that assigns a rank to each row within the partition of a result set. The rank is calculated based on the number_of_people_served in descending order, so a higher number means a higher rank. The partitioning is done by type_of_water_source, which means the ranking starts over for each different type_of_water_source. This is crucial as it allows the query to rank sources independently within each type of water source.
FROM water_source: This clause specifies the table from which to retrieve the data.
ORDER BY usage_rank, type_of_water_source: This clause is used to sort the data being returned. First, it sorts the data by usage_rank in ascending order (by default), so you'll see the water source serving the most people at the top of each water source type. After that, it sorts by type_of_water_source, though the primary sort is effectively the usage_rank due to its position in the ORDER BY clause.
The query effectively ranks water sources within each category based on how many people they serve, helping prioritize which water sources are utilized the most.
---------------------------------------------------------------------------------------------
SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served,
    RANK() OVER (
        PARTITION BY type_of_water_source 
        ORDER BY number_of_people_served DESC
    ) as usage_rank
FROM water_source
ORDER BY usage_rank, 
		 type_of_water_source;
*/


/*-- Try the different ranking functions in queries.
-- That is the DENSE_RANK() and the ROW_NUMBER() functions.
-- USING THE DENSE_RANK FUNCTION
---------------------------------------------------
The DENSE_RANK() function works similarly to RANK() 
but it doesn't skip any ranks if there's a tie (rank "gap" doesn't occur). 
This means that if two rows hold the second highest number of people served, they both get a dense rank of 2, and the next rank issued would be 3, not 4 as it would be with RANK().
--------------------------------------------------------
SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served,
    DENSE_RANK() OVER (
        PARTITION BY type_of_water_source 
        ORDER BY number_of_people_served DESC
    ) as usage_dense_rank
FROM water_source
ORDER BY usage_dense_rank, 
		 type_of_water_source;
*/

/*-- USING THE ROW_NUMBER FUNCTION
-------------------------------------------------------------
The ROW_NUMBER() function assigns a unique number to each row within its partition, regardless of ties. 
This means that if two rows hold the same number of people served, one will arbitrarily get a row number of, for instance, 3, and the other 4. 
There's no concept of a "tie" with ROW_NUMBER(); every row gets a unique number within its partition.
Both of these functions provide a unique way of ranking your data, and the choice between them depends on how you need to handle ties in your data set.
-----------------------------------------------------------------
SELECT 
    source_id,
    type_of_water_source,
    number_of_people_served,
    ROW_NUMBER() OVER (
        PARTITION BY type_of_water_source 
        ORDER BY number_of_people_served DESC
    ) as usage_row_number
FROM water_source
ORDER BY usage_row_number, 
		 type_of_water_source;
*/

/*SELECT  -- This calculates the time difference
  TIMEDIFF(MAX(time_of_record), MIN(time_of_record)) AS SurveyDuration
FROM visits;
*/

/* Calculate how long the survey took, we need to get the first and last dates (which functions can find the largest/smallest value), and subtract
them. Remember with DateTime data, we can't just subtract the values. We have to use a function to get the difference in days.
----------------------------------------------------------------------------
In this query:
MAX(time_of_record): gets the latest date and time from the time_of_record column (the end time).
MIN(time_of_record): gets the earliest date and time from the time_of_record column (the start time).
DATEDIFF: calculates the difference in days between the two timestamps, giving you the survey duration in days.
-----------------------------------------------------------------------------------
SELECT DATEDIFF(MAX(time_of_record), MIN(time_of_record)) AS SurveyDurationInDays
FROM visits;
*/

/* Calculate how long people have to queue on average in Maji Ndogo. 
Keep in mind that many sources like taps_in_home have no queues. These are just recorded as 0 in the time_in_queue column, so when we calculate averages, we need to exclude those rows. 
Try using NULLIF() to do this
---------------------------------
In this query:
NULLIF(time_in_queue, 0) sets the time_in_queue to NULL for rows where the value is 0.
AVG calculates the average of the non-zero queue times.
The WHERE clause filters the rows to only include those with a location of 'Maji Ndogo'.
----------------------------------------
SELECT AVG(NULLIF(time_in_queue, 0)) AS AverageQueueTime
FROM visits
WHERE time_in_queue = 'Maji Ndogo';
*/


/*So let's look at the queue times aggregated across the different days of the week. 
DAY() gives you the day of the month. If we want to aggregate data for each day of the week, we need to use another DateTime function, DAYNAME(column). 
As the name suggests, it returns the day from a timestamp as a string. Using that on the time_of_record column will result in a column with day names, Monday, Tuesday, etc., from the timestamp.
To do this, we need to calculate the average queue time, grouped by day of the week. Remember to revise DateTime functions, and also think about how to present the results clearly.
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
 SELECT Clause:
DAYNAME(time_of_record) AS DayOfWeek: This part extracts the day of the week from the time_of_record column and gives it an alias, "DayOfWeek," which is used as the label for the day of the week.
ROUND(AVG(NULLIF(time_in_queue, 0)), 0) AS AverageQueueTime: This part calculates the average queue time for each day of the week while rounding the result to 0 decimal places. Here's what's happening:
NULLIF(time_in_queue, 0): This sets the time_in_queue to NULL for rows where the value is 0, effectively excluding rows with no queue time.
AVG(...): Calculates the average of the non-zero queue times for each day of the week.
ROUND(..., 0): Rounds the average queue time to 0 decimal places, ensuring that the result is an integer.

FROM Clause: visits 

GROUP BY Clause:
GROUP BY DayOfWeek: Groups the results by the "DayOfWeek" column, so you get one row for each day of the week.

ORDER BY Clause:
ORDER BY CASE ... END: Orders the results by the day of the week, with Monday as 1 and Sunday as 7. This custom sorting is achieved using a CASE statement.
The CASE statement assigns a numerical value to each day of the week for sorting purposes. Days that are not explicitly mentioned (e.g., "Else 8") are grouped together at the end. This ensures that the days are ordered chronologically.

The final result is a table that shows the day of the week (e.g., "Monday," "Tuesday") and the average queue time for that day rounded to 0 decimal places. This presentation makes it easy to see how queue times vary throughout the week.
--------------------------------------------------------------------------------------------------------
SELECT
  DAYNAME(time_of_record) AS DayOfWeek,
  ROUND(AVG(NULLIF(time_in_queue, 0)), 0) AS AverageQueueTime
FROM visits
GROUP BY DayOfWeek
ORDER BY CASE
  WHEN DayOfWeek = 'Monday' THEN 1
  WHEN DayOfWeek = 'Tuesday' THEN 2
  WHEN DayOfWeek = 'Wednesday' THEN 3
  WHEN DayOfWeek = 'Thursday' THEN 4
  WHEN DayOfWeek = 'Friday' THEN 5
  WHEN DayOfWeek = 'Saturday' THEN 6
  WHEN DayOfWeek = 'Sunday' THEN 7
  ELSE 8
END;
*/

/*-- We can also look at what time during the day people collect water. Try to order the results in a meaningful way
-------------------------------------------------------------------------
In this query:
HOUR(time_of_record): extracts the hour component from the time_of_record column, giving you the hour of the day when people collect water.
NULLIF(time_in_queue, 0): sets the time_in_queue to NULL for rows where the value is 0, excluding rows with no queue time.
AVG: calculates the average queue time for each hour of the day.
The GROUP BY clause: groups the results by the hour of the day.
The ORDER BY: HourOfDay orders the results chronologically by the hour of the day, starting from midnight (0) and progressing to 23 (11 PM).

This query will provide you with the average queue time for each hour of the day, ordered in a meaningful way based on the time of day when people collect water. You can see how queue times vary throughout the day.
---------------------------------------------------------------------------

SELECT
	HOUR(time_of_record) AS HourOfDay,
	ROUND(AVG(NULLIF(time_in_queue, 0))) AS AverageQueueTime
FROM visits
GROUP BY HourOfDay
ORDER BY HourOfDay;

-- SAME QUERY BUT A DIFFERENT TIME FORMAT
SELECT
  DATE_FORMAT(time_of_record, '%H:%i') AS HourOfDay,
  AVG(NULLIF(time_in_queue, 0)) AS AverageQueueTime
FROM visits
GROUP BY HourOfDay
ORDER BY HourOfDay;
*/

/*SELECT
TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
DAYNAME(time_of_record),
CASE
WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
ELSE NULL
END AS Sunday
FROM
visits
WHERE
time_in_queue != 0;
*/


/* This query will provide you with the average queue times for each hour of the day, broken down by day of the week, and rounded to 0 decimal places. 
The results now include data for all seven days of the week.
SELECT
  TIME_FORMAT(TIME(time_of_record), '%H:00') AS hour_of_day,
  -- Sunday
  ROUND(AVG(
    CASE
      WHEN DAYNAME(time_of_record) = 'Sunday' THEN time_in_queue
      ELSE NULL
    END
  ), 0) AS Sunday,
  -- Monday
  ROUND(AVG(
    CASE
      WHEN DAYNAME(time_of_record) = 'Monday' THEN time_in_queue
      ELSE NULL
    END
  ), 0) AS Monday,
  -- Tuesday
  ROUND(AVG(
    CASE
      WHEN DAYNAME(time_of_record) = 'Tuesday' THEN time_in_queue
      ELSE NULL
    END
  ), 0) AS Tuesday,
  -- Wednesday
  ROUND(AVG(
    CASE
      WHEN DAYNAME(time_of_record) = 'Wednesday' THEN time_in_queue
      ELSE NULL
    END
  ), 0) AS Wednesday,
  -- Thursday
  ROUND(AVG(
    CASE
      WHEN DAYNAME(time_of_record) = 'Thursday' THEN time_in_queue
      ELSE NULL
    END
  ), 0) AS Thursday,
  -- Friday
  ROUND(AVG(
    CASE
      WHEN DAYNAME(time_of_record) = 'Friday' THEN time_in_queue
      ELSE NULL
    END
  ), 0) AS Friday,
  -- Saturday
  ROUND(AVG(
    CASE
      WHEN DAYNAME(time_of_record) = 'Saturday' THEN time_in_queue
      ELSE NULL
    END
  ), 0) AS Saturday
FROM
  visits
WHERE
  time_in_queue != 0
GROUP BY
  hour_of_day
ORDER BY
  hour_of_day;
*/

/* -- One of our employees, Farai Nia, lives at 33 Angelique Kidjo Avenue. What would be the result if we TRIM() her address?
SELECT employee_name
FROM employee
WHERE employee_name = 'Farai Nai'
AND address = '33 Angelique Kidjo Avenue';
*/

/* SELECT TRIM(address) AS Trimmed_Farai_Address
FROM employee
WHERE address = '33 Angelique Kidjo Avenue';
*/

/*SELECT COUNT(*) AS EmployeeCount
FROM employee
WHERE town_name = 'Dahabu';
*/

-- How many employees live in Harare, Kilimani? Modify one of your queries from the project to answer this question.
/* SELECT COUNT(*) AS EmployeeCount
FROM employee
WHERE province_name = 'Kilimani'
AND town_name = 'Harare';
*/


