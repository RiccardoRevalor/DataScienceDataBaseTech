--QUERY:For each month in 2003, select the total number of calls. Associate the RANK() to each month
--according to its total number of calls (1 for the month with the highest number of calls, 2 for the
--second, etc., the last month is the one with the least number of calls).
SELECT DateMonth AS Month, SUM(NumberOfCalls) AS TotNumberOfCalls, 
RANK() OVER (ORDER BY SUM(NumberOfCalls) DESC) AS MonthRankingByNumCalls
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
AND DateYear = 2003
GROUP BY DateMonth;