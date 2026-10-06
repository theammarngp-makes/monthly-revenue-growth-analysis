-- =====================================================================
-- File:     01_create_tables.sql
-- Purpose:  Defines the source table for this project.
-- Dialect:  MySQL 8.0+ / MySQL 8.4 (single authoritative baseline for
--           this project). CHECK constraints are parsed on all 8.0
--           versions but only ENFORCED from MySQL 8.0.16 onward.
-- =====================================================================
--
-- SCHEMA NOTE (read this before anything else):
-- The source data supplied for this engagement is already aggregated
-- to monthly grain. There is no order-level, transaction-level, or
-- customer-level table available (no order IDs, no line items, no
-- customer IDs). This project therefore models exactly one table:
-- a monthly revenue fact table.
--
-- This is a deliberate, documented constraint, not an oversight.
-- See docs/assumptions.md and docs/data_quality.md for the full
-- explanation of why order-count and AOV metrics are OUT OF SCOPE
-- for this engagement.
-- =====================================================================

CREATE TABLE IF NOT EXISTS monthly_revenue (
    sales_month             DATE            NOT NULL
        COMMENT 'First day of the calendar month, e.g. 2016-10-01',
    current_month_revenue   DECIMAL(14, 2)  NOT NULL
        COMMENT 'Total revenue recognized in that month',
    PRIMARY KEY (sales_month),
    CONSTRAINT chk_revenue_non_negative CHECK (current_month_revenue >= 0)
) ENGINE=InnoDB
  COMMENT='Monthly-grain revenue fact table. One row per calendar month. Source: client-provided extract, already pre-aggregated upstream. No order-level detail is available.';
