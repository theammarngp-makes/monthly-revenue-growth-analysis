# Key Insights

Each insight follows: **Finding → Evidence → Business Meaning → Recommended
Investigation/Action.** All figures are pulled directly from
`data/processed/monthly_revenue_processed.csv` — none are estimated.

---

### 1. Early-period growth percentages are real but not representative

**Finding:** The two largest MoM growth percentages in the entire series
occur in the first two months of data.

**Evidence:** Nov-2016 +144.19% (43,000 → 105,000); Dec-2016 +140.95%
(105,000 → 253,000).

**Business Meaning:** These are mathematically correct, but they reflect
a near-zero starting base, not a repeatable growth rate. If reported
without context (e.g., in a single "average MoM growth" headline number),
they would materially overstate the business's typical growth rate.

**Recommended Action:** Exclude or footnote the first 2-3 months whenever
reporting an average/typical MoM growth rate. Use median MoM growth, or a
"from month 4 onward" filter, alongside the full series.

---

### 2. Revenue shows a clear ramp-then-plateau shape, not sustained compounding

**Finding:** Revenue climbs from 43,000 to a period peak of 1,061,000
(May-2018), but the growth rate visibly slows after the Nov-2017 spike.

**Evidence:** 3-month rolling average moves from 133,667 (Dec-2016) to
640,667-674,000 (mid-to-late 2017), and settles in a 972,667-1,045,333
band from Apr-2018 through Aug-2018 (`data/processed/monthly_revenue_processed.csv`,
`rolling_3m_avg` column).

**Business Meaning:** The business has moved from a launch-growth phase
into a maturity phase relative to its current base. This is a normal
pattern for a young business, not necessarily a warning sign on its own.

**Recommended Action:** Investigate what specifically changed after
Nov-2017 (a new marketing channel, category expansion, referral program,
etc.) using data outside this dataset's scope — order-level, marketing
spend, or channel data would be needed to say more.

---

### 3. Nov-2017 shows a sharp spike followed by reversion — not a new baseline

**Finding:** Nov-2017 revenue (1,027,013) is well above the surrounding
months (Oct-2017: 635,000; Dec-2017: 780,000), and Dec-2017 shows the
worst MoM growth in the series (-24.05%). Note: this is *not* a
statistical outlier by the z-score test used in `docs/data_quality.md`
(z = 1.11, within the ±3 threshold applied there) — it is a visually
and proportionally large swing relative to neighboring months, which is
a weaker claim and is described as such.

**Evidence:** `mom_growth_pct` for Nov-2017 = +61.73%, for Dec-2017 =
-24.05% — the single largest month-over-month swing pair in the dataset
outside the initial ramp.

**Business Meaning:** A single unusually strong month followed by a sharp
pullback is consistent with a temporary spike rather than a permanent
step-change in the business's run rate. This dataset cannot say what
drove the spike, or whether a similar one could recur — it has no
calendar, promotional, or order-level data. Jan-2018 (952,000) is
consistent with this reading: it settles well below the Nov-2017 peak
but above the pre-spike baseline.

**Recommended Action:** Identify what happened in Nov-2017 specifically
(this dataset alone cannot say) and evaluate whether it is a repeatable,
plannable event (e.g., an annual seasonal calendar) or a non-repeatable
one-off.

---

### 4. There is no evidence of a sustained decline — the most recent dip is isolated

**Finding:** The longest run of consecutive MoM-negative months anywhere
in the 23-month series is **1**. The most recent month, Aug-2018
(-4.00%), is immediately preceded by a positive July (+0.53%).

**Evidence:** `consecutive_decline_months` column, computed via a
gaps-and-islands streak calculation in both SQL
(`sql/04_business_cases/01_revenue_decline_detection.sql`) and Python
(`python/04_growth_analysis.ipynb`) — every value in the series is 0 or 1,
never 2+.

**Business Meaning:** A single down month should not, on its own, trigger
an "the business is declining" narrative. This directly corrects an
earlier unverified claim (from this project's original README draft)
describing the ending months as a "2-month consecutive decline" — that
claim does not hold up against the actual data and has been dropped from
this version.

**Recommended Action:** Use the streak length (not a single month's
figure) as the trigger for a management review — e.g., flag when
`consecutive_decline_months >= 2`, which has not yet occurred in this
dataset.

---

### 5. Recent performance (last 3 vs. prior 3 months) is flat, not deteriorating

**Finding:** Jun-Aug 2018 averaged 1,022,829/month vs. 1,039,333/month
for Mar-May 2018 — a -1.59% change.

**Evidence:** `sql/04_business_cases/04_recent_performance.sql` and
`python/04_growth_analysis.ipynb`.

**Business Meaning:** A -1.59% change over a 3-month window, sitting
within a revenue band the business has occupied since Apr-2018, reads as
normal month-to-month noise around a stable plateau, not a trend reversal.

**Recommended Action:** Continue monitoring on a rolling 3-vs-3-month
basis rather than reacting to any single month; revisit if the delta
exceeds roughly the historical volatility band (`rolling_3m_std`, which
has ranged 14,295-23,116 in this same recent window).
