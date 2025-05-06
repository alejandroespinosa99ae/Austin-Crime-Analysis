use portfolioproject;

#Create the table
CREATE TABLE austin_crime (
    IncidentNumber bigint,
    HighestOffenseDescription text,
    HighestOffenseCode int,
    FamilyViolence text,
    OccurredDateTime text,
    OccurredDate text,
    OccurredTime double,
    ReportDateTime text,
    ReportDate text,
    ReportTime int,
    LocationType text,
    CouncilDistrict text,
    APDSector text,
    APDDistrict int,
    ClearanceStatus text,
    ClearanceDate text,
    UCRCategory text,
    CategoryDescription text,
    CensusBlockGroup text
);

LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\portfolioproject\\Crime_Reports_20250430.csv'
INTO TABLE austin_crime
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM portfolioproject.austin_crime;

# verifying that all the rows were imported
select count(*)
from portfolioproject.austin_crime;

#####################################################
# To get a better idea of the missing values in each column
SELECT 
  COUNT(*) AS total_rows,
  COUNT(CASE WHEN TRIM(IncidentNumber) = '' OR IncidentNumber IS NULL THEN 1 END) AS missing_IncidentNumber,
  COUNT(CASE WHEN TRIM(HighestOffenseDescription) = '' OR HighestOffenseDescription IS NULL THEN 1 END) AS missing_HighestOffenseDescription,
  COUNT(CASE WHEN TRIM(HighestOffenseCode) = '' OR HighestOffenseCode IS NULL THEN 1 END) AS missing_HighestOffenseCode,
  COUNT(CASE WHEN TRIM(FamilyViolence) = '' OR FamilyViolence IS NULL THEN 1 END) AS missing_FamilyViolence,
  COUNT(CASE WHEN TRIM(OccurredDateTime) = '' OR OccurredDateTime IS NULL THEN 1 END) AS missing_OccurredDateTime,
  COUNT(CASE WHEN TRIM(OccurredDate) = '' OR OccurredDate IS NULL THEN 1 END) AS missing_OccurredDate,
  COUNT(CASE WHEN TRIM(OccurredTime) = '' OR OccurredTime IS NULL THEN 1 END) AS missing_OccurredTime,
  COUNT(CASE WHEN TRIM(ReportDateTime) = '' OR ReportDateTime IS NULL THEN 1 END) AS missing_ReportDateTime,
  COUNT(CASE WHEN TRIM(ReportDate) = '' OR ReportDate IS NULL THEN 1 END) AS missing_ReportDate,
  COUNT(CASE WHEN TRIM(ReportTime) = '' OR ReportTime IS NULL THEN 1 END) AS missing_ReportTime,
  COUNT(CASE WHEN TRIM(LocationType) = '' OR LocationType IS NULL THEN 1 END) AS missing_LocationType,
  COUNT(CASE WHEN TRIM(CouncilDistrict) = '' OR CouncilDistrict IS NULL THEN 1 END) AS missing_CouncilDistrict,
  COUNT(CASE WHEN TRIM(APDSector) = '' OR APDSector IS NULL THEN 1 END) AS missing_APDSector,
  COUNT(CASE WHEN TRIM(APDDistrict) = '' OR APDDistrict IS NULL THEN 1 END) AS missing_APDDistrict,
  COUNT(CASE WHEN TRIM(ClearanceStatus) = '' OR ClearanceStatus IS NULL THEN 1 END) AS missing_ClearanceStatus,
  COUNT(CASE WHEN TRIM(ClearanceDate) = '' OR ClearanceDate IS NULL THEN 1 END) AS missing_ClearanceDate,
  COUNT(CASE WHEN TRIM(UCRCategory) = '' OR UCRCategory IS NULL THEN 1 END) AS missing_UCRCategory,
  COUNT(CASE WHEN TRIM(CategoryDescription) = '' OR CategoryDescription IS NULL THEN 1 END) AS missing_CategoryDescription,
  COUNT(CASE WHEN TRIM(CensusBlockGroup) = '' OR CensusBlockGroup IS NULL THEN 1 END) AS missing_CensusBlockGroup
