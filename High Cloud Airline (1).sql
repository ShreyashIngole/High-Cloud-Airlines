create database Airline;

-- 1. Date Field 
SELECT
  *,
  -- build a DATE from Year, Month and Day (MySQL)
  STR_TO_DATE(CONCAT(Year, '-', `Month (#)`, '-', Day), '%Y-%m-%d') AS FlightDate
FROM maindata
LIMIT 50;

-- 2A. Load Factor - Monthly

WITH md AS (
  SELECT 
    *, 
    STR_TO_DATE(CONCAT(`Year`, '-', `Month (#)`, '-', `Day`), '%Y-%m-%d') AS FlightDate
  FROM maindata
)
SELECT
  `Year`,
  `Month (#)` AS MonthNo,
  MONTHNAME(STR_TO_DATE(CONCAT(`Year`, '-', `Month (#)`, '-01'), '%Y-%m-%d')) AS MonthName,
  ROUND(SUM(`# Transported Passengers`) * 100.0 / NULLIF(SUM(`# Available Seats`), 0), 2) AS LoadFactorPct
FROM md
GROUP BY `Year`, `Month (#)`
ORDER BY `Year`, `Month (#)`;

-- 2B. Load Factor - Quarterly

WITH md AS (
  SELECT 
    *,
    STR_TO_DATE(CONCAT(`Year`, '-', `Month (#)`, '-', `Day`), '%Y-%m-%d') AS FlightDate
  FROM maindata
),
quarter_data AS (
  SELECT
    `Year`,
    QUARTER(FlightDate) AS QuarterNo,
    `# Transported Passengers`,
    `# Available Seats`
  FROM md
)
SELECT
  `Year`,
  QuarterNo,
  CONCAT('Q', QuarterNo) AS QuarterName,
  ROUND(SUM(`# Transported Passengers`) * 100.0 / NULLIF(SUM(`# Available Seats`), 0), 2) AS LoadFactorPct
FROM quarter_data
GROUP BY `Year`, QuarterNo
ORDER BY `Year`, QuarterNo;

-- 2C. Load Factor - Yearly

WITH md AS (
  SELECT *, STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`),'%Y-%m-%d') AS FlightDate
  FROM maindata
)
SELECT
  `Year`,
  SUM(`# Transported Passengers`) * 100.0 / NULLIF(SUM(`# Available Seats`),0) AS LoadFactorPct
FROM md
GROUP BY `Year`
ORDER BY `Year`;

-- 3. Load Factor by Carrier Name

WITH md AS (
  SELECT *, STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`),'%Y-%m-%d') AS FlightDate
  FROM maindata
)
SELECT
  `Carrier Name`,
  SUM(`# Transported Passengers`) AS TotalPassengers,
  SUM(`# Available Seats`)   AS TotalSeats,
  SUM(`# Transported Passengers`) * 100.0 / NULLIF(SUM(`# Available Seats`),0) AS LoadFactorPct
FROM md
GROUP BY `Carrier Name`
ORDER BY TotalPassengers DESC;

-- 4. Top 10 Carrier Names by passengers

WITH md AS (
  SELECT *, STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`),'%Y-%m-%d') AS FlightDate
  FROM maindata
)
SELECT
  `Carrier Name`,
  SUM(`# Transported Passengers`) AS TotalPassengers
FROM md
GROUP BY `Carrier Name`
ORDER BY TotalPassengers DESC
LIMIT 10;

-- 5. Top Routes (From–To City) by Number of Flights

WITH md AS (
  SELECT *, STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`),'%Y-%m-%d') AS FlightDate
  FROM maindata
)
SELECT
  `From - To City` AS Route,
  COUNT(*)                AS RouteRecords,
  SUM(`# Departures Performed`) AS DeparturesPerformed -- optional if this column counts flights
FROM md
GROUP BY `From - To City`
ORDER BY RouteRecords DESC
LIMIT 10;

-- 5. Load Factor: Weekend vs Weekday

WITH md AS (
  SELECT *, STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`),'%Y-%m-%d') AS FlightDate
  FROM maindata
)
SELECT
  CASE WHEN DAYOFWEEK(FlightDate) IN (1,7) THEN 'Weekend' ELSE 'Weekday' END AS DayType,
  SUM(`# Transported Passengers`) AS TotalPassengers,
  SUM(`# Available Seats`)       AS TotalSeats,
  SUM(`# Transported Passengers`) * 100.0 / NULLIF(SUM(`# Available Seats`),0) AS LoadFactorPct
FROM md
GROUP BY DayType;

-- 6. Number of flights based on Distance Group

WITH md AS (
  SELECT *, STR_TO_DATE(CONCAT(`Year`,'-',`Month (#)`,'-',`Day`),'%Y-%m-%d') AS FlightDate
  FROM maindata
)
SELECT
  `%Distance Group ID` AS DistanceGroup,
  COUNT(*)               AS NumRecords,
  SUM(`# Departures Performed`) AS FlightsPerformed -- if this column counts flights
FROM md
GROUP BY `%Distance Group ID`
ORDER BY NumRecords DESC;
