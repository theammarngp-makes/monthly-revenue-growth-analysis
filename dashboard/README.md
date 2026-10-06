# Dashboard

**Title:** Revenue Intelligence
**Data source:** `data/processed/monthly_revenue_processed.csv`
**Tool:** Tableau. Workbook: `dashboard/tableau/revenue_intelligence.twbx` (script-generated, to be verified and re-saved in Tableau Desktop; see `dashboard/tableau/README.md` for the spec and QA steps).

## Layout

| Zone | Content |
|---|---|
| KPI cards (top row) | Total Revenue, Latest MoM Growth %, Latest Revenue |
| Main visual | Monthly Revenue Trend (line, with 3-month rolling average overlay) |
| Secondary visual | MoM Growth % (bar, colored by sign) |
| Diagnostic | Revenue vs. Rolling 3-Month Average (highlights above/below-trend months) |
| Recent performance | Last 3 months vs. previous 3 months (bar comparison) |

**Note on scope:** the original brief's KPI cards for Orders and AOV, and
the "Revenue vs Orders vs AOV" diagnostic panel, are **not included** —
the source data has no order-level information to support them. See
`docs/assumptions.md`.

## Design principles

- Minimal, executive-friendly — 4 zones, no more.
- Every number on the dashboard traces to a named column in
  `data/processed/monthly_revenue_processed.csv` — nothing on the
  dashboard is calculated ad hoc inside Tableau that isn't already
  defined in `docs/metric_definitions.md`.
- Color is used only for sign (growth vs. decline), not decoration.

`dashboard-preview.png` in this folder is a **static preview** rendered with
matplotlib from the processed data, showing the intended design. It is not
a Tableau export; replace it with a real screenshot once the workbook is
built (see `docs/assumptions.md` §6).
