--QUERY: Select the yearly income for each phone rate, the total income for each phone rate, the total
--yearly income and the total income.
SELECT DateYear, phoneRateType, SUM(Price) AS YearlyIncomeForRate, SUM(SUM(Price))
OVER (PARTITION BY phoneRateType) AS TotIncomeForRate,
SUM(SUM(Price)) OVER (PARTITION BY DateYear) AS TotYearlyIncome,
SUM(SUM(Price)) OVER () AS TotIncome
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE F.Id_time = T.Id_time and F.Id_phoneRate = P.Id_phoneRate
GROUP BY DateYear, phoneRateType