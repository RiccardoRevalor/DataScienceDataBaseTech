--QUERY:Select the monthly number of calls and the monthly income. Associate the RANK() to each
--month according to its income (1 for the month with the highest income, 2 for the second, etc., the
--last month is the one with the least income). 
SELECT DateMonth, SUM(NumberOfCalls) AS CallsByMonth, SUM(Price) AS MonthlyIncome,
RANK() OVER(ORDER BY SUM(Price) DESC) AS MonthRanking
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
GROUP BY DateMonth