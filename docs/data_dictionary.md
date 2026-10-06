# Data Dictionary

## Source table: `monthly_revenue`

| Column | Type | Description | Notes |
|---|---|---|---|
| `sales_month` | DATE | First day of the calendar month the revenue was recognized in. | Primary key. Range: 2016-10-01 to 2018-08-01 (23 months, continuous, no gaps). |
| `current_month_revenue` | NUMERIC(14,2) | Total revenue recognized in that month. | No nulls, no zero/negative values observed. Range: 43,000 - 1,061,000 (raw units, currency unspecified in source). |

**Grain:** one row per calendar month. This is the finest grain available in
the provided data — there is no order-level, line-item, or customer-level
table underneath it.

## Derived columns (produced by `sql/03_analysis/` and `python/`)

| Column | Definition | First valid value |
|---|---|---|
| `previous_month_revenue` | `LAG(current_month_revenue)` | Month 2 (Nov-2016) |
| `mom_growth_pct` | `(current - previous) / previous * 100` | Month 2 (Nov-2016) |
| `running_revenue` | `SUM(current_month_revenue)` over all months up to and including the current row | Month 1 (Oct-2016) |
| `revenue_12mo_ago` / `yoy_growth_pct` | `LAG(current_month_revenue, 12)` and the resulting % change | Month 13 (Oct-2017) |
| `rolling_3m_avg` / `rolling_3m_std` | 3-month trailing rolling mean / population std dev | Month 3 (Dec-2016) |
| `revenue_acceleration` | `mom_growth_pct - previous mom_growth_pct` | Month 3 (Dec-2016) |
| `consecutive_decline_months` | Count of unbroken consecutive months with `mom_growth_pct < 0` | Month 2 (Nov-2016), value 0 unless in a decline streak |

## Columns that do NOT exist in this project (explicit gap)

| Column | Why it's absent |
|---|---|
| `order_id` / any order-level key | Not present in the source extract at any grain. |
| `orders` (monthly order count) | Cannot be derived — no order-level rows to count. |
| `order_growth_pct` | Depends on `orders`, which does not exist. |
| `aov` (Average Order Value) | Depends on `orders`, which does not exist. |
| `customer_id` | Not present. |

See `assumptions.md` for the full explanation and `docs/orders_and_aov_scope_note.md` for where this would live if order-level data becomes available.
