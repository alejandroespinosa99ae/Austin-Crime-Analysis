# There are 116,672 rows

#SELECT count(*) as total_number_rows 
#FROM `bigquery-public-data.austin_crime.crime`;


 How many unique crimes are in the dataset? There are 50 unique crimes
select 
  distinct(description)
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


# What are the distinct years in the dataset?

SELECT distinct(year)
FROM `bigquery-public-data.austin_crime.crime`;


# How many crimes occurred each year?

SELECT 
  year,
  count(primary_type) as crimes_per_year
FROM `bigquery-public-data.austin_crime.crime`
group by year;


# What is the most common primary_type crime?
SELECT 
  primary_type,
  count(primary_type) as count_of_crime
FROM `bigquery-public-data.austin_crime.crime`
group by primary_type
order by count_of_crime desc
limit 1;

# Count the number of missing addresses
select
  count(*) as total_num_rows,
  count(address) as num_addresses,
  count(*) - count(address) as missing_addresses
from `bigquery-public-data.austin_crime.crime`;

# What are the earliest and latest timestamps?
SELECT 
  min(timestamp) as `Min`,
  max(timestamp) as `Max`
FROM `bigquery-public-data.austin_crime.crime`;

# How many crimes occured in each police district?
SELECT
  district,
  count(primary_type) as district_crime_count
FROM `bigquery-public-data.austin_crime.crime`
group by district
order by district_crime_count desc;

# What is the distribution of crimes by clearance?
SELECT 
  primary_type,
  count(clearance_status)
FROM `bigquery-public-data.austin_crime.crime`
group by primary_type;

# What are the top 5 locations with the most crime?
SELECT 
  location,
  count(primary_type)
FROM `bigquery-public-data.austin_crime.crime`
group by location
order by location desc;

