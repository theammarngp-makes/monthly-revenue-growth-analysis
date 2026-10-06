-- =====================================================================
-- File:     05_growth_diagnostics.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Classify each month's growth behavior and detect
--           consecutive-direction streaks, using only revenue data
--           (order-volume/AOV decomposition is out of scope -- see
--           docs/orders_and_aov_scope_note.md).
--
-- ROLLING AVERAGE DEFINITION ALIGNMENT:
-- Requires a full 3-month observation window (min_periods = 3).
-- The first two months (Oct-2016, Nov-2016) have fewer than 3 months of
-- prior history, so rolling_3m_avg is intentionally NULL and
-- vs_rolling_trend is classified as 'no_trend_yet'. This matches the
-- Python EDA layer and Tableau extract definitions exactly.
-- =====================================================================

WITH numbered AS (
    SELECT
        sales_month,
        current_month_revenue,
        ROW_NUMBER() OVER (ORDER BY sales_month) AS row_num,
        ROUND(
            (current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY sales_month)) * 100.0
            / NULLIF(LAG(current_month_revenue) OVER (ORDER BY sales_month), 0),
            2
        ) AS mom_growth_pct,
        ROUND(AVG(current_month_revenue) OVER (
            ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) AS calc_rolling_3m
    FROM vw_clean_monthly_revenue
),
growth AS (
    SELECT
        sales_month,
        current_month_revenue,
        row_num,
        mom_growth_pct,
        CASE WHEN row_num >= 3 THEN calc_rolling_3m ELSE NULL END AS rolling_3m_avg
    FROM numbered
),
classified AS (
    SELECT
        *,
        CASE
            WHEN mom_growth_pct IS NULL THEN 'no_prior_month'
            WHEN mom_growth_pct > 0    THEN 'increase'
            WHEN mom_growth_pct < 0    THEN 'decrease'
            ELSE 'flat'
        END AS direction,
        CASE
            WHEN rolling_3m_avg IS NULL THEN 'no_trend_yet'
            WHEN current_month_revenue > rolling_3m_avg THEN 'above_trend'
            WHEN current_month_revenue < rolling_3m_avg THEN 'below_trend'
            ELSE 'on_trend'
        END AS vs_rolling_trend
    FROM growth
)
SELECT
    sales_month,
    current_month_revenue,
    mom_growth_pct,
    direction,
    rolling_3m_avg,
    vs_rolling_trend
FROM classified
ORDER BY sales_month;
