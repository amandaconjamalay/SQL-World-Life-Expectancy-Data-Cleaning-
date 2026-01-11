# SQL-World-Life-Expectancy-Data-Cleaning

## Overview
Performing data cleaning on World Life Expectancy Dataset to remove inconsistencies and irrelevant data.

## Datasets
* ```WorldLifeExpectancy.csv```

## 1. Removing Duplicates 
Looking for countries and years that are duplicated in the table.
* ```country``` and ```year``` used to identify each record.
* ```CONCAT(country, year)``` creates unique values (like ```"Brazil2022"```) to represent a unique ```Country-Year``` pair.
* ```COUNT(CONCAT(Country, Year))``` will identify how many times that exact Country-Year combo appears.
* ```GROUP BY Country, Year, CONCAT(Country, Year)``` all identical combinations are grouped together.
* ```HAVING COUNT(CONCAT(Country, Year)) > 1``` keeps only the (country + year) pair that appear more than once.  
  
```MySQL
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;
```

We need to find the ```Row_ID``` for the duplicates as each row has a unique row number.
* ```ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year)``` this assigns a sequential number to each row within the same Country-Year group, resets numbering for each Country-Year combination.
* ```ORDER BY CONCAT(Country, Year)) AS row_num``` determines which row gets the row number.

```MySQL
SELECT *
FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
	FROM world_life_expectancy) AS row_table
WHERE row_num > 1;
```
  <img width="300" height="150" alt="image" src="https://github.com/user-attachments/assets/e11c32f9-a58a-4106-958a-3692492d16ef" />

Now that we have identified the duplicates and their row number we can now delete the duplicates.
```MySQL
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
```
## Missing Data in Status column
When looking at the data I noticed that there were some blanks in the status column, this query checks to see if there are any blanks or nulls.
```MySQL
SELECT * 
FROM world_life_expectancy
WHERE Status IS NULL OR ''
;
```
<img width="400" height="250" alt="image" src="https://github.com/user-attachments/assets/6bb1f826-8838-4e7a-873f-a27177d25f4e" />

Since we have all the status for each country, we are able to populate in the missing data.
* E.g. to Afghanistan 2014 isn't populated but 2015 and 2016 is.

Checking the different outputs for the status column:

<img width="152" height="107" alt="image" src="https://github.com/user-attachments/assets/ae46c404-8a89-4e08-87f0-74e3defd9400" />

To populate we are going to use a self join:
* ```UPDATE world_life_expectancy t1 JOIN world_life_expectancy t2``` joining the table to itself.
* ```ON t1.Country = t2.Country``` matches rows belonging to the same country.
* ```SET t1.Status = 'Developing'``` only t1 is updated, t2 is read only.
* ```WHERE t1.Status = ''``` where status is blank and ```AND t2.Status <> ''``` t2 is not blank and the status is developing.


```MySQL
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
# update is on t1
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;
```

All the developing countries got updated, now we have to do the same for the developed countries, in this case we only have one which is the US.


```MySQL
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
```

## Missing data in Life Expectancy
<img width="500" height="144" alt="image" src="https://github.com/user-attachments/assets/ac219ae3-0fe1-4791-ad43-8df658ad3aab" />

When looking at the data e.g. Afghanistan it looks like the age slowly increases over the years. 


<img width="380" height="330" alt="image" src="https://github.com/user-attachments/assets/9e383c7d-d379-4eca-a483-aeba40c4b6b2" />

This query will fill in the mssing life expentacny values by taking the previous year and next year for the same country, average them, and use that as the missing year's value. 
* ```t1``` - the row with the missing life expectancy (the one we want to fix).
* ```t2``` - the previous year row (same country).
* ```t3``` - the next year row (same country).
* ```ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)``` - the calculate average.


```MySQL
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
```
A self join is put in place and when we compare the life expectancy against the other tables we are able to see the last year and next year on the same row line.

<img width="1467" height="173" alt="image" src="https://github.com/user-attachments/assets/415ddaad-5c9e-4ab1-bbd8-7cc9d783e301" />

Now we can update the table:

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


