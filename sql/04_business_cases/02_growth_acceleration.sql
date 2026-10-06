-- =====================================================================
-- File:     02_growth_acceleration.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Measure whether growth is accelerating or decelerating --
--           the change in the MoM growth rate itself, not just the
--           MoM growth rate in isolation.
--
-- Definition: revenue_acceleration = this month's mom_growth_pct
--             minus last month's mom_growth_pct. A positive value
--             means growth is speeding up; negative means the growth
--             rate is slowing (even if revenue is still growing).
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
)
SELECT
    sales_month,
    current_month_revenue,
    mom_growth_pct,
    ROUND(mom_growth_pct - LAG(mom_growth_pct) OVER (ORDER BY sales_month), 2) AS revenue_acceleration
FROM mom
ORDER BY sales_month;
