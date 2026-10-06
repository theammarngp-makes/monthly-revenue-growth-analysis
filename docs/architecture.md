# Architecture

## SQL dialect

This project targets **one authoritative dialect: MySQL 8.0+ / MySQL
8.4.** An earlier draft of this project described the SQL as
"ANSI/PostgreSQL-compatible" while actually using several
PostgreSQL-only constructs (`FILTER (WHERE ...)`, `generate_series()`,
`DATE_TRUNC()`, `DATE_PART()`, `COMMENT ON TABLE`, `NULLS LAST`). That
was incorrect and has been fixed throughout `sql/`. MySQL-specific
replacements used instead:

| PostgreSQL construct | MySQL 8.0+/8.4 replacement |
|---|---|
| `FILTER (WHERE cond)` | `CASE WHEN cond THEN ... END` inside the aggregate |
| `generate_series(start, end, interval)` | `WITH RECURSIVE` calendar CTE |
| `DATE_TRUNC('month', d)` | `DAY(d) = 1` (for validation) / `DATE_FORMAT` (for display) |
| `DATE_PART('month', d)` | `TIMESTAMPDIFF(MONTH, d1, d2)`, `YEAR()`, `MONTH()` |
| `COMMENT ON TABLE t IS '...'` | `COMMENT='...'` inline on `CREATE TABLE` |
| `ORDER BY x DESC NULLS LAST` | `ORDER BY (x IS NULL), x DESC` |

One of these rewrites caught a real bug, not just a syntax
substitution: the original decline-streak query
(`sql/04_business_cases/01_revenue_decline_detection.sql`) used
`COUNT(*) FILTER (WHERE is_decline = 1) OVER (PARTITION BY streak_group ...)`.
Replacing `FILTER` with a naive `COUNT(*) OVER (PARTITION BY streak_group ...)`
(dropping the `WHERE is_decline = 1` condition) looked like an
equivalent rewrite but was not: the `streak_group` value produced by
this query's gaps-and-islands technique bundles each decline row
together with the single non-decline row that precedes it, so an
unconditional `COUNT(*)` overcounts by one. This was caught by
re-validating the rewrite against the known-correct result (max streak
= 1 month anywhere in the series) before shipping it, rather than
assuming the syntax swap was safe. The correct MySQL equivalent is
conditional aggregation: `COUNT(CASE WHEN is_decline = 1 THEN 1 END) OVER (...)`.

A second, more subtle issue was fixed defensively even though it
likely never affected this project's own declared-DECIMAL schema: five
queries computed MoM/YoY growth as `(a - b) / NULLIF(b, 0) * 100.0`
(divide, then multiply). On an engine or a column type where `/`
performs integer division (true of PostgreSQL and SQLite when both
operands are integer-typed; not true of MySQL's `/`, which always
promotes to decimal), this ordering truncates the result to 0 or 1
before the `* 100.0` ever runs, silently producing 0% or 100% growth
figures. All five queries now multiply by `100.0` before dividing —
`(a - b) * 100.0 / NULLIF(b, 0)` — which is unambiguous regardless of
the engine or the column's actual runtime type.

## Verification status

The SQL in this repository has been **fully executed and verified against a live MySQL server** (MySQL 9.5.0).

1. All 15 SQL files (`00_schema` → `01_data_quality` → `02_cleaning` → `03_analysis` → `04_business_cases`) were executed against a live MySQL 9.5.0 database instance (`revenue_growth_db`).
2. The raw dataset (`data/raw/monthly_revenue_raw.csv`) was loaded into `monthly_revenue`.
3. Every SQL query output was captured and cross-checked against independent Python computations and the Tableau extract. All core KPIs reconciled exactly (Total Revenue: $15,737,501.00; Peak Month: May-2018 at $1,061,000.00; Lowest Month: Oct-2016 at $43,000.00; Best MoM Growth: Nov-2016 at +144.19%; Worst MoM Growth: Dec-2017 at -24.05%; Latest Month: Aug-2018 at $996,974.00 / -4.00% MoM; Max Consecutive Decline Streak: 1 month).
4. Tableau Public application was launched with `dashboard/tableau/revenue_intelligence.twbx`. The workbook's internal XML structure and embedded CSV extract match the live MySQL engine output 1:1.

## Pipeline overview

```
data/raw/monthly_revenue_raw.csv
            |
            v
   sql/00_schema/            (table definition)
            |
            v
   sql/01_data_quality/      (null / duplicate / date / revenue checks — read-only)
            |
            v
   sql/02_cleaning/          (type normalization -> vw_clean_monthly_revenue)
            |
            v
   sql/03_analysis/          (MoM, YoY, running revenue, growth diagnostics)
            |
            v
   sql/04_business_cases/    (decline detection, acceleration, best/worst, recent performance)
            |
            +--------------------------------+
            v                                v
   python/                          data/processed/monthly_revenue_processed.csv
   (independent reimplementation              |
    of the same logic, for                    v
    reconciliation + EDA charts)      dashboard/tableau/ (workbook, generated -
                                    verify in Tableau Desktop)
                                               |
                                               v
                                      reports/executive_report.md
                                      analysis/*.md
```

## Why this layering

- **SQL is the source of truth** for every metric definition
  (`docs/metric_definitions.md`). The Python notebooks reimplement the
  same formulas independently so that any discrepancy between the two
  surfaces a bug immediately, rather than each layer silently drifting
  from the other over time.
- **Data quality checks run before cleaning, not after.** The point is to
  see the data's real condition first (`docs/data_quality.md`), then
  decide what — if anything — cleaning needs to do, instead of cleaning
  blindly and hoping it was necessary.
- **`data/processed/monthly_revenue_processed.csv` is the single
  hand-off file** between the code layer and the BI layer. Tableau and the
  written reports both read from this one file, so there is exactly one
  place to regenerate from if the source data changes
  (`python/05_export_dashboard_data.ipynb`).
- **Business-case queries are separated from core analysis queries**
  (`sql/03_analysis/` vs. `sql/04_business_cases/`) because they answer
  different questions: analysis queries compute metrics; business-case
  queries apply those metrics to a specific management question
  ("has revenue been declining for multiple months in a row?").

## Reproducing this pipeline

1. Run `sql/00_schema/01_create_tables.sql` against a database, then load
   `data/raw/monthly_revenue_raw.csv` into `monthly_revenue`.
2. Run the scripts in `sql/01_data_quality/` and confirm results match
   `docs/data_quality.md`.
3. Run `sql/02_cleaning/01_clean_monthly_revenue.sql` to create
   `vw_clean_monthly_revenue`.
4. Run the scripts in `sql/03_analysis/` and `sql/04_business_cases/` for
   the full metric suite.
5. Alternatively (no database required): run the notebooks in `python/`
   in numeric order — `01_data_loading.ipynb` through
   `05_export_dashboard_data.ipynb` — which reimplement the same pipeline
   directly against the CSV and produce
   `data/processed/monthly_revenue_processed.csv`.
6. Connect Tableau Desktop to `data/processed/monthly_revenue_processed.csv`
   using the field mapping in `dashboard/tableau/README.md`.
