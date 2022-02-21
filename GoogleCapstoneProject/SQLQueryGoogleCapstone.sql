-- DATA CLEANING
SELECT *
FROM PortfolioProject..dailyActivity_merged

SELECT TotalDistance
FROM PortfolioProject..dailyActivity_merged


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Repare de date formatting 
UPDATE PortfolioProject..dailyActivity_merged 
SET ActivityDate = CONVERT(date, ActivityDate)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Identifying missing values
SELECT *
FROM PortfolioProject..dailyActivity_merged
WHERE TotalDistance = '0'

/* I'm deleting the rows where TotalDistance is 0 because total distance being 0 zero means that the fitness tracking device was not used (or used in a way that is not
 useful to us). */
DELETE 
FROM PortfolioProject..dailyActivity_merged
WHERE TotalDistance = '0'


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Identifying duplicates

-- This allows us to find that the number of unique participants is 33.
SELECT Id, count(id)
FROM PortfolioProject..dailyActivity_merged
GROUP BY Id


/* There are repeat Id numbers and repeat ActivityDate, each Id number cannot have repeat ActivityDate dates or else it means there is an error in the data.
Therefore, we find out if the Id and ActivityDate are unique to one another. Together, they should form a primary key.*/
SELECT ActivityDate, COUNT(ActivityDate)
FROM PortfolioProject..dailyActivity_merged
GROUP BY ActivityDate

SELECT Id, ActivityDate, COUNT(Id)
FROM PortfolioProject..dailyActivity_merged
GROUP BY Id, ActivityDate
HAVING COUNT(Id)> 1

SELECT Id, ActivityDate, COUNT(ActivityDate)
FROM PortfolioProject..dailyActivity_merged
GROUP BY Id, ActivityDate
HAVING COUNT(ActivityDate)> 1
-- The Id and Activity date are unique to one another


-- This allows us to see that we have no duplicates rows
SELECT DISTINCT *
FROM PortfolioProject..dailyActivity_merged


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Deleting unused columns? 

/* TrackerDistance is the total distance tracked by the fitbit device and TotalDistance is simply the total distance tracked. Therefore, TrackerDistance is useless to us.
In this query we can see that there are 15 instances where TrackerDistance is different (and lower) that TotalDistance. We will drop the column*/
SELECT TotalDistance, TrackerDistance
FROM PortfolioProject..dailyActivity_merged
WHERE TotalDistance != TrackerDistance

ALTER TABLE dbo.dailyActivity_merged
DROP COLUMN TrackerDistance


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
														-- NEW TABLE --


-- Added 2 new tables, going to clean them and finish by performing join statements
SELECT *
FROM PortfolioProject..weightLogInfo_merged


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Fixe date formatting
-- First I seperate the date from the time 

/* 
Can't use PARSENAME for this because we have PMs and AMs at the end of the date. 
SELECT PARSENAME(REPLACE(Date, ' ','.'), 1)
FROM PortfolioProject..weightLogInfo_merged
 */


SELECT Date, LEFT(Date, CHARINDEX(' ', Date)) AS Date1,
RIGHT(Date, LEN(Date) - CHARINDEX(' ', Date)) AS Time
FROM PortfolioProject..weightLogInfo_merged

ALTER TABLE PortfolioProject..weightLogInfo_merged
ADD Date1 NVARCHAR(255);

UPDATE PortfolioProject..weightLogInfo_merged
SET Date1 = LEFT(Date, CHARINDEX(' ', Date))


ALTER TABLE PortfolioProject..weightLogInfo_merged
ADD Time NVARCHAR(255);

UPDATE PortfolioProject..weightLogInfo_merged
SET Time = RIGHT(Date, LEN(Date) - CHARINDEX(' ', Date))


-- The time and date have been seperated I can now fixe the formatting.
UPDATE PortfolioProject..weightLogInfo_merged 
SET Date1 = CONVERT(date, Date1)

UPDATE PortfolioProject..weightLogInfo_merged 
SET Time = CONVERT(time, Time)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Dropping values
-- Both date and time are properly formatted, I can drop the original Date column. 
ALTER TABLE PortfolioProject..weightLogInfo_merged
DROP COLUMN Date

-- I will also drop the Fat column as only 2 of 67 values are present, therefore, making the column useless
ALTER TABLE PortfolioProject..weightLogInfo_merged
DROP COLUMN Fat


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                           -- NEW TABLE --


SELECT *
FROM PortfolioProject..sleepDay_merged


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/* All useless because the time does not matter in this case, it is just filled out as 00:00:00
-- Seperating the values in SleepDay
SELECT SleepDay, LEFT(SleepDay, CHARINDEX(' ', SleepDay)) AS Date1,
RIGHT(SleepDay, LEN(SleepDay) - CHARINDEX(' ', SleepDay)) AS Time
FROM PortfolioProject..sleepDay_merged

ALTER TABLE PortfolioProject..sleepDay_merged
ADD Date1 NVARCHAR(255);

ALTER TABLE PortfolioProject..sleepDay_merged
ADD Time NVARCHAR(255);


UPDATE PortfolioProject..sleepDay_merged
SET Date1 = LEFT(SleepDay, CHARINDEX(' ', SleepDay))

UPDATE PortfolioProject..sleepDay_merged
SET Time = RIGHT(SleepDay, LEN(SleepDay) - CHARINDEX(' ', SleepDay))


-- The values have been seperated, I can format them properly now
UPDATE PortfolioProject..sleepDay_merged 
SET Date1 = CONVERT(date, Date1)
*/

-- Format SleepDay
UPDATE PortfolioProject..sleepDay_merged
SET SleepDay = CONVERT(date, SleepDay)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Dropping unecessary tables I created

ALTER TABLE PortfolioProject..sleepDay_merged 
DROP COLUMN Date1

ALTER TABLE PortfolioProject..sleepDay_merged 
DROP COLUMN Time


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Checking for duplicate values
-- The Id and SleepDay should be unique to one another
SELECT SleepDay, COUNT(SleepDay)
FROM PortfolioProject..sleepDay_merged
GROUP BY SleepDay

SELECT Id, SleepDay, COUNT(Id)
FROM PortfolioProject..sleepDay_merged
GROUP BY Id, SleepDay
HAVING COUNT(Id)> 1

SELECT Id, SleepDay, COUNT(SleepDay)
FROM PortfolioProject..sleepDay_merged
GROUP BY Id, SleepDay
HAVING COUNT(SleepDay)> 1
-- There are 2 instances where the Id and SleepDay appear twice on the same row. Meaning either there are errors in the data or the user took an nap during the day.


-- With this statement I find that it is an error in the data, there are 3 duplicates.
SELECT *
FROM PortfolioProject..sleepDay_merged
WHERE Id = '8378563200' AND SleepDay = '2016-04-25'
OR 
Id = '4388161847' AND SleepDay = '2016-05-05'
OR
Id = '4702921684' AND SleepDay = '2016-05-07';



---------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- Deleting the duplicate rows 
WITH RowNumCTE AS
(
	SELECT *,
	ROW_NUMBER() OVER
	(
	PARTITION BY Id, SleepDay
	ORDER BY Id
	)
	row_num
	FROM PortfolioProject..sleepDay_merged
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
															-- JOINING TABLES --


SELECT *
FROM PortfolioProject..dailyActivity_merged AS a
INNER JOIN PortfolioProject..sleepDay_merged AS b 
	ON a.Id = b.Id 
	AND a.ActivityDate = b.SleepDay 
LEFT JOIN PortfolioProject..weightLogInfo_merged c
	ON a.Id = c.Id
	AND a.ActivityDate = c.Date1


