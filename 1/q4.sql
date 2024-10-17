--QUERY: For each day in July 2003, select the total income and the average income over the last 3 days
SELECT DayDate AS Day, SUM(Price) AS IncomePerDay, 
AVG(SUM(Price)) OVER (ORDER BY DayDate RANGE BETWEEN INTERVAL '2' Day PRECEDING AND CURRENT ROW) AS AvgIncomeTrailing3Days
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
AND DateMonth = '7-2003'
GROUP BY DayDate