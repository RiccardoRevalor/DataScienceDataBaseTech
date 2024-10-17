--QUERY: For each caller region, select the monthly number of calls and the cumulative monthly number of
--calls from the beginning of the year.
SELECT Region, DateYear AS Year, DateMonth AS Month, SUM(NumberOfCalls) AS MonthlyCalls,
SUM(SUM(NumberOfCalls)) OVER (PARTITION BY Region, DateYear ORDER BY DateMonth ROWS UNBOUNDED PRECEDING) AS TrailingYearlyCallsForRegion
FROM FACTS F, TIMEDIM T, LOCATION L
WHERE F.ID_location_Caller = L.ID_location
AND F.ID_time = T.ID_time
GROUP BY DateMonth, DateYear, Region