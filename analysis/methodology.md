# Methodology

## Approach

1. **Inspect before designing.** The repository architecture and SQL
   schema were written to match the actual shape of the data
   (`data/raw/monthly_revenue_raw.csv`, 2 columns, monthly grain) rather
   than an assumed schema. This is why the project scope was revised
   part-way through (see `docs/assumptions.md`) once the real data shape
   was confirmed.
2. **Validate before calculating.** Data quality checks
   (`sql/01_data_quality/`, `python/02_data_validation.ipynb`) ran before
   any growth metric was computed, and the results are documented in
   `docs/data_quality.md` regardless of outcome (in this case: clean data).
3. **Define every metric once.** All formulas live in
   `docs/metric_definitions.md` and are implemented identically in SQL and
   Python, so the two layers can be cross-checked against each other.
4. **Reconcile independently.** SQL (source of truth) and Python
   (independent reimplementation) were both run against the same source
   CSV and compared row-for-row during development; they match exactly.
   A SQLite cross-check of the core LAG/window-function logic against the
   real dataset was also used to validate SQL syntax and results before
   finalizing the queries.
5. **Distinguish findings from causes.** Every insight in
   `analysis/key_insights.md` is stated as "the data shows X," never "X
   was caused by Y," unless a specific external explanation was
   confirmed (none were, in this engagement — see `docs/assumptions.md`).
6. **Document gaps instead of filling them.** Where the original scope
   could not be met with the available data (order counts, AOV), that gap
   is documented explicitly in three places (`docs/assumptions.md`,
   `docs/metric_definitions.md`, `reports/executive_report.md`) rather
   than filled with an estimate.

## Tools

- **SQL** (MySQL 8.0+ / MySQL 8.4 — single authoritative dialect, no
  PostgreSQL-only constructs) for the canonical metric definitions and
  window-function logic.
- **Python** (pandas, numpy, matplotlib) for independent validation, EDA,
  and the final dashboard-ready export.
- **Tableau** for the executive dashboard. The workbook
  (`dashboard/tableau/revenue_intelligence.twbx`) was generated
  programmatically from the spec in `dashboard/tableau/README.md` rather
  than saved from Tableau Desktop, so it must be opened and verified
  against `dashboard/tableau/dashboard_audit.md` before use.
