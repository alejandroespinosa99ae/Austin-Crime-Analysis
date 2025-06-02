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
############################################################################
# What District has the most crimes? (6th query District with most crimes.csv)
SELECT 
	case
		when CouncilDistrict is null or TRIM(CouncilDistrict) = '' then 'Unknown'
        else CouncilDistrict
        end as CouncilDistrict_, 
    count(CouncilDistrict) as districtCrime
FROM portfolioproject.austin_crime
group by CouncilDistrict_
order by districtCrime desc;
############################################################################
# Total Crimes (1st query Total Crimes.csv)
# sum of all the reported crimes in the dataset
SELECT 
    `year`,
    `Month`,
    case
		when CouncilDistrict is null or TRIM(CouncilDistrict) = '' then 'Unknown'
        else CouncilDistrict
        end as CouncilDistrict_,
    COUNT(IncidentNumber) as Crimes
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/1st query Total crimes.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM portfolioproject.austin_crime
Group by `year`,`Month`, CouncilDistrict_
order by `year`, CouncilDistrict_ desc;

SHOW VARIABLES LIKE 'secure_file_priv';

########################################################
# 2 Crime Distribution by Year and Yearly Changes (2nd query.csv)
# Analysis of crimes categorized by year, including insights into the year-over-year changes
SELECT right(OccurredDate,4) as extracted_year, count(OccurredDate) as crimes_committed
FROM portfolioproject.austin_crime
WHERE RIGHT(OccurredDate, 4) != '2025'
group by extracted_year
order by crimes_committed desc;

########################################################
# Crimes by Time Range 
# Exploration of crime occurrences within specific time intervals, providing a detailed breakdown

# Most popular days crimes were committed by year# OccurredDate has no missing values so we're using it instead of DateTime which includes the date and the time
WITH week_crimes as (SELECT 
	dayofweek(str_to_date(OccurredDate,'%m/%d/%Y')) as num_of_day,
    OccurredDate
FROM portfolioproject.austin_crime
)
SELECT 
	right(OccurredDate,4) as years,
	case 
		when num_of_day = 1 then 'Monday'
        when num_of_day = 2 then 'Tuesday'
        when num_of_day = 3 then 'Wednesday'
        when num_of_day = 4 then 'Thursday'
        when num_of_day = 5 then 'Friday'
        when num_of_day = 6 then 'Saturday'
        when num_of_day = 7 then 'Sunday'
        else 'Unknown' end as day_of_week,
    count(*) as crimes
FROM week_crimes
WHERE RIGHT(OccurredDate, 4) != '2025'
GROUP BY years, day_of_week
order by years desc;

########################################################
# Changing the table to now have a column for the year
ALTER TABLE austin_crime
ADD `year` TEXT;
# Populate the newly added column
SET SQL_SAFE_UPDATES = 0;
UPDATE austin_crime
SET `year` = RIGHT(OccurredDate,4);
SET SQL_SAFE_UPDATES = 1;
########################################################

# Changing the table to now have a column for the Month
ALTER TABLE austin_crime
ADD `Month` TEXT;
# Populate the newly added column
SET SQL_SAFE_UPDATES = 0;
UPDATE austin_crime
SET `Month` = CASE 
    WHEN `Month` = '01' THEN 'January'
    WHEN `Month` = '02' THEN 'February'
    WHEN `Month` = '03' THEN 'March'
    WHEN `Month` = '04' THEN 'April'
    WHEN `Month` = '05' THEN 'May'
    WHEN `Month` = '06' THEN 'June'
    WHEN `Month` = '07' THEN 'July'
    WHEN `Month` = '08' THEN 'August'
    WHEN `Month` = '09' THEN 'September'
    WHEN `Month` = '10' THEN 'October'
    WHEN `Month` = '11' THEN 'November'
    WHEN `Month` = '12' THEN 'December'
    ELSE `Month` -- fallback if it doesn't match any known value
END;
SET SQL_SAFE_UPDATES = 1;

# 3 Crimes by month for each year
select `year`, `Month`, count(`year`) as crimes
from austin_crime
group by `year`, `Month`;

########################################################



# 4 Heatmap showing Crime Distribution by Weekdays and Months
# Visualization using a heatmap to illustrate how many crimes are distributed across weekdays and months

# 5 Crimes by Country: ((((((Instead do apd sector???
# Examination of crimes categorized by the country where they occurred

##########################################################################
# Total resolved and unresolved crimes (Clearance Status.csv)
# getting an overview of the overall resolution rate
SELECT 
	CouncilDistrict,
    `year`,
    `Month`,
	format((sum(case when ClearanceStatus = 'N' then 1 end)/ count(*) * 100), 2) as not_cleared,
     format((sum(case when ClearanceStatus = 'C' then 1 end)/ count(*) * 100), 2) as cleared,
     format((sum(case when trim(ClearanceStatus) = 'O' then 1 end)/ count(*) * 100), 2) as other,
    format((sum(case when trim(ClearanceStatus) = '' then 1 end)/ count(*) * 100), 2) as tba
from portfolioproject.austin_crime
group by CouncilDistrict, `year`, `Month`
;
############################################################################

# Monthly crime trend with percentage Variance
# analysis of the montly crime trend, accompanied by the percentage variance to highlight fluctuations

# Identification of the most dangerous time of the day
# exploration to pinpoint the specific time periods during the day associated with a higher frequency of crimes

#####################################################
# this query is to see the popular times to commit a crime across all years for the given weekday (Crime heatmap.csv)
WITH day_of_week_cte as (SELECT 
	dayofweek(str_to_date(OccurredDateTime,'%m/%d/%Y')) as num_of_day,
    OccurredDateTime
FROM portfolioproject.austin_crime
)
SELECT 
    hour(right(OccurredDateTime,5)) as hour_of_day, # we want to group by hour
	case 
		when num_of_day = 1 then 'Monday'
        when num_of_day = 2 then 'Tuesday'
        when num_of_day = 3 then 'Wednesday'
        when num_of_day = 4 then 'Thursday'
        when num_of_day = 5 then 'Friday'
        when num_of_day = 6 then 'Saturday'
        when num_of_day = 7 then 'Sunday'
        else 'Unknown' end as day_of_week,
    count(*) as crimes
FROM day_of_week_cte
group by day_of_week, hour_of_day
order by crimes desc;
#####################################################
# What are the top 10 most common crimes committed? (Most Common Crimes.csv)
SELECT 
	HighestOffenseDescription, 
	count(HighestOffenseDescription) as `Number of Crimes`
FROM portfolioproject.austin_crime
GROUP BY HighestOffenseDescription
ORDER BY `Number of Crimes` desc
LIMIT 10;

#######################################################

SELECT 
    year,
    month,
    CouncilDistrict,
    HighestOffenseDescription,
    Crimes
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/top 10 crimes.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
FROM (
    SELECT 
        `year`,
        `month`,
        CouncilDistrict,
         HighestOffenseDescription,
        COUNT(*) AS Crimes,
        ROW_NUMBER() OVER (
            PARTITION BY `year`, `month`, CouncilDistrict
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM portfolioproject.austin_crime
    GROUP BY `year`, `month`, CouncilDistrict,  HighestOffenseDescription
) ranked
WHERE rn <= 10
ORDER BY `year`, `month`, CouncilDistrict, rn;





