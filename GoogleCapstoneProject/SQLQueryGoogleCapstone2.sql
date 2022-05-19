SELECT *
FROM PortfolioProject..hourlyCalories_merged

SELECT *
FROM PortfolioProject..hourlyIntensities_merged

--- JOINING THE TWO TABLES ---

SELECT ISNULL(c.Id, i.Id) AS Id, ISNULL(c.ActivityHour, i.ActivityHour) AS ActivityHour, c.Calories, i.TotalIntensity, i.AverageIntensity 
FROM PortfolioProject..hourlyCalories_merged c
JOIN PortfolioProject..hourlyIntensities_merged i
ON c.Id = i.Id AND c.ActivityHour = i.ActivityHour



--- CREATING TEMP TABLE ---

SELECT ISNULL(c.Id, i.Id) AS Id, ISNULL(c.ActivityHour, i.ActivityHour) AS ActivityHour, c.Calories, i.TotalIntensity, i.AverageIntensity INTO #temptable
FROM PortfolioProject..hourlyCalories_merged c
JOIN PortfolioProject..hourlyIntensities_merged i
ON c.Id = i.Id AND c.ActivityHour = i.ActivityHour

SELECT * FROM #temptable


--- SEPERATING DATETIME VALUE IN THE TEMP TABLE --- 

SELECT ActivityHour, LEFT(ActivityHour, CHARINDEX(' ', ActivityHour)+ 7) AS Date,
RIGHT(ActivityHour, CHARINDEX(' ', ActivityHour) + 4) AS Time
FROM #temptable

ALTER TABLE #temptable
ADD Date date 
ALTER TABLE #temptable
ADD Time time

UPDATE #temptable
SET Date = LEFT(ActivityHour, CHARINDEX(' ', ActivityHour)+ 7)

UPDATE #temptable
SET Time = RIGHT(ActivityHour, CHARINDEX(' ', ActivityHour) + 4)

SELECT * FROM #temptable

ALTER TABLE #temptable
DROP COLUMN ActivityHour


-- ADDING COLUMN WITH ONLY THE NUMBER OF THE HOUR --   

ALTER TABLE #temptable
ADD Hour int

UPDATE #temptable
SET Hour = LEFT(Time, CHARINDEX(':', Time) -1)


SELECT * FROM #temptable


--- GROUP BY TIME OF DAY ---

SELECT Time , AVG(calories)
FROM #temptable
GROUP BY Time
ORDER BY AVG(calories) DESC


---------- NEW TABLE ----------


--- LOOKING AT DATA + DELETING NULL VALUES ---
SELECT *
FROM PortfolioProject..heartrate_seconds_merged$
WHERE Time IS NULL

DELETE FROM PortfolioProject..heartrate_seconds_merged$
WHERE Time IS NULL


--- SEPERATING TIME COLUMN INTO DAY AND TIME ---

SELECT Time, LEFT(Time, CHARINDEX(' ', Time)+ 10) AS Date, RIGHT(Time, CHARINDEX(' ', Time) -2) 
FROM PortfolioProject..heartrate_seconds_merged$

ALTER TABLE PortfolioProject..heartrate_seconds_merged$
ADD Date NVARCHAR(255)

ALTER TABLE PortfolioProject..heartrate_seconds_merged$
ADD Time2 NVARCHAR(255)

UPDATE PortfolioProject..heartrate_seconds_merged$
SET Date = LEFT(Time, CHARINDEX(' ', Time)+ 10)

UPDATE PortfolioProject..heartrate_seconds_merged$
SET Time2 = RIGHT(Time, CHARINDEX(' ', Time) -2)

SELECT Date, LEFT(Time, CHARINDEX(' ', Time)+ 7) AS Date2, 
RIGHT(Date, CHARINDEX(' ', Date)- 1) AS TimeNumber, 
RIGHT(Time, CHARINDEX(' ', Time) -2) AS TimeDay
FROM PortfolioProject..heartrate_seconds_merged$

ALTER TABLE PortfolioProject..heartrate_seconds_merged$
ADD TimeNumber NVARCHAR(255)

UPDATE PortfolioProject..heartrate_seconds_merged$
SET TimeNumber = RIGHT(Date, CHARINDEX(' ', Date)- 1)


SELECT CONCAT(TimeNumber,'  ',Time2) AS HourOfDay
FROM PortfolioProject..heartrate_seconds_merged$

ALTER TABLE PortfolioProject..heartrate_seconds_merged$
ADD HourOfDay NVARCHAR(255)

UPDATE PortfolioProject..heartrate_seconds_merged$
SET HourOfDay = CONCAT(TimeNumber,'  ',Time2)

