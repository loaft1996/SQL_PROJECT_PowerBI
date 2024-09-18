USE project;

SELECT *
FROM hr;

ALTER TABLE hr
CHANGE COLUMN ď»żid emp_id VARCHAR(20) NULL; 

DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;


UPDATE hr
SET birthdate = CASE 
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%d-%m-%Y'), '%Y-%m-%d')
    ELSE NULL
END;
ALTER TABLE hr 
MODIFY COLUMN birthdate DATE;



UPDATE hr
SET hire_date = CASE 
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%d-%m-%Y'), '%Y-%m-%d')
    ELSE NULL
END;
ALTER TABLE hr 
MODIFY COLUMN hire_date DATE;



UPDATE hr
SET termdate = NULL
WHERE termdate = '';

SELECT termdate FROM hr;
UPDATE hr 
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL;
ALTER TABLE hr 
MODIFY COLUMN termdate DATE;


ALTER TABLE hr
ADD COLUMN age INT;
UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS youngest,
    max(age) AS oldest
FROM hr;

SELECT count(*) FROM hr 
WHERE age < 18;


-- Otázky
-- 1) Zamestnanci podľa pohlavia, ktorý ešte pracuju vo firme. 
SELECT gender, count(gender) AS gender_count
FROM hr
WHERE age >=18 AND termdate IS NULL
GROUP BY gender;

-- 2) Rasové/etnické členenie zamestnancov vo firme.

SELECT race, count(race) AS race_count
FROM hr 
WHERE age >=18 AND termdate IS NULL
GROUP BY race
ORDER BY count(race) DESC;

-- 3) Aké je vekové rozdelenie zamestnancov vo firme ?
SELECT 
	min(age) AS najmdalší_zamestnanec,   
    max(age) AS najstaší_zamestnanec
FROM hr 
WHERE age >=18 and termdate IS NULL; 

SELECT 
	CASE 
		WHEN age >=18 AND age <=24 THEN '18-24'
        WHEN age >=25 AND age <=34 THEN '25-34'
		WHEN age >=35 AND age <=44 THEN '35-44'
        WHEN age >=45 AND age <=54 THEN '45-54'
        WHEN age >=55 AND age <=64 THEN '55-64'
	ELSE '65+'
END AS age_group,
count(age) AS count_age
FROM hr 
WHERE age >=18 and termdate IS NULL
GROUP BY age_group
ORDER BY age_group;

SELECT 
	CASE 
		WHEN age >=18 AND age <=24 THEN '18-24'
        WHEN age >=25 AND age <=34 THEN '25-34'
		WHEN age >=35 AND age <=44 THEN '35-44'
        WHEN age >=45 AND age <=54 THEN '45-54'
        WHEN age >=55 AND age <=64 THEN '55-64'
	ELSE '65+'
END AS age_group,
count(age) AS count_age,gender
FROM hr 
WHERE age >=18 and termdate IS NULL
GROUP BY age_group,gender
ORDER BY age_group,gender;


-- 4)  Koľko zamestnancov pracuje v centrále a koľko na dištančných pozíciách?
SELECT location, count(location) AS count_location
FROM hr
WHERE age >=18 and termdate IS NULL
GROUP BY location;

-- 5) Aká je priemerná doba zamestnania zamestnanca pred jeho odchodom z firmy?
SELECT 
	round(avg(datediff(termdate,hire_date))/365,0) AS avg_length_employment
    FROM hr
    WHERE termdate <= curdate() AND termdate IS NOT NULL AND age >=18;
    
-- 6) Ako sa líši rozdelenie pohlaví medzi jednotlivými oddeleniami.
SELECT department,gender, count(department)
FROM hr 
WHERE age >=18 and termdate IS NULL
GROUP BY department,gender
ORDER BY department;

-- 7) Aké je rozdelenie pracovných pozícií v celej spoločnosti?
SELECT jobtitle, count(jobtitle) AS jobtitle_count
FROM hr
WHERE age >=18 and termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;


-- 8) Ktoré oddelenie má najvyššiu mieru fluktuácie?
SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM ( 
	SELECT department,
    count(department) AS total_count,
    SUM(CASE WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age>=18
    GROUP BY department
    ) AS subquery
    ORDER BY termination_rate DESC;
    
-- 9)  Aké je rozdelenie zamestnancov podľa štátu? 
SELECT location_state, count(location_state) AS count_location_state
FROM hr
GROUP BY location_state
ORDER BY count(location_state) DESC;

-- 10) Ako sa menil počet zamestnancov v spoločnosti v priebehu času na základe dátumov nástupu a odchodu?
SELECT 
    year,
    hires,
    terminations,
    hires - terminations AS net_change,
    ROUND((hires - terminations) / hires * 100, 2) AS net_change_perce
	-- ROUND((terminations/ hires) * 100, 2) AS percente_turnover 
    
FROM (
    SELECT YEAR(hire_date) AS year,
        COUNT(*) AS hires,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    WHERE age >= 18
    GROUP BY YEAR(hire_date)
) AS subquery
ORDER BY year ASC;


-- 11) Aká je distribúcia dĺžky pracovného pomeru v jednotlivých oddeleniach?


SELECT department, 
       ROUND(AVG(DATEDIFF(termdate, hire_date) / 365), 0) AS avg_tenure
FROM hr
WHERE termdate <= CURDATE() 
  AND termdate IS NOT NULL 
  AND age >= 18
GROUP BY department;




    
    
    
    
    





        






