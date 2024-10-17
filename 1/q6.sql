--QUERY: Consider the year 2003. Separately for phone rate and month, analyze (i) the total income, (ii) the
--percentage of income with respect to the total revenue considering all the phone rates, (iii) the
--percentage of income with respect to the total revenue considering all the months
SELECT P.ID_phoneRate, DateMonth,
SUM(Price) AS TotalIncome, --(i)
SUM(Price) / SUM(SUM(Price)) OVER (PARTITION BY P.ID_phoneRate) AS PercPhoneRate, --(ii)
SUM(Price) / SUM(SUM(Price)) OVER (PARTITION BY DateMonth) AS PercMonths --(iii)
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE F.ID_time = T.ID_time AND P.ID_phoneRate = F.ID_phoneRate
AND DateYear = 2003
GROUP BY P.ID_phoneRate, DateMonth