UPDATE PortfolioProject..heartrate_seconds_merged$
SET Date = LEFT(Time, CHARINDEX(' ', Time)+ 7)


ALTER TABLE PortfolioProject..heartrate_seconds_merged$
DROP COLUMN Time2, TimeNumber



--- GROUPING HEART RATE BY HOUR ---

-- First we format the date and time properly --
SELECT CAST(Date AS date) AS datee, CAST(HourOfDay AS time)	 
FROM PortfolioProject..heartrate_seconds_merged$

UPDATE PortfolioProject..heartrate_seconds_merged$
SET Date = CONVERT(date, Date), HourOfDay = CONVERT(time, HourOfDay)

SELECT *
FROM PortfolioProject..heartrate_seconds_merged$

SELECT Id, HourOfDay, AVG(Value)
FROM PortfolioProject..heartrate_seconds_merged$
GROUP BY Id, HourOfDay 
ORDER BY  AVG(Value) DESC

SELECT  Id, AVG(Value)
FROM PortfolioProject..heartrate_seconds_merged$
GROUP BY  Id 
ORDER BY  AVG(Value) DESC
-- We have 7 unique people for this analysis--




-----  NEW TABLE  -----

-- CHANGING THE TABLE NAME --
SELECT TOP 100 *
FROM PortfolioProject..heartrate_seconds_merged


ALTER TABLE PortfolioProject..heartrate_seconds_merged
ADD Id NVARCHAR(50), DateTime NVARCHAR(50), HeartRate NVARCHAR(50)

UPDATE PortfolioProject..heartrate_seconds_merged
SET Id = [Column 0], DateTime = [Column 1], HeartRate = [Column 2]

ALTER TABLE PortfolioProject..heartrate_seconds_merged
DROP COLUMN [Column 0], [Column 1], [Column 2]


-- FINDING AND DELETING NULL VALUES --

SELECT *
FROM PortfolioProject..heartrate_seconds_merged
WHERE DateTime IS NULL

SELECT *
FROM PortfolioProject..heartrate_seconds_merged
WHERE Id IS NULL

SELECT *
FROM PortfolioProject..heartrate_seconds_merged
WHERE HeartRate IS NULL
-- No null values


-- SEPERATING TIME COLUMN INTO DAY AND TIME --

SELECT DateTime, LEFT(DateTime, CHARINDEX(' ', DateTime)+2) AS Date, 
RIGHT(DateTime, CHARINDEX(' ', DateTime) -6) 
FROM PortfolioProject..heartrate_seconds_merged

ALTER TABLE PortfolioProject..heartrate_seconds_merged
ADD Date NVARCHAR(255)

ALTER TABLE PortfolioProject..heartrate_seconds_merged
ADD Time2 NVARCHAR(255)

UPDATE PortfolioProject..heartrate_seconds_merged
SET Date = LEFT(DateTime, CHARINDEX(' ', DateTime)+ 2)

UPDATE PortfolioProject..heartrate_seconds_merged
SET Time2 = RIGHT(DateTime, CHARINDEX(' ', DateTime) -6)

SELECT Date, LEFT(DateTime, CHARINDEX(' ', DateTime)) AS Date2, 
RIGHT(Date, CHARINDEX(' ', Date)- 7) AS TimeNumber, 
RIGHT(DateTime, CHARINDEX(' ', DateTime) -7) AS TimeDay
FROM PortfolioProject..heartrate_seconds_merged

ALTER TABLE PortfolioProject..heartrate_seconds_merged
ADD TimeNumber NVARCHAR(255)

UPDATE PortfolioProject..heartrate_seconds_merged
SET TimeNumber = RIGHT(Date, CHARINDEX(' ', Date)- 7)


SELECT CONCAT(TimeNumber,'  ',Time2) AS Time
FROM PortfolioProject..heartrate_seconds_merged

ALTER TABLE PortfolioProject..heartrate_seconds_merged
ADD Time NVARCHAR(255)

UPDATE PortfolioProject..heartrate_seconds_merged
SET Time = CONCAT(TimeNumber,'  ',Time2)

UPDATE PortfolioProject..heartrate_seconds_merged
SET Date = LEFT(DateTime, CHARINDEX(' ', DateTime))


ALTER TABLE PortfolioProject..heartrate_seconds_merged
DROP COLUMN Time2, TimeNumber


SELECT TOP 1000 * 
FROM PortfolioProject..heartrate_seconds_merged


-- FORMATTING DAY AND TIME --

-- Forgot to format the DateTime column which lead to errors in the time column.
UPDATE PortfolioProject..heartrate_seconds_merged
Set DateTime = CAST(DateTime AS datetime2)

