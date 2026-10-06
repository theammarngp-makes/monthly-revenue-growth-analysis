-- =====================================================================
-- File:     01_null_checks.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Check for NULLs in required columns of monthly_revenue.
-- Expected result on this dataset: 0 rows (verified in Python EDA,
--   see python/02_data_validation.ipynb and docs/data_quality.md).
-- =====================================================================

SELECT
    SUM(CASE WHEN sales_month IS NULL THEN 1 ELSE 0 END)           AS null_sales_month,
    SUM(CASE WHEN current_month_revenue IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    COUNT(*)                                                       AS total_rows
FROM monthly_revenue;

-- Row-level detail of any offending rows (should return zero rows here)
SELECT *
FROM monthly_revenue
WHERE sales_month IS NULL
   OR current_month_revenue IS NULL;
