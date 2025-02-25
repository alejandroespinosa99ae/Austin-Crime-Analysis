# How many rows are there in the dataset? There are 116,672 rows
SELECT count(*) as total_number_rows 
FROM `bigquery-public-data.austin_crime.crime`;


# How many unique crimes are in the dataset? There are 50 unique crimes
select 
distinct description
from `bigquery-public-data.austin_crime.crime`;


# What is the highest sub category crime comitted?
select 
description,
count(description) as num
from `bigquery-public-data.austin_crime.crime`
group by description
order by num desc;


# Number of primary types of crime commited in descending order

with cte_crimes as (select 
primary_type,
count(primary_type) as crimes_committed
from `bigquery-public-data.austin_crime.crime`
group by primary_type
order by crimes_committed desc)

select 
  * 
from cte_crimes;



# From what year(s) is the data from? 2014-2016

SELECT distinct(year)
FROM `bigquery-public-data.austin_crime.crime`;


# How many crimes occurred each year?








