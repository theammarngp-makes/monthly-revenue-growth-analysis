-- =====================================================================
-- File:     01_monthly_revenue.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Base monthly revenue series -- the foundation every other
--           analysis query builds on.
-- =====================================================================

SELECT
    sales_month,
    current_month_revenue
FROM vw_clean_monthly_revenue
ORDER BY sales_month;
