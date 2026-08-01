/* =========================================================
   BANK MARKETING ANALYSIS PROJECT
   03_create_clean_view.sql
   
   Purpose: Final version of the cleaned, analysis-ready view.
   - Normalizes text casing (Job, Education)
   - Maps cryptic codes to readable labels (Education, Poutcome)
   - Adds derived columns used across the Power BI dashboard:
     TargetFlag, AgeGroup, MonthNumber
   ========================================================= */

USE BankMarketingDB;
GO

CREATE OR ALTER VIEW dbo.vw_BankMarketing_Clean AS
SELECT
    ClientID,
    Age,

    -- Capitalize Job (e.g. "blue-collar" -> "Blue-collar")
    UPPER(LEFT(CASE WHEN Job = 'unknown' THEN 'Unknown' ELSE Job END, 1))
        + LOWER(SUBSTRING(CASE WHEN Job = 'unknown' THEN 'Unknown' ELSE Job END, 2, 50)) AS Job,

    Marital,

    -- Map Education codes to readable labels
    CASE Education
        WHEN 'basic.4y'             THEN 'Basic Education (4 years)'
        WHEN 'basic.6y'             THEN 'Basic Education (6 years)'
        WHEN 'basic.9y'             THEN 'Basic Education (9 years)'
        WHEN 'high.school'          THEN 'High School'
        WHEN 'illiterate'           THEN 'Illiterate'
        WHEN 'professional.course'  THEN 'Professional Course'
        WHEN 'university.degree'    THEN 'University Degree'
        WHEN 'unknown'              THEN 'Unknown'
        ELSE Education
    END AS Education,

    HasDefault, Housing, Loan, Contact, Month, DayOfWeek,
    Duration, Campaign, Pdays, Previous,

    -- Rename "nonexistent" to a clearer label
    CASE WHEN Poutcome = 'nonexistent' THEN 'No Previous Contact' ELSE Poutcome END AS Poutcome,

    EmpVarRate, ConsPriceIdx, ConsConfIdx, Euribor3m, NrEmployed,
    Target,

    -- Numeric flag for Target, used in DAX measures
    CASE WHEN Target = 'yes' THEN 1 ELSE 0 END AS TargetFlag,

    -- Age bucketed into groups for demographic analysis
    CASE
        WHEN Age < 30 THEN '18-29'
        WHEN Age < 40 THEN '30-39'
        WHEN Age < 50 THEN '40-49'
        WHEN Age < 60 THEN '50-59'
        ELSE '60+'
    END AS AgeGroup,

    -- Numeric month, used for chronological sorting in Power BI
    CASE Month
        WHEN 'jan' THEN 1  WHEN 'feb' THEN 2  WHEN 'mar' THEN 3
        WHEN 'apr' THEN 4  WHEN 'may' THEN 5  WHEN 'jun' THEN 6
        WHEN 'jul' THEN 7  WHEN 'aug' THEN 8  WHEN 'sep' THEN 9
        WHEN 'oct' THEN 10 WHEN 'nov' THEN 11 WHEN 'dec' THEN 12
    END AS MonthNumber
FROM dbo.BankMarketing;
GO

-- Sanity checks
SELECT TOP 10 * FROM dbo.vw_BankMarketing_Clean;
SELECT COUNT(*) FROM dbo.vw_BankMarketing_Clean;   -- should return 41188
