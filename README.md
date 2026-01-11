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
# filtering which country has duplicates
HAVING COUNT(CONCAT(Country, Year)) > 1;
```

