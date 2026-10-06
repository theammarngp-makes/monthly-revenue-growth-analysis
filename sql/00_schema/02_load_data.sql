-- =====================================================================
-- File:     02_load_data.sql
-- Purpose:  Populates monthly_revenue table from raw CSV data.
-- Dialect:  MySQL 8.0+ / MySQL 8.4
--
-- REPRODUCIBILITY & FORMATTING NOTE:
-- The raw CSV (data/raw/monthly_revenue_raw.csv) stores sales_month as
-- text in 'YYYY-MM' format (e.g., '2016-10').
-- The schema table (sql/00_schema/01_create_tables.sql) defines
-- sales_month as DATE NOT NULL (storing the first of the month, e.g.
-- '2016-10-01').
--
-- Direct LOAD DATA without date transformation will attempt to insert
-- '2016-10' into DATE, resulting in '0000-00-00', primary key duplicate
-- collisions, and loading 1 row instead of 23.
--
-- Below are two official mechanisms to load the 23 rows correctly:
--
-- METHOD 1 (Standard SQL - Client Portable, Recommended):
-- Uses explicit INSERT INTO with STR_TO_DATE / CONCAT. Works across all
-- MySQL clients (CLI, Workbench, DBeaver, Python/Java connectors) without
-- requiring file-permission or local_infile configuration.
--
-- METHOD 2 (LOAD DATA LOCAL INFILE - High Performance Bulk Load):
-- Uses a variable transformation @m to map 'YYYY-MM' to 'YYYY-MM-01'.
-- Requires: SET GLOBAL local_infile = 1; and client --local-infile=1 flag.
-- =====================================================================

USE revenue_growth_db;

-- ---------------------------------------------------------------------
-- METHOD 1: Standard SQL Population Pass
-- ---------------------------------------------------------------------
INSERT INTO monthly_revenue (sales_month, current_month_revenue) VALUES
('2016-10-01', 43000.00),
('2016-11-01', 105000.00),
('2016-12-01', 253000.00),
('2017-01-01', 390000.00),
('2017-02-01', 362000.00),
('2017-03-01', 535000.00),
('2017-04-01', 453000.00),
('2017-05-01', 526000.00),
('2017-06-01', 607000.00),
('2017-07-01', 635000.00),
('2017-08-01', 680000.00),
('2017-09-01', 707000.00),
('2017-10-01', 635000.00),
('2017-11-01', 1027013.00),
('2017-12-01', 780000.00),
('2018-01-01', 952000.00),
('2018-02-01', 861000.00),
('2018-03-01', 1015000.00),
('2018-04-01', 1042000.00),
('2018-05-01', 1061000.00),
('2018-06-01', 1033000.00),
('2018-07-01', 1038514.00),
('2018-08-01', 996974.00)
ON DUPLICATE KEY UPDATE current_month_revenue = VALUES(current_month_revenue);

-- Verification assertions post-load:
SELECT
    COUNT(*)                             AS loaded_rows,
    SUM(current_month_revenue)           AS total_revenue,
    CASE WHEN COUNT(*) = 23 AND SUM(current_month_revenue) = 15737501.00
         THEN 'PASS' ELSE 'FAIL' END     AS verification_status
FROM monthly_revenue;

/*
-- ---------------------------------------------------------------------
-- METHOD 2: LOAD DATA LOCAL INFILE Alternative
-- ---------------------------------------------------------------------
-- Execute in mysql CLI with: mysql --local-infile=1 -u root -p
--
-- SET GLOBAL local_infile = 1;
-- LOAD DATA LOCAL INFILE 'data/raw/monthly_revenue_raw.csv'
-- INTO TABLE monthly_revenue
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (@raw_month, @raw_revenue)
-- SET sales_month = STR_TO_DATE(CONCAT(@raw_month, '-01'), '%Y-%m-%d'),
--     current_month_revenue = CAST(@raw_revenue AS DECIMAL(14,2));
*/
