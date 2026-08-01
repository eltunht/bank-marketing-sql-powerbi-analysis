/* =========================================================
   BANK MARKETING ANALYSIS PROJECT
   01_create_database_and_table.sql
   
   Purpose: Creates the database and the main staging structure
   Source: bank-additional-full.csv (UCI Bank Marketing Dataset)
   Tool: SQL Server Management Studio 2022
   ========================================================= */

-- 1) Create database
CREATE DATABASE BankMarketingDB;
GO

USE BankMarketingDB;
GO

-- 2) Main table (holds the cleaned, typed data)
CREATE TABLE dbo.BankMarketing (
    ClientID        INT IDENTITY(1,1) PRIMARY KEY,
    Age             INT             NULL,
    Job             NVARCHAR(50)    NULL,
    Marital         NVARCHAR(30)    NULL,
    Education       NVARCHAR(50)    NULL,
    HasDefault      NVARCHAR(10)    NULL,
    Housing         NVARCHAR(10)    NULL,
    Loan            NVARCHAR(10)    NULL,
    Contact         NVARCHAR(20)    NULL,
    Month           NVARCHAR(10)    NULL,
    DayOfWeek       NVARCHAR(10)    NULL,
    Duration        INT             NULL,
    Campaign        INT             NULL,
    Pdays           INT             NULL,
    Previous        INT             NULL,
    Poutcome        NVARCHAR(20)    NULL,
    EmpVarRate      FLOAT           NULL,
    ConsPriceIdx    FLOAT           NULL,
    ConsConfIdx     FLOAT           NULL,
    Euribor3m       FLOAT           NULL,
    NrEmployed      FLOAT           NULL,
    Target          NVARCHAR(5)     NULL
);
GO
