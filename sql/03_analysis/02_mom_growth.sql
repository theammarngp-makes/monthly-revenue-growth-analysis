-- =====================================================================
-- File:     02_mom_growth.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Month-over-Month revenue and MoM growth %, using LAG().
--
-- Definition: mom_growth_pct = (current - previous) / previous * 100
-- The first month in the series has no prior month, so its
-- mom_growth_pct is intentionally NULL -- NOT 0. Treating the first
-- month as "0% growth" would misrepresent it as a flat month rather
-- than a period with no valid comparison base.
-- Division-by-zero is guarded with NULLIF, in case a future refresh
-- ever introduces a zero-revenue month.
-- =====================================================================

SELECT
    sales_month,
    current_month_revenue,
    LAG(current_month_revenue) OVER (ORDER BY sales_month) AS previous_month_revenue,
    ROUND(
        (current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY sales_month)) * 100.0
        / NULLIF(LAG(current_month_revenue) OVER (ORDER BY sales_month), 0),
        2
    ) AS mom_growth_pct
FROM vw_clean_monthly_revenue
ORDER BY sales_month;