FROM portfolioproject.austin_crime;

# what years does the dataset range from
select distinct(right(OccurredDate,4))
from portfolioproject.austin_crime;

# What are the distinct Districts in Austin
select distinct(APDDistrict)
from portfolioproject.austin_crime;

# What District has the most crimes?
SELECT 
	CouncilDistrict, 
    count(CouncilDistrict) as districtCrime
FROM portfolioproject.austin_crime
group by CouncilDistrict
order by districtCrime desc;

# There is a blank row for the CouncilDistrict that needs to be corrected, lets find all of them
SELECT CouncilDistrict, APDSector, APDDistrict
FROM portfolioproject.austin_crime
#WHERE APDSector = "GE"
WHERE (trim(CouncilDistrict) = "" or CouncilDistrict != "") and APDSector = "DA";



# 1 Total Crimes
# sum of all the reported crimes in the dataset
SELECT COUNT(IncidentNumber)
FROM portfolioproject.austin_crime;


# 2 Crime Distributin by Year and Yearly Changes
# Analysis of crimes categorized by year, including insights into the year-over-year changes
SELECT right(OccurredDate,4) as extracted_year, count(OccurredDate)
FROM portfolioproject.austin_crime
WHERE RIGHT(OccurredDate, 4) IN (
  '2003','2004','2005','2006','2007','2008','2009',
  '2010','2011','2012','2013','2014','2015','2016',
  '2017','2018', '2019', '2020', '2021', '2022', 
  '2023', '2024', '2025'
)
group by extracted_year;

# 3 Crimes by Time Range 
# Exploration of crime occurrences within specific time intervals, providing a detailed breakdown
SELECT 
	#right(OccurredDateTime, 4) as occurred_time, 
    str_to_date(OccurredTime, '%H:%i') as occurred_time,
    count(*)
FROM portfolioproject.austin_crime
GROUP BY occurred_time;

# Most popular days crimes were committed # OccurredDate has no missing values so we're using it instead of DateTime which includes the date and the time
WITH week_crimes as (SELECT 
	dayofweek(str_to_date(OccurredDate,'%m/%d/%Y')) as num_of_day
FROM portfolioproject.austin_crime
)
SELECT 
	case 
		when num_of_day = 1 then 'Monday'
        when num_of_day = 2 then 'Tuesday'
        when num_of_day = 3 then 'Wednesday'
        when num_of_day = 4 then 'Thursday'
        when num_of_day = 5 then 'Friday'
        when num_of_day = 6 then 'Saturday'
        when num_of_day = 7 then 'Sunday'
        else 'Unknown' end as day_of_week,
    count(*)
FROM week_crimes
GROUP BY day_of_week
;

SELECT 
    *
FROM portfolioproject.austin_crime
WHERE IncidentNumber = 20031901191;


# 4 Heatmap showing Crime Distribution by Weekdays and Months
# Visualization using a heatmap to illustrate how many crimes are distributed across weekdays and months

# 5 Crimes by Country: ((((((Instead do apd sector???
# Examination of crimes categorized by the country where they occurred

# Total resolved and unresolved crimes
# getting an overview of the overall resolution rate

# Monthly crime trend with percentage Variance
# analysis of the montly crime trend, accompanied by the percentage variance to highlight fluctuations

# Identification of the most dangerous time of the day
# exploration to pinpoint the specific time periods during the day associated with a higher frequency of crimes



# What are the top 10 most common crimes committed?
SELECT 
	HighestOffenseDescription, 
	count(HighestOffenseDescription) as `Number of Crimes`
FROM portfolioproject.austin_crime
GROUP BY HighestOffenseDescription
ORDER BY `Number of Crimes` desc
LIMIT 10;

# Lets take a closer look at Burglary of Vehicle
with vehicle_cte as (
select *
from portfolioproject.austin_crime
where HighestOffenseDescription LIKE '%BURGLARY OF VEHICLE%'
)
select * 
from vehicle_cte;




