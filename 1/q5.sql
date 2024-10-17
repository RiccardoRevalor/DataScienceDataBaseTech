--QUERY: Select the monthly income and the cumulative monthly income from the beginning of the year.
SELECT DateMonth, DateYear, SUM(Price) as MonthlyIncome, 
SUM(SUM(Price)) OVER (PARTITION BY DateYear ORDER BY DateMonth ROWS UNBOUNDED PRECEDING) AS TrailingYearlyIncome
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
GROUP BY DateMonth, DateYear