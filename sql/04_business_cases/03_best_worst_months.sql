-- =====================================================================
-- File:     03_best_worst_months.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Identify the highest/lowest revenue months and the
--           highest/lowest MoM growth months, ranked with RANK()
--           rather than a hardcoded TOP-N filter.
--
-- NULL ordering note: MySQL has no NULLS LAST modifier. The first
-- month's mom_growth_pct is NULL (no prior month to compare against --
-- see sql/03_analysis/02_mom_growth.sql) and must not be mistaken for
-- the best or worst growth month. Ordering by the expression
-- (mom_growth_pct IS NULL) first -- which evaluates to 0 for non-NULL
-- rows and 1 for the NULL row -- places the NULL row last regardless
-- of ASC or DESC direction on the second sort key, which is the
-- portable equivalent of PostgreSQL's "DESC NULLS LAST" / "ASC NULLS
-- LAST".
--
-- Note: the very first month (Oct-2016) is deliberately excluded from
-- the growth ranking by the same mechanism.
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
ranked AS (
    SELECT
        *,
        RANK() OVER (ORDER BY current_month_revenue DESC)                       AS revenue_rank_desc,
        RANK() OVER (ORDER BY current_month_revenue ASC)                        AS revenue_rank_asc,
        RANK() OVER (ORDER BY (mom_growth_pct IS NULL), mom_growth_pct DESC)     AS growth_rank_desc,
        RANK() OVER (ORDER BY (mom_growth_pct IS NULL), mom_growth_pct ASC)      AS growth_rank_asc
    FROM mom
)
SELECT sales_month, current_month_revenue, mom_growth_pct,
       revenue_rank_desc, revenue_rank_asc, growth_rank_desc, growth_rank_asc
FROM ranked
WHERE revenue_rank_desc = 1   -- highest revenue month
   OR revenue_rank_asc = 1    -- lowest revenue month
   OR growth_rank_desc = 1    -- best MoM growth month
   OR growth_rank_asc = 1     -- worst MoM growth month
ORDER BY sales_month;
