# Executive Report — Monthly Revenue Growth & Performance Intelligence

**Period:** October 2016 - August 2018 (23 months)
**Prepared from:** `data/processed/monthly_revenue_processed.csv`

---

## 1. Executive Summary

Revenue grew from 43,000 (Oct-2016) to a period peak of 1,061,000
(May-2018), a total of 15,737,501 recognized across the full period. The
business shows a launch-growth phase through late 2017 followed by a
stable plateau in 2018. There is no evidence of a sustained multi-month
decline anywhere in the series, including in the most recent month on
record.

## 2. Business Context

The originating business problem: revenue data existed but there was no
centralized, reliable monthly performance layer to answer basic growth
questions on demand (see project brief). This report and its supporting
SQL/Python/dashboard pipeline directly answer the business questions that
the available data supports.

## 3. Performance Overview

| Metric | Value |
|---|---|
| Total revenue (full period) | 15,737,501 |
| Number of months | 23 |
| Highest revenue month | May-2018 (1,061,000) |
| Lowest revenue month | Oct-2016 (43,000, first month) |
| Best MoM growth | Nov-2016, +144.19% (low-base effect — see Limitations) |
| Worst MoM growth | Dec-2017, -24.05% (post-spike reversion) |

## 4. Revenue Growth

Revenue rose steeply from Oct-2016 through a peak of 1,027,013 in
Nov-2017, then plateaued in a ~860,000-1,061,000 band through Aug-2018.
The 3-month rolling average confirms this: it climbs continuously through
2017 and then flattens from roughly Apr-2018 onward.

## 5. MoM Performance

Full month-by-month MoM growth is in
`data/processed/monthly_revenue_processed.csv`. Two periods deserve
separate framing rather than being averaged into a single "typical MoM
growth" figure:

- **Oct-Dec 2016**: extreme MoM % (+144.19%, +140.95%) reflecting a
  small starting base, not a repeatable rate.
- **Nov-Dec 2017**: a sharp spike (+61.73%) immediately followed by the
  steepest decline in the series (-24.05%) — consistent with a spike
  followed by reversion rather than a structural shift (the data cannot
  identify what prompted the spike).

Outside these two windows, MoM growth ranges from -15.33% to +54.15%.
Most months fall within ±20%; the exceptions are Jan-2017 (+54.15%),
Mar-2017 (+47.79%), and Jan-2018 (+22.05%).

## 6. Order & AOV Dynamics

**Not available.** The source data provided for this engagement contains
only monthly revenue totals — no order count, order ID, or customer data
exists anywhere in the provided files. Order volume, order growth %, and
Average Order Value could not be computed and are not included in this
report. See Limitations (Section 11) and `docs/assumptions.md` for the
full explanation.

## 7. Recent Performance

The last 3 months on record (Jun-Aug 2018) averaged 1,022,829/month vs.
1,039,333/month for the prior 3 months (Mar-May 2018) — a **-1.59%**
change. The change is small relative to the month-to-month swings in
the series (rolling 3-month std dev ranged 14,295-126,640 across 2018) and
does not, on its own, indicate a trend reversal.

## 8. Key Signals

- No consecutive multi-month revenue decline exists anywhere in the
  23-month series (longest streak: 1 month).
- The Aug-2018 dip (-4.00%) follows a positive July (+0.53%) and is best
  read as an isolated month, not the start of a decline.
- Only 11 of 23 months support a Year-over-Year comparison; treat
  early YoY figures (Oct-Dec 2017) with caution, as they are measured
  against a low prior-year base.

## 9. Business Recommendations

See `analysis/business_recommendations.md` for the full list, tied
explicitly to the findings above. Highlights:
1. Report growth with a rolling average + decline-streak view, not a
   single MoM % in isolation.
2. Investigate the Nov-2017 spike to determine if it is repeatable.
3. Set `consecutive_decline_months >= 2` as the management-review trigger.
4. Close the order-level data gap — this is the single highest-value next
   step, since it unlocks the volume-vs-value diagnostic the business
   originally asked for.
5. Reconcile total revenue against a second source (ledger/payment
   processor) before using this pipeline for finance-facing reporting.

## 10. Methodology

See `analysis/methodology.md` for the full approach: validate before
calculating, define every metric once, reconcile SQL against Python
independently, and document gaps rather than filling them.

## 11. Limitations

- **No order-level data.** Order count, order growth %, and AOV are out of
  scope for this engagement — the source data does not support them (see
  `docs/assumptions.md`).
- **No causal data.** There is no marketing spend, promotional calendar,
  seasonality flag, or external event data. All findings describe *what*
  happened to revenue, never *why*, unless independently confirmed
  (nothing was, in this engagement).
- **Limited YoY coverage.** Only 11 of 23 months have a valid
  Year-over-Year figure.
- **Unreconciled against a second source.** Revenue totals have not been
  checked against a general ledger or payment processor export.
- **Currency unspecified** in the source data.
