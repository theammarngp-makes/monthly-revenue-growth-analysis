# Orders & AOV — Scope Note

This project's original scope called for:
  - Monthly order counts
  - Order growth %
  - Average Order Value (AOV)
  - A revenue-diagnostic split into "driven by order volume" vs.
    "driven by AOV"
These cannot be computed. The source dataset provided for this
engagement (data/raw/monthly_revenue_raw.csv) contains exactly two
columns: sales_month and current_month_revenue. There is no order
count, order ID, line-item, or customer-level field anywhere in the
data supplied.
Rather than invent an order count or back into one with an assumed
average order size (which would be a fabricated number presented as
real), this gap is left explicit here and documented in:
  - docs/assumptions.md
  - docs/data_quality.md
  - reports/executive_report.md (Limitations section)
If order-level data becomes available in a future engagement, this
file is the intended location for:
    SELECT sales_month, COUNT(DISTINCT order_id) AS orders, ...
    LAG(orders) OVER (...) AS previous_month_orders, ...
    current_month_revenue / NULLIF(orders, 0) AS aov
