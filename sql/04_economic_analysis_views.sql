/* =========================================================
   BANK MARKETING ANALYSIS PROJECT
   04_economic_analysis_views.sql
   
   Purpose: Analytical views that power the "Economic Impact" 
   page of the Power BI dashboard.
   - vw_MonthlyEconomicSummary : monthly aggregation
   - vw_MonthlyEconomicTrend   : adds a 3-month moving average
                                 using a SQL window function
   - vw_CorrelationStats       : Pearson correlation coefficients
                                 computed manually in T-SQL between
                                 each macroeconomic indicator and
                                 the conversion outcome
   ========================================================= */

USE BankMarketingDB;
GO

-- 1) Monthly aggregation: client volume, conversions, and average
--    macroeconomic indicators per month
CREATE OR ALTER VIEW dbo.vw_MonthlyEconomicSummary AS
SELECT 
    MonthNumber,
    Month,
    COUNT(*) AS TotalClients,
    SUM(TargetFlag) AS Conversions,
    CAST(SUM(TargetFlag) AS FLOAT) / COUNT(*) AS ConversionRate,
    AVG(EmpVarRate) AS AvgEmpVarRate,
    AVG(ConsPriceIdx) AS AvgConsPriceIdx,
    AVG(ConsConfIdx) AS AvgConsConfIdx,
    AVG(Euribor3m) AS AvgEuribor3m,
    AVG(NrEmployed) AS AvgNrEmployed
FROM dbo.vw_BankMarketing_Clean
GROUP BY MonthNumber, Month;
GO

-- 2) 3-month moving average of ConversionRate, using a window function,
--    to smooth out month-to-month noise and reveal the underlying trend
CREATE OR ALTER VIEW dbo.vw_MonthlyEconomicTrend AS
SELECT *,
    AVG(ConversionRate) OVER (
        ORDER BY MonthNumber 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS ConversionRate_3MonthMA
FROM dbo.vw_MonthlyEconomicSummary;
GO

-- 3) Pearson correlation coefficients (computed manually with the
--    standard formula, no external statistics library) between each
--    macroeconomic indicator and the binary conversion outcome
CREATE OR ALTER VIEW dbo.vw_CorrelationStats AS
SELECT
    -- Euribor3m vs Target
    (COUNT(*) * SUM(CAST(Euribor3m AS FLOAT) * CAST(TargetFlag AS FLOAT)) 
        - SUM(CAST(Euribor3m AS FLOAT)) * SUM(CAST(TargetFlag AS FLOAT)))
    / NULLIF(SQRT(
        (COUNT(*) * SUM(POWER(Euribor3m,2)) - POWER(SUM(Euribor3m),2)) 
        * (COUNT(*) * SUM(POWER(CAST(TargetFlag AS FLOAT),2)) - POWER(SUM(CAST(TargetFlag AS FLOAT)),2))
    ), 0) AS Euribor_Target_Correlation,

    -- ConsConfIdx vs Target
    (COUNT(*) * SUM(CAST(ConsConfIdx AS FLOAT) * CAST(TargetFlag AS FLOAT)) 
        - SUM(CAST(ConsConfIdx AS FLOAT)) * SUM(CAST(TargetFlag AS FLOAT)))
    / NULLIF(SQRT(
        (COUNT(*) * SUM(POWER(ConsConfIdx,2)) - POWER(SUM(ConsConfIdx),2)) 
        * (COUNT(*) * SUM(POWER(CAST(TargetFlag AS FLOAT),2)) - POWER(SUM(CAST(TargetFlag AS FLOAT)),2))
    ), 0) AS ConsConf_Target_Correlation,

    -- EmpVarRate vs Target
    (COUNT(*) * SUM(CAST(EmpVarRate AS FLOAT) * CAST(TargetFlag AS FLOAT)) 
        - SUM(CAST(EmpVarRate AS FLOAT)) * SUM(CAST(TargetFlag AS FLOAT)))
    / NULLIF(SQRT(
        (COUNT(*) * SUM(POWER(EmpVarRate,2)) - POWER(SUM(EmpVarRate),2)) 
        * (COUNT(*) * SUM(POWER(CAST(TargetFlag AS FLOAT),2)) - POWER(SUM(CAST(TargetFlag AS FLOAT)),2))
    ), 0) AS EmpVar_Target_Correlation
FROM dbo.vw_BankMarketing_Clean;
GO

-- Sanity checks
SELECT * FROM dbo.vw_MonthlyEconomicTrend ORDER BY MonthNumber;
SELECT * FROM dbo.vw_CorrelationStats;
