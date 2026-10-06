-- =====================================================================
-- File:     01_clean_monthly_revenue.sql
-- Dialect:  MySQL 8.0+ / MySQL 8.4
-- Purpose:  Produce a validated, analysis-ready view of monthly_revenue.
--
-- Cleaning rules applied (and why):
--   1. Cast sales_month to DATE (first of month) for correct ordering
--      and window-function behavior -- the raw column may arrive as
--      text (e.g. "2016-10") depending on export format.
--   2. Round revenue to 2 decimal places for consistent currency
--      formatting downstream.
--   3. NOTHING IS DROPPED. Data quality checks in 01_data_quality/
--      found zero nulls, zero duplicates, zero gaps, and zero invalid
--      values on this dataset -- so this cleaning step is a
--      normalization pass, not a filtering pass. If a future data
--      refresh introduces bad rows, they should be routed to a
--      quarantine table for manual review rather than silently
--      dropped -- see the commented-out pattern below.
-- =====================================================================

CREATE OR REPLACE VIEW vw_clean_monthly_revenue AS
SELECT
    CAST(sales_month AS DATE)                           AS sales_month,
    ROUND(CAST(current_month_revenue AS DECIMAL(14, 2)), 2) AS current_month_revenue
FROM monthly_revenue
ORDER BY sales_month;

-- Optional quarantine pattern (not needed for the current dataset,
-- included for reproducibility if the source data changes):
--
-- CREATE TABLE IF NOT EXISTS monthly_revenue_quarantine (
--     sales_month             VARCHAR(20),
--     current_month_revenue   VARCHAR(30),
--     rejection_reason        VARCHAR(100)
-- );
--
-- INSERT INTO monthly_revenue_quarantine
-- SELECT CAST(sales_month AS CHAR), CAST(current_month_revenue AS CHAR), 'null_or_negative_revenue'
-- FROM monthly_revenue
-- WHERE current_month_revenue IS NULL OR current_month_revenue < 0;
