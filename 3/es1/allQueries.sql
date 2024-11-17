--1
SELECT DateYear, phoneRateType, SUM(Price) AS YearlyIncomeForRate, SUM(SUM(Price))
OVER (PARTITION BY phoneRateType) AS TotIncomeForRate,
SUM(SUM(Price)) OVER (PARTITION BY DateYear) AS TotYearlyIncome,
SUM(SUM(Price)) OVER () AS TotIncome
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE F.Id_time = T.Id_time and F.Id_phoneRate = P.Id_phoneRate
GROUP BY DateYear, phoneRateType


--2
SELECT DateMonth, SUM(NumberOfCalls) AS CallsByMonth, SUM(Price) AS MonthlyIncome,
RANK() OVER(ORDER BY SUM(Price) DESC) AS MonthRanking
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
GROUP BY DateMonth


--3
SELECT DateMonth AS Month, SUM(NumberOfCalls) AS TotNumberOfCalls, 
RANK() OVER (ORDER BY SUM(NumberOfCalls) DESC) AS MonthRankingByNumCalls
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
AND DateYear = 2003
GROUP BY DateMonth;



--4
SELECT PhoneRateType, DateMonth, SUM(SUM(Price)) AS IncomePerMonth, 
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE F.ID_time = T.ID_time
AND F.ID_phoneRate = P.ID_phoneRate
AND DateMonth = '7-2003'
GROUP BY DateMonth, P.PhoneRateType



--5
SELECT DateMonth, DateYear, SUM(Price) as MonthlyIncome, 
SUM(SUM(Price)) OVER (PARTITION BY DateYear ORDER BY DateMonth ROWS UNBOUNDED PRECEDING) AS TrailingYearlyIncome
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
GROUP BY DateMonth, DateYear



--6
SELECT P.ID_phoneRate, DateMonth,
SUM(Price) AS TotalIncome, --(i)
SUM(Price) / SUM(SUM(Price)) OVER (PARTITION BY P.ID_phoneRate) AS PercPhoneRate, --(ii)
SUM(Price) / SUM(SUM(Price)) OVER (PARTITION BY DateMonth) AS PercMonths --(iii)
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE F.ID_time = T.ID_time AND P.ID_phoneRate = F.ID_phoneRate
AND DateYear = 2003
GROUP BY P.ID_phoneRate, DateMonth


--Starting from the data warehouse described in the first laboratory practice (and whose logical
--scheme is shown in the Table 1), define two materialized views useful for reducing the response times of at
--least three of the 6 queries listed below


--MV THAT OPTMIIZES QUERY 2,3,5
CREATE MATERIALIZED VIEW OptimizeQuery2_3_5 
BUILD IMMEDIATE
AS 
SELECT DateMonth, DateYear, SUM(Price) as MonthlyIncome, SUM(NumberOfCalls) AS TotNumberOfCalls
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
GROUP BY DateMonth, DateYear


--MV THAT OPTIMIZES QUERY 3,4
CREATE MATERIALIZED VIEW OptimizeQuery3_4 
BUILD IMMEDIATE
AS
SELECT PhoneRateType, DateMonth,  SUM(NumberOfCalls) AS NumCalls, SUM(Price) AS TotPrice
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE  F.ID_time = T.ID_time AND F.ID_phoneRate = P.ID_phoneRate
GROUP BY DateMonth, P.PhoneRateType


--ASSUMING CREATE MATERIALIZED VIEW IS NOT AVAILABLE, CREATE THE TABLES THAT WOULD BE USED TO CREATE THE MATERIALIZED VIEWS
CREATE TABLE VM1(
    DateMonth VARCHAR(15) CHECK (DateMonth IS NOT NULL),
    DateYear INTEGER CHECK (DateYear IS NOT NULL),
    MonthlyIncome FLOAT CHECK (MonthlyIncome IS NOT NULL),
    TotNumberOfCalls INTEGER CHECK (TotNumberOfCalls IS NOT NULL));
