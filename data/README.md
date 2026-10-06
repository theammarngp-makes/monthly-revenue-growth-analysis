# Data

## `raw/monthly_revenue_raw.csv`

The original source extract, unmodified. 23 rows, 2 columns
(`sales_month`, `current_month_revenue`), monthly grain, Oct-2016 through
Aug-2018. See `docs/data_dictionary.md` for the full column spec and
`docs/data_quality.md` for validation results (clean — no defects found).

## `processed/monthly_revenue_processed.csv`

Generated output — **not hand-edited**. Produced by
`python/05_export_dashboard_data.ipynb` (or the equivalent SQL in
`sql/03_analysis/` + `sql/04_business_cases/`). Contains the raw columns
plus every derived metric defined in `docs/metric_definitions.md`
(MoM growth, running revenue, YoY growth, rolling average/std, revenue
acceleration, consecutive decline streak).

`processed/tableau_extract.csv` is the same table plus helper columns for
Tableau (`mom_growth_decimal`, `growth_direction`, `vs_rolling_trend`,
`period_bucket`, `latest_flag`), also written by
`python/05_export_dashboard_data.ipynb`.

This is the single file the Tableau dashboard and the written reports are
built from. If the source data changes, regenerate this file — do not
edit it directly.

**Not included:** `orders`, `order_growth_pct`, `aov` columns. See
`docs/assumptions.md` for why.
