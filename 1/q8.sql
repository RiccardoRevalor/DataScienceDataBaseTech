--QUERY: Consider the year 2003. Analyze the total number of calls for (i) separately for each month and
--(ii) separately for each month, phone rate and caller region and (iii) separately for each month,
--phone rate and receiver region.
SELECT DateMonth AS Month, phoneRateType as RateType, LOCC.Region as CallerRegion, LOCR.Region as ReceiverRegion,
SUM(NumberOfCalls) AS CallsPerMonth
FROM FACTS F,  TIMEDIM T, PHONERATE P, LOCATION LOCR, LOCATION LOCC
WHERE F.ID_time = T.ID_time AND F.ID_phoneRate = P.ID_phoneRate
AND F.ID_location_Caller = LOCC.ID_location
AND F.ID_location_Receiver = LOCR.ID_location
AND DateYear = 2003
GROUP BY GROUPING SETS ((DateMonth), (DateMonth, phoneRateType, LOCC.Region), (DateMonth, phoneRateType, LOCR.Region))
ORDER BY DateMonth


