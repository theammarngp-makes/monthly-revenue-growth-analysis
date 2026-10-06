-- =====================================================================
-- File:     03_yoy_growth.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Year-over-Year growth %, using LAG(..., 12).
--
-- COVERAGE NOTE: The dataset spans Oct-2016 through Aug-2018 (23
-- months). A trailing-12-month comparison is only mathematically
-- valid from the 13th month onward -- so YoY is NULL for the first
-- 12 months (Oct-2016 - Sep-2017) by design, not by error.
-- That means only 11 months (Oct-2017 - Aug-2018) have a YoY figure,
-- and even the earliest of those are being compared against a
-- low-base launch period (see docs/metric_definitions.md for the
-- "early-period ramp" caveat that also affects MoM).
-- =====================================================================

SELECT
    sales_month,
    current_month_revenue,
    LAG(current_month_revenue, 12) OVER (ORDER BY sales_month) AS revenue_12mo_prior,
    ROUND(
        (current_month_revenue - LAG(current_month_revenue, 12) OVER (ORDER BY sales_month)) * 100.0
        / NULLIF(LAG(current_month_revenue, 12) OVER (ORDER BY sales_month), 0),
        2
    ) AS yoy_growth_pct
FROM vw_clean_monthly_revenue
ORDER BY sales_month;
