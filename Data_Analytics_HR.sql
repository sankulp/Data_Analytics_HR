CREATE DATABASE projects_hr;

USE projects_hr;

SELECT * FROM hr  # selecting all the columns from the table

-- data cleaning and pre processing--

ALTER TABLE HR       # as we have to change the name of the first column 
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) null;

DESCRIBE HR

SET sql_safe_updates = 0; # so as to change the columns into tables

UPDATE HR
SET birthdate = CASE 
		WHEN birthdate 	LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
		WHEN birthdate 	LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
        ELSE NULL 
        END;

ALTER TABLE HR
MODIFY COLUMN birthdate DATE; # CHANGING THE DATATYPE OF BIRTHDATE COLUMN 

-- CHANGE THE DATA FORMAT AND DATATYPE OF HIRE DATE COLUMN-- 


UPDATE HR
SET hire_date = CASE 
		WHEN hire_date 	LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
		WHEN hire_date 	LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
        ELSE NULL 
        END;



ALTER TABLE HR
MODIFY COLUMN hire_date DATE; # CHANGING THE DATATYPE OF BIRTHDATE COLUMN 


-- change the date format and data type of termdate column--
-- there are 2 ways of doing the change, one is using the date_format and other is directly using the DATE function--

/*UPDATE HR
SET termdate = date_format(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'), '%Y-%m-%d')
WHERE termdate IS NOT NULL AND termdate != '' ;        # we run the above query only where termdate is not = 0 and is not empty space
*/

UPDATE HR
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL  AND termdate != '' ;


UPDATE HR
SET termdate = NULL 
WHERE termdate = '' ;  # whwrever termdate isn't available it is set to 0 


ALTER TABLE HR
MODIFY COLUMN termdate DATE; 

-- create a column age--

ALTER TABLE HR
ADD COLUMN age INT; 

UPDATE HR
SET age = timestampdiff( YEAR,birthdate,curdate())  # finding out the difference between the birthdate and current year

SELECT min(age), max(age) FROM HR 

-- 1. WHAT IS THE GENDER BREAKDOWN OF EMPLOYEES IN THE COMPAMY

SELECT * FROM HR

SELECT gender, COUNT(*) AS count  
FROM HR
WHERE termdate IS NULL
GROUP BY gender;

-- 2. WHAT IS THE RACE BREAKDOWN OF EMPLOYEES IN THE COMPANY 

SELECT race, COUNT(*) AS count
FROM HR
WHERE termdate is NULL  # since we want only the current employees
GROUP BY race;


-- 3. FIND WTHAT IS THE AGE DSTRIBUTION OF THE EMPLOYEES IN THE COMPANY

SELECT 
	CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
	WHEN age >= 35 AND age <= 44 THEN '35-44'
	WHEN age >= 45 AND age <= 54 THEN '45-54'
	WHEN age >= 55 AND age <= 64 THEN '55-64'
	ELSE '65 +'
END AS age_group,

COUNT(*) AS count
FROM HR
WHERE termdate IS NULL 
GROUP BY age_group
ORDER BY age_group;

-- 4. HOW MNANY EMPLOYEES WORK AT HEADQUARTER AND REMOTE 

SELECT LOCATION, COUNT(*) AS count
FROM HR
WHERE termdate IS NULL 
GROUP BY location;



-- 5. WHAT IS THE AVERAGE LENGTH OF EMPLOYMENT WHO HAVE BEEN TERMINATED

SELECT ROUND(AVG( year(termdate) - year(hire_date)),0) AS length_of_emp  # this gives the length of emp for all the terminated employees till date

FROM HR 
WHERE termdate IS NOT NULL AND termdate <= curdate()


-- HOW DOES THE GENDER DISTRIBUTION VARY SACROSS DEPT AND JOB TITLe

SELECT * FROM HR 

SELECT department, jobtitle, gender, COUNT(*) AS count

FROM HR
WHERE termdate IS NOT NULL 
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender
  

  
SELECT department, gender, COUNT(*) AS count

FROM HR
WHERE termdate IS NOT NULL
GROUP BY department, gender
ORDER BY department, gender

 
-- 7. WHAT IS THE DISTRIBUTION OF JOBTITLES ACROSS THE COMPANY

SELECT jobtitle, COUNT(*) AS count

FROM HR
WHERE termdate IS NOT NULL
GROUP BY jobtitle

-- 8. WHICH DEPARTMENT HAS THE HIGHEST TURNOVER /  TERMINATION RATE

SELECT * FROM HR

SELECT department,
		COUNT(*) AS total_count,
        COUNT( CASE 
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                END) AS terminated_count, # this gives the total termination count and to calculate the termination rate we divide the total count by number of vlaues
                
		ROUND((COUNT( CASE 
				WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                END )/ COUNT(*))*100,2) AS termination_rate 
                
		FROM HR
        GROUP BY department
        ORDER BY termination_rate DESC 
                
                
                
-- 9. WHAT IS THE DISTRIBUTION OF EMPLOYEES ACROSS LOCATION_STATE



SELECT location_state, COUNT(*) AS count
FROM HR
WHERE termdate IS NULL 
GROUP BY location_state


-- 10. HOW HAS COMPANY'S EMPLOYEE COUNT CHANGE OVER TIME BASED ON HIRE AND TERMINATION DATE

SELECT * FROM HR

SELECT year,
		hires,
		terminations,
		hires - terminations AS net_change,
		(terminations/hires) * 100 AS change_percent

	FROM (
			SELECT YEAR(hire_date) AS year,
			COUNT(*) AS hires,
			SUM( CASE 
					WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                END) AS terminations
                
			FROM HR
			GROUP BY YEAR(hire_Date)) AS subquery
                
GROUP BY year
ORDER BY year; 


-- 11. WHAT IS THE TENURE DISRTIBUTION FOR EACH DEPARTMENT

SELECT * FROM HR

                
SELECT department, round(avg(datediff( termdate, hire_date) / 365),0) AS avg_tenure

FROM HR
WHERE termdate IS NOT NULL AND termdate <= curdate()
GROUP BY department
ORDER BY avg_tenure
        



                
		
                 


