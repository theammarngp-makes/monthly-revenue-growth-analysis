-- =====================================================================
-- File:     04_running_revenue.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Cumulative (running total) revenue since the start of the
--           observed period, using SUM() OVER an ordered window frame.
-- =====================================================================

SELECT
    sales_month,
    current_month_revenue,
    SUM(current_month_revenue) OVER (
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM vw_clean_monthly_revenue
ORDER BY sales_month;