SELECT Time, REPLACE(Time, ':', '')
FROM PortfolioProject..heartrate_seconds_merged

UPDATE PortfolioProject..heartrate_seconds_merged
SET Time = REPLACE(Time, ':', '')



SELECT CAST(Date AS date), CAST(Time AS time)
FROM PortfolioProject..heartrate_seconds_merged


-- Seperating date time again in order to get a better value for the time column
SELECT DateTime, RIGHT(DateTime, CHARINDEX(' ', DateTime)+6)
FROM PortfolioProject..heartrate_seconds_merged

ALTER TABLE PortfolioProject..heartrate_seconds_merged
ADD temptime NVARCHAR(255)

UPDATE PortfolioProject..heartrate_seconds_merged
SET temptime = RIGHT(DateTime, CHARINDEX(' ', DateTime)+6)

SELECT temptime, LEFT(temptime, CHARINDEX(' ', temptime) +2)
FROM PortfolioProject..heartrate_seconds_merged

UPDATE PortfolioProject..heartrate_seconds_merged
SET Time = LEFT(temptime, CHARINDEX(' ', temptime) +2)

ALTER TABLE PortfolioProject..heartrate_seconds_merged
DROP COLUMN temptime


-- Changing HeartRate column to a float in order to perform analysis
UPDATE PortfolioProject..heartrate_seconds_merged
SET HeartRate = CAST(HeartRate AS float)

ALTER TABLE PortfolioProject..heartrate_seconds_merged
ADD Value float 

UPDATE PortfolioProject..heartrate_seconds_merged
SET Value = HeartRate

ALTER TABLE PortfolioProject..heartrate_seconds_merged
DROP COLUMN HeartRate


-- Changing DateTime Column to Only display date --

SELECT CONVERT(date, DateTime)
FROM PortfolioProject..heartrate_seconds_merged

UPDATE PortfolioProject..heartrate_seconds_merged
SET DateTime = CONVERT(date, DateTime)



-- This Query shows us that we have 14 unique participants who's data is made available for us to analyse
SELECT Id, AVG(Value) AS AverageValue
FROM PortfolioProject..heartrate_seconds_merged
GROUP BY Id
ORDER BY Id DESC


-- This Query will give the table we are going to use for further analysis
SELECT DateTime, Id, Time AS Hour, AVG(Value) AS AverageValue
FROM PortfolioProject..heartrate_seconds_merged
GROUP BY Id, Time, DateTime
ORDER BY Id DESC




SELECT TOP 1000 * 
FROM PortfolioProject..heartrate_seconds_merged




-----  USING THE NEWLY CREATED TABLES  -----
-----  JOIN TABLE WITH DAILYACTIVITY TABLE  -----
/* I made a few modifications to the table in excel, creating a new column that adpted the Hour column into a time column that can be used properly*/


SELECT *
FROM PortfolioProject..AverageHeartRate


SELECT *
FROM PortfolioProject..SleepActivityWeight

-- Deleting the null values and useless columns--
DELETE FROM PortfolioProject..AverageHeartRate
WHERE Hour IS NULL

ALTER TABLE PortfolioProject..AverageHeartRate
DROP COLUMN Hour


-- Converting into column into date and time --
SELECT CONVERT(date, DateTime)
FROM PortfolioProject..AverageHeartRate

SELECT CONVERT(time, Hours)
FROM PortfolioProject..AverageHeartRate

UPDATE PortfolioProject..AverageHeartRate
SET Hours = CAST(Hours AS time)

UPDATE PortfolioProject..AverageHeartRate
SET DateTime = CONVERT(date, DateTime)


SELECT Hours, AVG(AverageValue)
FROM PortfolioProject..AverageHeartRate
GROUP BY Hours

SELECT Id, DateTime, Hours, AVG(AverageValue)
FROM PortfolioProject..AverageHeartRate
GROUP BY Id, DateTime, Hours
ORDER BY DateTime
-- I went In a circle bc if I'm not doing a JOIN, all of this is useless.
/* Maybe I can make a join that give us the average heartrate per person (in that case all this is still useless bc
I didn't dates or times, only the id */

SELECT *
FROM PortfolioProject..AverageHeartRate


SELECT Id, AVG(AverageValue)
FROM PortfolioProject..AverageHeartRate
GROUP BY Id


-- Joining the tables --
SELECT *
FROM PortfolioProject..SleepActivityWeight s
JOIN PortfolioProject..AverageHeartRate a
	ON s.Id = a.Id 
	AND 
	s.ActivityDate = a.DateTime
-- Useless query I think
