# Data Quality Report

Checks performed against `data/raw/monthly_revenue_raw.csv` (23 rows), run
independently in both SQL (`sql/01_data_quality/`) and Python
(`python/02_data_validation.ipynb`), with matching results in both layers.

## Summary

| Check | Method | Result |
|---|---|---|
| Null values | `IS NULL` / `.isnull().sum()` | **0** nulls in either column |
| Duplicate months | `GROUP BY ... HAVING COUNT(*) > 1` / `.duplicated()` | **0** duplicate `sales_month` values |
| Date parseability | Cast to `DATE` / `pd.to_datetime(..., errors='coerce')` | **0** unparseable dates |
| Month-sequence gaps | Generated calendar vs. actual months | **0** missing months — continuous Oct-2016 → Aug-2018 |
| Negative or zero revenue | `WHERE current_month_revenue <= 0` | **0** rows |
| Statistical outliers (>3σ from mean) | Z-score | **0** rows flagged |

**Conclusion: this dataset has no detected data quality defects.** No rows
were dropped, no values were imputed, and no cleaning-by-deletion occurred
anywhere in this pipeline — the cleaning step in `sql/02_cleaning/` is a
type-normalization pass only (see `assumptions.md`, section 2).

## What was NOT checked (and why)

- **Referential integrity** (e.g., foreign keys to a customer or product
  table) — not applicable, because no related tables exist in the source
  data. See `data_dictionary.md` for the full list of tables/columns that
  do not exist in this project.
- **Cross-source reconciliation** (e.g., matching this revenue figure
  against a general ledger or payment processor export) — no second data
  source was provided to reconcile against. This is listed as a limitation
  in `reports/executive_report.md`.

## Coverage limitation (distinct from a quality defect)

The data is clean, but **23 months is a limited window**:
- Only 11 of the 23 months have a valid Year-over-Year comparison (see
  `docs/metric_definitions.md`).
- The first 2-3 months are a near-zero-revenue ramp period that produces
  extreme (but mathematically correct) MoM growth percentages — these are
  called out explicitly wherever MoM growth is reported, rather than
  silently averaged in with the rest of the series.

## Data quarantine pattern (not currently needed)

`sql/02_cleaning/01_clean_monthly_revenue.sql` includes a commented-out
quarantine-table pattern for future data refreshes, in case a later export
does introduce null, negative, or duplicate rows. It is not active because
it is not needed on the current dataset — it exists so that a future
defect is quarantined for manual review rather than silently dropped.
