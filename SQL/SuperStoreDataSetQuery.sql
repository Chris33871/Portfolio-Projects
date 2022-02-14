SELECT count(*)
FROM dbo.SuperstoreDataset

SELECT *
FROM dbo.SuperstoreDataset
ORDER BY 1


-- Checking if Order ID is a Primary key 
SELECT [Order ID], count(*)
FROM dbo.SuperstoreDataset
GROUP BY [Order ID] 
HAVING count(*) > 1 
-- Order ID alone is not a primary key. 


-- Checking for erros in Shipping date and Order date
SELECT * 
FROM PortfolioProject..SuperstoreDataset
WHERE [Ship Date] < [Order Date]
-- There are no instances where the shipping date preceds the order date


-- Findind the distinct shipping modes
SELECT DISTINCT [Ship Mode]
FROM PortfolioProject..SuperstoreDataset


-- Getting the time between the order date and the ship date for the second class shipping mode 
SELECT DATEDIFF(DAY, [Order Date], [Ship Date]) AS NumOfDays, *
FROM PortfolioProject..SuperstoreDataset
WHERE [Ship Mode] = 'Second Class'


-- Getting the maximum and minimum amount of time betwwen the order date and the ship date for the second class shipping mode 
SELECT MIN(a.NumOfDays), MAX(a.NumOfDays)
FROM(
SELECT DATEDIFF(DAY, [Order Date], [Ship Date]) AS NumOfDays, *
FROM PortfolioProject..SuperstoreDataset
WHERE [Ship Mode] = 'Second Class')a


-- Find the amount ordered by customers
SELECT [Customer ID], [Order ID], count(*)
FROM PortfolioProject..SuperstoreDataset
GROUP BY [Customer ID], [Order ID]
ORDER BY [Customer ID]

SELECT * 
FROM PortfolioProject..SuperstoreDataset
WHERE [Order ID] = 'CA-2011-138100'