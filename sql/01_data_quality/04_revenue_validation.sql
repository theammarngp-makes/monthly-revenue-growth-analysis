-- =====================================================================
-- File:     04_revenue_validation.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Validate revenue values are non-negative, non-zero, and
--           within a plausible range given the observed distribution.
-- Expected result on this dataset: 0 negative, 0 zero values.
--   Range observed: 43,000 - 1,061,000 (verified in Python EDA).
-- =====================================================================

-- 1. Negative or zero revenue (impossible for a revenue figure)
SELECT sales_month, current_month_revenue
FROM monthly_revenue
WHERE current_month_revenue <= 0;

-- 2. Distribution summary, used to sanity-check for implausible outliers
--    (does NOT remove anything -- for visibility only)
SELECT
    MIN(current_month_revenue)           AS min_revenue,
    MAX(current_month_revenue)           AS max_revenue,
    ROUND(AVG(current_month_revenue), 2) AS avg_revenue,
    ROUND(STDDEV_POP(current_month_revenue), 2) AS stddev_revenue
FROM monthly_revenue;

-- 3. Flag months more than 3 standard deviations from the mean for
--    manual review (informational only -- not an automatic exclusion,
--    per this project's rule of never silently removing data)
WITH stats AS (
    SELECT
        AVG(current_month_revenue)        AS avg_rev,
        STDDEV_POP(current_month_revenue) AS std_rev
    FROM monthly_revenue
)
SELECT
    m.sales_month,
    m.current_month_revenue,
    ROUND((m.current_month_revenue - s.avg_rev) / NULLIF(s.std_rev, 0), 2) AS z_score
FROM monthly_revenue m
CROSS JOIN stats s
WHERE ABS((m.current_month_revenue - s.avg_rev) / NULLIF(s.std_rev, 0)) > 3
ORDER BY m.sales_month;
