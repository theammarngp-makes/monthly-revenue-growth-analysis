-- =====================================================================
-- File:     02_duplicate_checks.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Check for duplicate month rows (grain violation).
-- Expected result on this dataset: 0 duplicate months (verified in
--   Python EDA; sales_month is the table's primary key).
-- =====================================================================

SELECT
    sales_month,
    COUNT(*) AS occurrences
FROM monthly_revenue
GROUP BY sales_month
HAVING COUNT(*) > 1
ORDER BY sales_month;

-- Sanity check: total row count vs. distinct month count should match
SELECT
    COUNT(*)                    AS total_rows,
    COUNT(DISTINCT sales_month) AS distinct_months
FROM monthly_revenue;
