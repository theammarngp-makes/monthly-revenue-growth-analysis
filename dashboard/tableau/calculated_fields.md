# Tableau Calculated Fields

Connect to `data/processed/tableau_extract.csv` (same numbers as
`monthly_revenue_processed.csv`, plus pre-built helper columns).
Do the maths in the extract, not in Tableau, so the dashboard cannot
drift from the SQL/Python definitions.

## Format rules (fixes common errors)
- **MoM %**: use `mom_growth_decimal` and format as Percentage, 1 decimal.
  Do NOT use `mom_growth_pct` with a K/M number format; that is how a
  growth chart ends up on a 0K-600K axis.
- **Aggregation**: every measure must be `SUM` on a single row per month
  (one row = one month), never a running SUM across the whole view unless
  the field is `running_revenue` (use `MAX`/`ATTR`, not `SUM`).
- **Nulls**: leave the first month's MoM as Null. Do not fill with 0.

## KPI cards (filter each to `is_latest_month = TRUE` except Total)
| Card | Field |
|---|---|
| Total Revenue | `SUM([current_month_revenue])`, format `#,##0` |
| Latest Month Revenue | `SUM([current_month_revenue])` where latest |
| Latest MoM Growth | `AVG([mom_growth_decimal])` where latest, format `+0.0%;-0.0%`, red if < 0 |
| Decline Streak | `MAX([consecutive_decline_months])` where latest |

## Charts
- **Trend**: line of `current_month_revenue` + dashed `rolling_3m_avg`, same axis.
- **MoM bars**: `mom_growth_decimal`, color by `growth_direction` (Growth blue/green, Decline red). Exclude `is_ramp_period` via a "Hide ramp months" parameter, or annotate the first two bars.
- **Diagnostic**: revenue vs `rolling_3m_avg`, color by `vs_rolling_trend`.
- **Recent performance**: `AVG(current_month_revenue)` by `period_bucket`, filter out `Earlier`.

## Interactivity (keep it small)
- Date range filter on `sales_month`.
- Parameter: "Include ramp months (first 3)" Yes/No.
- Tooltips: month, revenue, MoM %, streak. No orders or AOV anywhere.
