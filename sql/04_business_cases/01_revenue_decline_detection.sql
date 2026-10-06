-- =====================================================================
-- File:     01_revenue_decline_detection.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Flag every month where revenue declined vs. the prior
--           month, and measure how many consecutive months of
--           decline preceded it (a streak, not just a single flag).
--
-- Business use: a single red month can be noise. A streak of 2+ is
-- what should trigger a management review.
--
-- IMPLEMENTATION NOTE: this uses the "gaps and islands" technique.
-- ROW_NUMBER() minus a running SUM(is_decline) produces a constant
-- streak_group value for each unbroken run of decline months, but
-- that group also absorbs the single non-decline row that precedes
-- the run (that is how the arithmetic works). The inner
-- COUNT(CASE WHEN is_decline = 1 THEN 1 END) -- MySQL has no FILTER
-- (WHERE ...) clause, so conditional aggregation is used instead --
-- is therefore required to count only the decline rows within that
-- group; a plain COUNT(*) would overcount by including the leading
-- non-decline row. This was verified against the processed data: the
-- correct result has a maximum streak of 1 anywhere in the series,
-- and dropping the CASE WHEN (using plain COUNT(*) instead) incorrectly
-- produces a maximum of 2.
-- =====================================================================

WITH mom AS (
    SELECT
        sales_month,
        current_month_revenue,
        ROUND(
            (current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY sales_month)) * 100.0
            / NULLIF(LAG(current_month_revenue) OVER (ORDER BY sales_month), 0),
            2
        ) AS mom_growth_pct
    FROM vw_clean_monthly_revenue
),
flagged AS (
    SELECT
        *,
        CASE WHEN mom_growth_pct < 0 THEN 1 ELSE 0 END AS is_decline
    FROM mom
),
grouped AS (
    SELECT
        *,
        ROW_NUMBER() OVER (ORDER BY sales_month)
          - SUM(is_decline) OVER (ORDER BY sales_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
          AS streak_group
    FROM flagged
)
SELECT
    sales_month,
    current_month_revenue,
    mom_growth_pct,
    is_decline,
    CASE WHEN is_decline = 1
         THEN COUNT(CASE WHEN is_decline = 1 THEN 1 END) OVER (PARTITION BY streak_group ORDER BY sales_month)
         ELSE 0
    END AS consecutive_decline_months
FROM grouped
ORDER BY sales_month;
