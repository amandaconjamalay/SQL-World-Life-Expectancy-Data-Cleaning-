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