INSERT INTO VM1(DateMonth, DateYear, MonthlyIncome, TotNumberOfCalls)
(SELECT DateMonth, DateYear, SUM(Price) as MonthlyIncome, SUM(NumberOfCalls) AS TotNumberOfCalls
FROM FACTS F, TIMEDIM T
WHERE F.ID_time = T.ID_time
GROUP BY DateMonth, DateYear);

CREATE TABLE VM2(
    PhoneRateType VARCHAR(20) CHECK (PhoneRateType IS NOT NULL),
    DateMonth VARCHAR(15) CHECK (DateMonth IS NOT NULL),
    NumCalls INTEGER CHECK (NumCalls IS NOT NULL),
    TotPrice FLOAT CHECK (TotPrice IS NOT NULL));
INSERT INTO VM2(PhoneRateType, DateMonth, NumCalls, TotPrice)
(SELECT PhoneRateType, DateMonth,  SUM(NumberOfCalls) AS NumCalls, SUM(Price) AS TotPrice
FROM FACTS F, TIMEDIM T, PHONERATE P
WHERE  F.ID_time = T.ID_time AND F.ID_phoneRate = P.ID_phoneRate
GROUP BY DateMonth, P.PhoneRateType);



--NOW, MANUALLY CREATE THE TRIGGERS TO UPDATE THE VM1, VM2 TABLES WHEN THE FACTS TABLE IS UPDATED

--TRIGGER TO UPDATE VM1
CREATE OR REPLACE TRIGGER UpdateVM1
AFTER INSERT ON FACTS
FOR EACH ROW 
DECLARE
N NUMBER;
V_DateMonth VARCHAR(15);
V_DateYear INTEGER;
BEGIN
SELECT DateMonth INTO V_DateMonth 
FROM TIMEDIM 
WHERE ID_time = :NEW.ID_time;

SELECT DateYear INTO V_DateYear 
FROM TIMEDIM 
WHERE ID_time = :NEW.ID_time;

SELECT COUNT(*) INTO N
FROM VM1
WHERE DateMonth = V_DateMonth AND DateYear = V_DateYear;

if (N>0) then
    update VM1
    set MonthlyIncome = MonthlyIncome + :NEW.Price,
    TotNumberOfCalls = TotNumberOfCalls + :NEW.NumberOfCalls
    where DateMonth = V_DateMonth AND DateYear = V_DateYear;
else
    insert into VM1(DateMonth, DateYear, MonthlyIncome, TotNumberOfCalls)
    values(V_DateMonth, V_DateYear, :NEW.Price, :NEW.NumberOfCalls);
end if;
END;

--TRIGGER TO UPDATE VM2
CREATE OR REPLACE TRIGGER UpdateVM2
AFTER INSERT ON FACTS
FOR EACH ROW
DECLARE
N NUMBER;
V_PhoneRateType VARCHAR(20);
V_DateMonth VARCHAR(15);
BEGIN

SELECT DateMonth INTO V_DateMonth 
FROM TIMEDIM 
WHERE ID_time = :NEW.ID_time;

select PhoneRateType into V_PhoneRateType
from PHONERATE
where ID_phoneRate = :NEW.ID_phoneRate; 

select COUNT(*) into N
from VM2
where DateMonth = V_DateMonth and PhoneRateType = V_PhoneRateType;

if (N>0) then
    update VM2
    set NumCalls = NumCalls + :NEW.NumberOfCalls,
    TotPrice = TotPrice+ :NEW.Price
    where DateMonth = V_DateMonth and PhoneRateType = V_PhoneRateType; 

else
    insert into VM2(PhoneRateType, DateMonth, NumCalls, TotPrice)
    values(V_PhoneRateType, V_DateMonth, :NEW.NumberOfCalls, :NEW.Price);

end if;

END;

