/* =========================================================
   BANK MARKETING ANALYSIS PROJECT
   02_import_data.sql
   
   Purpose: Imports the CSV into a staging table (all NVARCHAR,
   to avoid type-conversion failures), then loads clean, typed
   data into the main dbo.BankMarketing table.

   NOTE: Update the file path below to match your local CSV location.
   ========================================================= */

USE BankMarketingDB;
GO

-- 1) Staging table: everything as text, to avoid BULK INSERT type errors
CREATE TABLE dbo.BankMarketing_Staging (
    age             NVARCHAR(50),
    job             NVARCHAR(50),
    marital         NVARCHAR(50),
    education       NVARCHAR(50),
    [default]       NVARCHAR(50),
    housing         NVARCHAR(50),
    loan            NVARCHAR(50),
    contact         NVARCHAR(50),
    month           NVARCHAR(50),
    day_of_week     NVARCHAR(50),
    duration        NVARCHAR(50),
    campaign        NVARCHAR(50),
    pdays           NVARCHAR(50),
    previous        NVARCHAR(50),
    poutcome        NVARCHAR(50),
    emp_var_rate    NVARCHAR(50),
    cons_price_idx  NVARCHAR(50),
    cons_conf_idx   NVARCHAR(50),
    euribor3m       NVARCHAR(50),
    nr_employed     NVARCHAR(50),
    y               NVARCHAR(50)
);
GO

-- 2) Bulk load the raw CSV (semicolon-delimited)
BULK INSERT dbo.BankMarketing_Staging
FROM 'C:\bank-additional-full.csv'   -- <-- update path if needed
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n'
);
GO

-- Sanity check: should return 41188
SELECT COUNT(*) AS StagingRowCount FROM dbo.BankMarketing_Staging;
GO

-- 3) Clean (strip stray quotes, cast types) and load into the final table
INSERT INTO dbo.BankMarketing
    (Age, Job, Marital, Education, HasDefault, Housing, Loan, Contact,
     Month, DayOfWeek, Duration, Campaign, Pdays, Previous, Poutcome,
     EmpVarRate, ConsPriceIdx, ConsConfIdx, Euribor3m, NrEmployed, Target)
SELECT
    TRY_CAST(REPLACE(age, '"', '') AS INT),
    REPLACE(job, '"', ''),
    REPLACE(marital, '"', ''),
    REPLACE(education, '"', ''),
    REPLACE([default], '"', ''),
    REPLACE(housing, '"', ''),
    REPLACE(loan, '"', ''),
    REPLACE(contact, '"', ''),
    REPLACE(month, '"', ''),
    REPLACE(day_of_week, '"', ''),
    TRY_CAST(REPLACE(duration, '"', '') AS INT),
    TRY_CAST(REPLACE(campaign, '"', '') AS INT),
    TRY_CAST(REPLACE(pdays, '"', '') AS INT),
    TRY_CAST(REPLACE(previous, '"', '') AS INT),
    REPLACE(poutcome, '"', ''),
    TRY_CAST(REPLACE(emp_var_rate, '"', '') AS FLOAT),
    TRY_CAST(REPLACE(cons_price_idx, '"', '') AS FLOAT),
    TRY_CAST(REPLACE(cons_conf_idx, '"', '') AS FLOAT),
    TRY_CAST(REPLACE(euribor3m, '"', '') AS FLOAT),
    TRY_CAST(REPLACE(nr_employed, '"', '') AS FLOAT),
    REPLACE(y, '"', '')
FROM dbo.BankMarketing_Staging;
GO

-- Sanity check: should return 41188
SELECT COUNT(*) AS FinalRowCount FROM dbo.BankMarketing;
GO

-- Data quality check: no NULLs expected in these numeric fields
SELECT 
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END)        AS NullAge,
    SUM(CASE WHEN EmpVarRate IS NULL THEN 1 ELSE 0 END) AS NullEmpVar,
    SUM(CASE WHEN Euribor3m IS NULL THEN 1 ELSE 0 END)  AS NullEuribor
FROM dbo.BankMarketing;
GO

-- 4) Drop the staging table, no longer needed
DROP TABLE dbo.BankMarketing_Staging;
GO
