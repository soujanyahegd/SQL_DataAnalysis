# World Life Expectancy Data Cleaning Project


SELECT * 
FROM WorldLifeExpectancy
LIMIT 50;

# Identifying the duplicates

select Country, Year , CONCAT(Country, Year) as CountryYear, Count(CONCAT(Country, Year)) as Duplicates
from WorldLifeExpectancy
group by Country, Year , CONCAT(Country, Year)
having Duplicates >1;

# Removing duplicate records

select Row_ID,
CONCAT(Country, Year) as CountryYear,
row_number() over(Partition by CONCAT(Country, Year) order by CONCAT(Country, Year)) as row_num
from WorldLifeExpectancy;