# Assumptions & Scope Boundaries

This document exists so that anyone reviewing this project (a hiring
manager, a teammate, future-me) can see exactly where the analysis is
grounded in data versus where a scope decision was made, and why.

## 1. Scope was reduced from the original brief — and why

This engagement was originally scoped to cover order volume, order growth,
and Average Order Value (AOV) alongside revenue. After inspecting the
actual source data, that scope was **deliberately narrowed to revenue-only
analysis**, because:

- The only source file available is `data/raw/monthly_revenue_raw.csv`,
  which contains exactly two columns: `sales_month` and
  `current_month_revenue`.
- There is no order ID, line-item, or customer-level table anywhere in the
  provided data — meaning **order counts cannot be derived, and AOV
  (revenue ÷ orders) cannot be calculated without an order count.**
- Backfilling an assumed order count (e.g., "assume $85 average order
  size") would mean presenting a fabricated number as if it were measured
  data. That is a worse outcome for a client — or for a portfolio reviewer
  — than clearly saying "this metric is out of scope without more data."

**What this means concretely:**
- The dashboard KPI cards for Orders and AOV described in the original
  brief were **not built**, rather than built with invented numbers.
- The "Revenue Change → Order Volume Change → AOV Change" diagnostic tree
  was replaced with a revenue-only diagnostic (direction, magnitude,
  streak, vs. rolling trend) — see
  `sql/03_analysis/05_growth_diagnostics.sql`.
- If order-level data becomes available, the intended location for this
  work is documented in
  `docs/orders_and_aov_scope_note.md`.

## 2. The dataset is already pre-aggregated

The source CSV is monthly-grain, not transaction-grain. This project's SQL
layer therefore does not include a "raw transactions → cleaned
transactions" step in the traditional sense — there are no transaction
rows to clean. The cleaning step in `sql/02_cleaning/` is a type/format
normalization pass (date casting, rounding), not a row-filtering pass,
because the data quality checks in `sql/01_data_quality/` found nothing to
filter (see `data_quality.md`).

## 3. Currency is unspecified in the source

The source data does not label a currency (USD, EUR, etc.). This project
does not assume a currency and reports figures as unitless numeric revenue
throughout. If a currency is confirmed, it should be added to
`data_dictionary.md` and the dashboard KPI card formatting.

## 4. No causal claims

Per this project's own requirement, findings describe *what happened* in
the revenue series, not *why*. Statements like "revenue growth coincided
with X" are used instead of "X caused revenue growth," because this
dataset has no marketing spend, seasonality flags, promotional calendar,
or external event data that would be needed to support a causal claim.

## 5. Reproducibility assumption

All SQL in `sql/` is written against a single table, `monthly_revenue`
(see `sql/00_schema/01_create_tables.sql`), assumed to be loaded from
`data/raw/monthly_revenue_raw.csv`. The Python notebooks in `python/` are
an independent reimplementation of the same logic against the same CSV,
used to cross-validate the SQL rather than to replace it — the numbers in
both layers were checked against each other during development and match
exactly.

## 6. Remaining work before this is finance/portfolio-ready

- `dashboard/tableau/revenue_intelligence.twbx` — generated programmatically from the spec in `dashboard/tableau/README.md`, reading `data/processed/tableau_extract.csv`. It has not been opened in Tableau Desktop by its generator, so open it, run the checks in `dashboard/tableau/dashboard_audit.md`, fix anything that looks wrong, and re-save it from Tableau.
- `assets/dashboard-preview.png` and `dashboard/dashboard-preview.png` —
  currently a static matplotlib rendering of the intended design, not a
  Tableau screenshot. Replace both once the workbook exists.
