# World Life Expectancy (Data Cleaning)

SELECT * 
FROM world_life_expectancy
;

# Removing duplicates

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
# filtering which country has duplicates
HAVING COUNT(CONCAT(Country, Year)) > 1
;

# ROW_NUMBER - We want a row number patitioned on this concatenation.

SELECT *
FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
	FROM world_life_expectancy) AS row_table
WHERE row_num > 1
;

# Now we want to delete these row ids.
DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN(
    SELECT Row_ID
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
	FROM world_life_expectancy) AS row_table
WHERE row_num > 1)
;
    
# Next, we have some blanks in the status column. 
	
SELECT * 
FROM world_life_expectancy
WHERE Status IS NULL OR ''
;
    
SELECT DISTINCT(Status) 
FROM world_life_expectancy
WHERE Status <> ''
;

# We can use this by saying when it is a developing country we can populate that when it's blank.
SELECT DISTINCT country
FROM world_life_expectancy
WHERE Status = 'Developing'
;

#ERROR
-- We can't say take it from where its blank but also not blank, it would cancel itself out 
-- But if we self join we can now filter off that other table 
UPDATE world_life_expectancy
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT country
		FROM world_life_expectancy
		WHERE Status = 'Developing')
;

# Going to do a self join in the update statement
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
# update is on t1
SET t1.Status = 'Developing'
## identifying which ones are blank
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

# It updates all the rows except one as the on it didnt populate was a developed country. 
SELECT * 
FROM world_life_expectancy
WHERE Country = 'United States of America'
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
# update is on t1
SET t1.Status = 'Developed'
## identifying which ones are blank
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

# Taking a look at life expectancy which have blanks 
-- When looking at the life expectancy you can see that it is slowly increasing every year. 
SELECT * 
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

#Joining on country and year 
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)	
FROM world_life_expectancy t1
JOIN world_life_expectancy t2 
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2 
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3 
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
WHERE t1.`Life expectancy` = ''
; 









