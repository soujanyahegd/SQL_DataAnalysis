
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

-- Exploratory Data Analysis 

-- Cleaned Data
SELECT * 
FROM WorldLifeExpectancy;

-- Getting max and min of Life expectancy for all the countries and increase in it

select country, 
min([Life expectancy]) as Min_LifeExpectancy,
max([Life expectancy]) as Max_LifeExpectancy,
ROUND(max([Life expectancy]) - min([Life expectancy]),1) as LifeExpectancy_Increase
from WorldLifeExpectancy
group by country
having min([Life expectancy]) <> '0'
and max([Life expectancy]) <> '0'
order by LifeExpectancy_Increase desc;

-- Getting the average life expectancy for  year

select year, ROUND(AVG([Life expectancy]),2) as Avg_LifeExpectancy 
from WorldLifeExpectancy
where [Life expectancy] <> '0'
group by year
order by year desc;

-- Finding correlation between the coloumns

select country, 
round(avg([Life expectancy]),1) as Avg_LifeExp,
round(avg(GDP),1) as Avg_GDP
from WorldLifeExpectancy
group by country
having Avg_LifeExp > 0
and Avg_GDP > 0
order by Avg_GDP desc;

select 
SUM(case 
         when GDP >= 1400 then 1 else 0
end) High_GDP_Count,
AVG(case 
         when GDP >= 1400 then [Life expectancy] else null
end) High_GDP_LifeExp,
SUM(case 
         when GDP < 1400 then 1 else 0
end) Low_GDP_Count,
AVG(case 
         when GDP < 1400 then [Life expectancy] else null
end) Low_GDP_LifeExp
from WorldLifeExpectancy;

-- Average Life expectancy with status of the Country

select Status, 
Round(Avg([Life expectancy]),1) as Avg_LifeExp, Count(distinct(Country)) as Distinct_Countries
from WorldLifeExpectancy
group by Status
order by Avg_LifeExp desc;

-- Average life expectancy and BMI correlation

select Country,
Round(Avg([Life expectancy]),1) as Avg_LifeExp,
Round(Avg(BMI),1) as Avg_BMI
from WorldLifeExpectancy
group by Country
having Avg_LifeExp > 0
and Avg_BMI > 0
order by Avg_BMI desc;

-- Adult Mortality rolling total

select Country,
Year,
[Life expectancy],
[Adult Mortality],
sum([Adult Mortality]) over(partition by Country order by Year) as MortalityRollingTotal
from WorldLifeExpectancy
where country like '%united%';





