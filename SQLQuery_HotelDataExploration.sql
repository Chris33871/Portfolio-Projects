
/*

Hotel Historical Data Exploration 

*/

---------------------------------------------------------------------------------------------------------------------
-- Unifying the Data + Finding the Revenue + Finding if the revenue increases per year + Broken down by Hotel type
WITH Hotels AS (
SELECT *
FROM dbo.[2018]
UNION
SELECT *
FROM dbo.[2019]
UNION
SELECT *
FROM dbo.[2020]
)
SELECT arrival_date_year, hotel,
ROUND(SUM((stays_in_week_nights + stays_in_weekend_nights) * adr),2) AS Revenue
FROM Hotels
GROUP BY arrival_date_year, hotel
ORDER BY Revenue DESC



---------------------------------------------------------------------------------------------------------------------
-- Joining Further Tables
WITH Hotels AS (
SELECT *
FROM dbo.[2018]
UNION
SELECT *
FROM dbo.[2019]
UNION
SELECT *
FROM dbo.[2020]
) 
SELECT *
FROM Hotels a
LEFT JOIN dbo.market_segment_table b
ON a.market_segment = b.market_segment
LEFT JOIN dbo.meal_cost c 
ON c.meal = a.meal




