Bank Marketing Analysis — SQL Server + Power BI

End-to-end analytics project on the UCI Bank Marketing Dataset (via Kaggle): raw CSV → SQL Server database → analytical SQL views → interactive Power BI dashboard.

Tools
SQL Server Management Studio 2022 — database design, data cleaning, aggregation, window functions, manually computed Pearson correlation
Power BI Desktop — 3-page interactive dashboard with slicers, KPI cards, and DAX measures
Dataset
Source: bank-additional-full.csv, 41,188 client records from a Portuguese bank's telemarketing campaign
Target variable: whether the client subscribed to a term deposit (yes/no)
Project Structure
sql/
  01_create_database_and_table.sql   -- database + table schema
  02_import_data.sql                 -- BULK INSERT + data cleaning/typing
  03_create_clean_view.sql           -- analysis-ready view (labels, buckets, flags)
  04_economic_analysis_views.sql     -- monthly aggregation, moving average, correlation
powerbi/
  bank_marketing_dashboard.pbix
screenshots/
  overview.png
  demographics_campaign.png
  economic_impact.png
SQL Highlights
Staging-table pattern to safely import a semicolon-delimited CSV with quoted text fields via BULK INSERT
Data cleaning and relabeling with CASE / NULLIF (e.g. mapping basic.4y → Basic Education (4 years))
Window function for a 3-month moving average: AVG(...) OVER (ORDER BY MonthNumber ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
Pearson correlation coefficient computed manually in T-SQL (no external stats library) between macroeconomic indicators and the conversion outcome
Dashboard

Page 1 — Overview: KPI cards (total clients, conversion rate, avg. call duration), monthly contact volume, conversions by contact type, conversion rate by previous outcome, overall campaign outcome

Page 2 — Demographics & Campaign: conversion rate by age group and job, education × marital status matrix, client volume distribution by job, conversion rate by number of contacts

Page 3 — Economic Impact: correlation KPI cards, conversion rate trend (raw vs. 3-month moving average), conversion rate vs. employment variation rate

Key Findings
Diminishing returns on repeated contact — conversion rate drops sharply after 2–3 contact attempts with the same client
Channel matters — cellular contact converts at a substantially higher rate than landline (telephone)
Past success predicts future success — clients who said "yes" in a previous campaign convert at a much higher rate than first-time contacts
U-shaped age effect — the youngest (18–29) and oldest (60+) age groups convert best; middle-aged clients convert least
Volume vs. quality trade-off by month — May had the highest contact volume (13,769 clients) but one of the lowest conversion rates (6.4%); months with small, seemingly targeted outreach (March, September, October, December) saw conversion rates of 44–50%
Macroeconomic correlation — Euribor rate (r ≈ -0.31) and employment variation rate (r ≈ -0.30) are moderately negatively correlated with conversion; consumer confidence index shows almost no correlation (r ≈ 0.05). In stronger economic conditions, clients are less inclined toward term deposits.
How to Reproduce
Run the SQL scripts in sql/ in numeric order against SQL Server 2022 (update the CSV path in 02_import_data.sql to match your local file location)
Open powerbi/bank_marketing_dashboard.pbix in Power BI Desktop
Point the data source to your own BankMarketingDB instance (Home → Transform Data → Data source settings)
Refresh
