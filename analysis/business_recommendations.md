# Business Recommendations

Each recommendation is tied directly to a finding in `key_insights.md` —
none are generic "grow revenue" advice.

## 1. Replace single-month growth headlines with a rolling-average + streak view

**Tied to:** Insight #1 (early-ramp distortion) and Insight #4 (streak vs.
single-month decline).

Report MoM growth alongside the 3-month rolling average and the current
consecutive-decline-month count, rather than a single MoM % in isolation.
This prevents both false alarms (one bad month read as a trend) and false
comfort (one good month masking an underlying multi-month slide) — neither
of which is currently a concern in this dataset, but the reporting habit
should be built before it is.

## 2. Investigate the Nov-2017 spike to determine whether it is repeatable

**Tied to:** Insight #3.

If Nov-2017 corresponds to a known seasonal event (holiday shopping,
end-of-year procurement, etc.), evaluate whether it can be deliberately
planned for and amplified next time. This requires data outside this
project's scope (order-level or campaign data) to confirm what drove it —
this analysis can only confirm *that* it happened, not *why*.

## 3. Set a data-driven decline-alert threshold instead of reacting to any single red month

**Tied to:** Insight #4.

Adopt `consecutive_decline_months >= 2` (from
`sql/04_business_cases/01_revenue_decline_detection.sql`) as the trigger
for a management review, rather than any single negative MoM month. On
the current data, this threshold has never been crossed — which is itself
useful context for how the most recent Aug-2018 dip should be read.

## 4. Close the order-level data gap to unlock the originally-scoped diagnostics

**Tied to:** the AOV/order-volume gap documented in `docs/assumptions.md`.

The most consequential recommendation is not about revenue behavior — it
is about instrumentation. Order-level data (order ID, order date, order
value, ideally customer ID) is needed to answer the business's own
question of whether revenue changes are "driven by order volume or order
value." Without it, this project can describe *what* revenue did but not
*why* in terms of volume vs. value — which was one of the original
business questions this engagement set out to answer.

## 5. Reconcile this revenue figure against a second source before using it for finance reporting

**Tied to:** `docs/data_quality.md` ("what was not checked").

This data passed every internal quality check available, but it has not
been reconciled against a general ledger, payment processor export, or
accounting system total. Before this pipeline feeds an executive or
investor-facing report, confirm the totals tie out to at least one
independent source.
