-- =====================================================================
-- File:     04_recent_performance.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Compare the last 3 months against the preceding 3 months
--           to answer "is the business improving or deteriorating
--           right now?" -- a more stable read than a single MoM figure.
--
-- MySQL has no FILTER (WHERE ...) clause; conditional aggregation
-- (AVG(CASE WHEN ... THEN ... END)) is the portable equivalent used
-- throughout this file.
-- =====================================================================

WITH ranked AS (
    SELECT
        sales_month,
        current_month_revenue,
        ROW_NUMBER() OVER (ORDER BY sales_month DESC) AS months_from_latest
    FROM vw_clean_monthly_revenue
),
buckets AS (
    SELECT
        *,
        CASE
            WHEN months_from_latest <= 3 THEN 'last_3_months'
            WHEN months_from_latest <= 6 THEN 'previous_3_months'
            ELSE NULL
        END AS period_bucket
    FROM ranked
)
SELECT
    period_bucket,
    MIN(sales_month) AS period_start,
    MAX(sales_month) AS period_end,
    ROUND(AVG(current_month_revenue), 2) AS avg_monthly_revenue,
    SUM(current_month_revenue)           AS total_revenue
FROM buckets
WHERE period_bucket IS NOT NULL
GROUP BY period_bucket
ORDER BY period_bucket DESC;

-- Single summary row with the percentage delta between the two periods
WITH ranked AS (
    SELECT
        sales_month,
        current_month_revenue,
        ROW_NUMBER() OVER (ORDER BY sales_month DESC) AS months_from_latest
    FROM vw_clean_monthly_revenue
),
agg AS (
    SELECT
        AVG(CASE WHEN months_from_latest <= 3 THEN current_month_revenue END)               AS last_3_avg,
        AVG(CASE WHEN months_from_latest BETWEEN 4 AND 6 THEN current_month_revenue END)    AS prior_3_avg
    FROM ranked
)
SELECT
    ROUND(last_3_avg, 2)  AS last_3_months_avg_revenue,
    ROUND(prior_3_avg, 2) AS prior_3_months_avg_revenue,
    ROUND((last_3_avg - prior_3_avg) / NULLIF(prior_3_avg, 0) * 100, 2) AS pct_change
FROM agg;
