# Metric Definitions

Every metric in this project is defined here exactly once. The SQL, Python,
and dashboard layers all implement these same definitions — if a number
looks different in two places, one of them has a bug, not a "different way
of counting."

## Current Month Revenue
Raw monthly revenue as provided in the source extract. No transformation
applied beyond type casting and rounding to 2 decimal places.

## Month-over-Month (MoM) Growth %
```
mom_growth_pct = (current_month_revenue - previous_month_revenue)
                  / previous_month_revenue * 100
```
- The **first month in the series has no `mom_growth_pct` value** — it is
  `NULL`, not `0`. A `0%` would falsely imply "no change from last month"
  when there is no last month to compare against.
- Division-by-zero is guarded with `NULLIF` in SQL / safe division in
  Python, in case a future data refresh introduces a zero-revenue month.

**Early-period ramp caveat:** the first 2-3 months of this dataset
(Oct-Dec 2016) sit on a very small revenue base (43,000 → 105,000 →
253,000). MoM growth in this window is mathematically correct
(+144.19%, +140.95%) but **not representative of a steady-state growth
rate** — it reflects a near-zero starting point, not a repeatable growth
pattern. Any headline "average MoM growth %" across the full series will
be pulled upward by these two months. Report the trend from month 4
onward separately when a steady-state read is needed.

## Year-over-Year (YoY) Growth %
```
yoy_growth_pct = (current_month_revenue - revenue_12_months_prior)
                  / revenue_12_months_prior * 100
```
- Only valid from the 13th month of the series onward. With 23 months of
  data (Oct-2016 - Aug-2018), that means **only 11 months (Oct-2017 -
  Aug-2018) have a YoY figure** — the first 12 months are `NULL` by design.
- The earliest available YoY comparisons (Oct-Dec 2017) are still being
  measured against the low-base ramp period one year prior, so those
  specific YoY percentages (e.g. +1,376.74% in Oct-2017) are real
  arithmetic but reflect the low prior-year base, not a repeatable rate.

## Running Revenue (Cumulative Revenue)
```
running_revenue = SUM(current_month_revenue) OVER (
    ORDER BY sales_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```
Total revenue recognized from the start of the observed period through
the current month, inclusive.

## Rolling 3-Month Average / Std Dev
Trailing 3-month simple moving average and population standard deviation
of `current_month_revenue`, used to separate trend from month-to-month
noise. First valid value is the 3rd month in the series.

## Revenue Acceleration
```
revenue_acceleration = this_month_mom_growth_pct - previous_month_mom_growth_pct
```
Measures whether the *rate* of growth is speeding up or slowing down —
distinct from whether revenue itself is growing. A month can have positive
`mom_growth_pct` and negative `revenue_acceleration` at the same time
(growing, but more slowly than the month before).

## Consecutive Decline Months (Streak)
Count of unbroken consecutive months with `mom_growth_pct < 0`, reset to 0
the moment a month has non-negative growth. Used to distinguish an
isolated bad month from a genuine downward trend (see
`sql/04_business_cases/01_revenue_decline_detection.sql`).

## Metrics explicitly OUT OF SCOPE for this project

| Metric | Status |
|---|---|
| Monthly order count | Not computable — no order-level data in the source. |
| Order Growth % | Depends on order count. Not computable. |
| Average Order Value (AOV) | Depends on order count. Not computable. |
| Revenue-driver split (volume vs. AOV) | Depends on order count. Not computable. |

These were part of this project's original planned scope. They are
documented here as **explicit gaps**, not silently dropped — see
`assumptions.md` for the reasoning and what would be required to add them
back in a future iteration.
