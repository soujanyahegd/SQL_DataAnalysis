--World Life Expectancy Data Cleaning Project

SELECT * 
FROM WorldLifeExpectancy
LIMIT 50;

--Identifying the duplicates

select Country, Year , CONCAT(Country, Year) as CountryYear, Count(CONCAT(Country, Year)) as Duplicates
from WorldLifeExpectancy
group by Country, Year , CONCAT(Country, Year)
having Duplicates >1;

--Removing duplicate records

select *
from(
select Row_ID,
CONCAT(Country, Year) as CountryYear,
row_number() over(Partition by CONCAT(Country, Year) order by CONCAT(Country, Year)) as row_num
from WorldLifeExpectancy) as row_table 
where row_num >1
;


delete from WorldLifeExpectancy
where Row_ID IN (
select Row_ID
from(
select Row_ID,
CONCAT(Country, Year) as CountryYear,
row_number() over(Partition by CONCAT(Country, Year) order by CONCAT(Country, Year)) as row_num
from WorldLifeExpectancy) as row_table 
where row_num >1)
;

--Finding NULL values and filling the values

-- Status was null and filled it with its status

select * from WorldLifeExpectancy
where Status is NULL;

select DISTINCT(Status) 
from WorldLifeExpectancy
where Status is NOT NULL;

select DISTINCT(Country) from WorldLifeExpectancy
where Status = 'Developing';

UPDATE WorldLifeExpectancy 
set Status = 'Developing' 
where Country IN (select DISTINCT(Country) 
from WorldLifeExpectancy
where Status = 'Developing') ;

UPDATE WorldLifeExpectancy 
set Status = 'Developed' 
where Country IN (select DISTINCT(Country) 
from WorldLifeExpectancy
where Status = 'Developed') ;

-- Life expectancy is null, filling that value with correct VALUES

Select Country, Year, [Life expectancy]  from WorldLifeExpectancy
where [Life expectancy]  is null;

Select t1.Country, t1.Year, t1.[Life expectancy] ,
t2.Country, t2.Year, t2.[Life expectancy],
t3.Country, t3.Year, t3.[Life expectancy],
Round((t2.[Life expectancy] + t3.[Life expectancy] )/2, 1)  as  average 
from WorldLifeExpectancy t1
join WorldLifeExpectancy t2
         ON t1.Country = t2.Country
		 And t1.Year = t2.Year -1
join WorldLifeExpectancy t3
         ON t1.Country = t3.Country
		 And t1.Year = t3.Year +1
where t1.[Life expectancy] is null;

UPDATE WorldLifeExpectancy
SET [Life expectancy] = (
    SELECT ROUND((t2.[Life expectancy] + t3.[Life expectancy]) / 2, 1)
    FROM WorldLifeExpectancy t1
    JOIN WorldLifeExpectancy t2
        ON WorldLifeExpectancy .Country = t2.Country
        AND WorldLifeExpectancy .Year = t2.Year - 1
    JOIN WorldLifeExpectancy t3
        ON WorldLifeExpectancy .Country = t3.Country
        AND WorldLifeExpectancy .Year = t3.Year + 1
    WHERE WorldLifeExpectancy.Country = t1.Country
      AND WorldLifeExpectancy.Year = t1.Year
      AND WorldLifeExpectancy.[Life expectancy] IS NULL
)
WHERE [Life expectancy] IS NULL;

