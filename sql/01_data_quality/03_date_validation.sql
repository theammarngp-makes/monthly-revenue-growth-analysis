-- =====================================================================
-- File:     03_date_validation.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4 (uses WITH RECURSIVE, available
--           since MySQL 8.0.1 — not valid on MySQL 5.7 or earlier)
-- Purpose:  Validate the month sequence is continuous (no gap months)
--           and that every value falls on the first of the month.
-- Expected result on this dataset: continuous Oct-2016 -> Aug-2018,
--   23 of 23 expected months present, 0 gaps (verified in Python EDA).
-- =====================================================================

-- 1. Confirm every date is stored as the first of the month
SELECT sales_month
FROM monthly_revenue
WHERE DAY(sales_month) <> 1;

-- 2. Gap detection: generate the full expected month series between
--    min and max with a recursive CTE, then LEFT JOIN back to find
--    any missing months. MySQL has no generate_series() equivalent,
--    so the series is built recursively instead.
WITH RECURSIVE bounds AS (
    SELECT MIN(sales_month) AS min_month, MAX(sales_month) AS max_month
    FROM monthly_revenue
),
expected_months AS (
    SELECT min_month AS sales_month, max_month
    FROM bounds
    UNION ALL
    SELECT DATE_ADD(sales_month, INTERVAL 1 MONTH), max_month
    FROM expected_months
    WHERE DATE_ADD(sales_month, INTERVAL 1 MONTH) <= max_month
)
SELECT e.sales_month AS missing_month
FROM expected_months e
LEFT JOIN monthly_revenue m ON e.sales_month = m.sales_month
WHERE m.sales_month IS NULL
ORDER BY e.sales_month;

-- 3. Confirm chronological range for documentation.
--    TIMESTAMPDIFF replaces PostgreSQL's DATE_PART-based month math.
SELECT
    MIN(sales_month)                                        AS first_month,
    MAX(sales_month)                                        AS last_month,
    COUNT(*)                                                AS months_present,
    TIMESTAMPDIFF(MONTH, MIN(sales_month), MAX(sales_month)) + 1
                                                             AS months_expected
FROM monthly_revenue;
