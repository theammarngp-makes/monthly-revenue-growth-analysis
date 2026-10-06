<div align="center">

<img src="assets/banner.png" alt="Monthly Revenue Growth & Performance Intelligence" width="100%">

# 📈 Monthly Revenue Growth & Performance Intelligence

### A governed SQL + Python + Tableau pipeline that turns a monthly revenue extract into executive-ready growth intelligence

<p>
  <a href="#-executive-summary"><img src="https://img.shields.io/badge/Executive-Summary-blue?style=for-the-badge&logo=markdown" alt="Executive Summary"></a>
  <a href="#-dashboard"><img src="https://img.shields.io/badge/Tableau-Dashboard_Spec-orange?style=for-the-badge&logo=tableau" alt="Dashboard"></a>
  <a href="#-sql-engineering"><img src="https://img.shields.io/badge/SQL-23_Files-green?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL"></a>
  <a href="#-python-validation-layer"><img src="https://img.shields.io/badge/Python-5_Notebooks-yellow?style=for-the-badge&logo=python&logoColor=white" alt="Python"></a>
  <a href="#-reports--presentation"><img src="https://img.shields.io/badge/Reports-PDF_%2B_PPTX-purple?style=for-the-badge&logo=readthedocs&logoColor=white" alt="Reports"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge" alt="MIT License"></a>
</p>

*23 months of revenue · Oct-2016 → Aug-2018 · MoM + YoY + running revenue · gaps-and-islands decline detection · SQL ↔ Python reconciled*

</div>

---

## 📑 Table of Contents

1. [Executive Summary](#-executive-summary)
2. [Business Problem](#-business-problem)
3. [Scope & Data Gap (Read This First)](#-scope--data-gap-read-this-first)
4. [KPI Framework](#-kpi-framework)
5. [Architecture](#-architecture)
6. [Dashboard](#-dashboard)
7. [Key Insights](#-key-insights)
8. [SQL Engineering](#-sql-engineering)
9. [Python Validation Layer](#-python-validation-layer)
10. [Data Quality](#-data-quality)
11. [Business Recommendations](#-business-recommendations)
12. [Reports & Presentation](#-reports--presentation)
13. [Documentation](#-documentation)
14. [Repository Structure](#-repository-structure)
15. [How to Run](#-how-to-run)
16. [Methodology](#-methodology)
17. [Limitations](#-limitations)
18. [Skills Demonstrated](#-skills-demonstrated)
19. [Enterprise BI Portfolio](#-enterprise-bi-portfolio)
20. [Author & License](#-author--license)

---

## 📌 Executive Summary

Most teams can *pull* a monthly revenue number. Far fewer can answer, on demand and without a spreadsheet scramble: **is growth accelerating, flat, or deteriorating, and was that last bad month a blip or the start of a slide?**

This engagement builds the layer that answers it. A raw 23-row monthly extract is validated, cleaned, and passed through a **window-function SQL metric layer** (MoM, YoY, running revenue, decline streaks). An **independent Python reimplementation** reconciles every metric, and the results feed an executive dashboard design and a tiered reporting suite.

**What the data says:**

| Question | Answer |
|---|---|
| Is revenue in sustained decline? | **No.** The longest consecutive-decline streak in all 23 months is **1 month**. |
| What is the latest month doing? | Aug-2018 posted **−4.00% MoM**, following a positive July. A dip, not a trend. |
| Is recent performance deteriorating? | **Flat.** Last 3 months vs. prior 3 months: **−1.59%**, within normal volatility. |
| Was the Nov-2017 spike a new baseline? | **No.** It was a one-off; Dec-2017 recorded the series' worst MoM (**−24.05%**). |

📄 Full narrative: [`analysis/executive_summary.md`](analysis/executive_summary.md) · 📕 Executive report: [`reports/executive_report.pdf`](reports/executive_report.pdf)

---

## 🧩 Business Problem

The business held monthly revenue figures but **no centralized, reliable layer** for tracking growth, spotting momentum changes, or supporting management decisions on demand. This project builds that layer and answers, directly from the data:

- 💰 How much revenue is generated each month, and how is it trending?
- 📊 How is revenue changing month over month, and year over year where the data allows?
- 🔍 Which months saw significant growth or decline, and was a decline a single bad month or a genuine multi-month slide?
- ➕ What is cumulative revenue over the observed period?
- 🧭 Is the most recent performance improving, flat, or deteriorating?
- 🎯 Where should management look closer?

> **Value proposition:** replace ad-hoc "what's our MoM growth?" pulls with one reproducible pipeline, from raw CSV to dashboard-ready metrics, where every number traces back to a single documented definition.

---

## ⚠️ Scope & Data Gap (Read This First)

The source extract (`data/raw/monthly_revenue_raw.csv`) contains **exactly two columns**: `sales_month` and `current_month_revenue`. It has **23 rows** at monthly grain, **Oct-2016 through Aug-2018**. There is no order ID, line item, or customer-level data anywhere in the source.

| Metric | Status | Why |
|---|---|---|
| Monthly revenue, MoM %, YoY %, running revenue | ✅ In scope, built at full depth | Computable from the real data |
| Consecutive-decline detection, acceleration, best/worst, recent performance | ✅ In scope | Computable from the real data |
| Order Count, Order Growth %, Average Order Value | ❌ Out of scope | Cannot be computed without inventing an order count |

Rather than fabricate an order count, the gap is documented in [`docs/assumptions.md`](docs/assumptions.md), and every doc and query that would have touched those metrics says so directly. **Closing this gap is the single highest-leverage next step** (see [Recommendations](#-business-recommendations)).

---

## 🎯 KPI Framework

| KPI | Definition | Source |
|---|---|---|
| **Current Month Revenue** | Raw monthly revenue, as provided | [`sql/03_analysis/01_monthly_revenue.sql`](sql/03_analysis/01_monthly_revenue.sql) |
| **MoM Growth %** | `(current − previous) / previous × 100`; NULL for month 1; zero-division guarded | [`sql/03_analysis/02_mom_growth.sql`](sql/03_analysis/02_mom_growth.sql) |
| **YoY Growth %** | `(current − 12mo_prior) / 12mo_prior × 100`; valid from month 13 onward | [`sql/03_analysis/03_yoy_growth.sql`](sql/03_analysis/03_yoy_growth.sql) |
| **Running Revenue** | `SUM() OVER` cumulative window | [`sql/03_analysis/04_running_revenue.sql`](sql/03_analysis/04_running_revenue.sql) |
| **Consecutive Decline Streak** | Gaps-and-islands count of unbroken MoM-negative months | [`sql/04_business_cases/01_revenue_decline_detection.sql`](sql/04_business_cases/01_revenue_decline_detection.sql) |

Edge cases and caveats for every KPI: [`docs/metric_definitions.md`](docs/metric_definitions.md)

---

## 🏗️ Architecture

<div align="center">
  <img src="assets/architecture.png" alt="Pipeline architecture" width="90%">
</div>

```text
data/raw/monthly_revenue_raw.csv
   │
   ├─▶ sql/00_schema            table definition
   ├─▶ sql/01_data_quality      null · duplicate · date · revenue checks
   ├─▶ sql/02_cleaning          type normalization → vw_clean_monthly_revenue
   ├─▶ sql/03_analysis          MoM · YoY · running revenue · growth diagnostics
   ├─▶ sql/04_business_cases    decline detection · acceleration · best/worst · recent performance
   │
   ├─▶ python/                  independent reimplementation · EDA · reconciliation
   ├─▶ data/processed/monthly_revenue_processed.csv    single hand-off file
   ├─▶ dashboard/tableau/       Revenue Intelligence dashboard (manual build)
   └─▶ reports/executive_report.md
```

| Layer | Role |
|---|---|
| **SQL** | Source-of-truth metric engine |
| **Python** | Independent reconciliation and EDA layer |
| **Tableau** | Executive presentation layer |
| **Docs / Reports** | Governance, narrative, and audience-tiered communication |

Full explanation and reproduction steps: [`docs/architecture.md`](docs/architecture.md)

---

## 🖥️ Dashboard

<div align="center">
  <img src="assets/dashboard-preview.png" alt="Revenue Intelligence dashboard preview" width="95%">
</div>

<br>

<div align="center">
  <img src="assets/revenue-trend.png" alt="Monthly revenue trend and MoM growth" width="95%">
</div>

> **Transparency note:** these are **static previews rendered from the processed data with matplotlib. They are not Tableau exports.** The interactive Tableau workbook is a manual build, specified field by field in [`dashboard/tableau/README.md`](dashboard/tableau/README.md). Why this matters is documented in [`docs/assumptions.md`](docs/assumptions.md).

📘 Dashboard guide: [`dashboard/README.md`](dashboard/README.md) · 🛠️ Tableau build spec: [`dashboard/tableau/README.md`](dashboard/tableau/README.md) · 🖼️ Preview: [`dashboard/dashboard-preview.png`](dashboard/dashboard-preview.png)

---

## 💡 Key Insights

<div align="center">
  <img src="assets/insights-preview.png" alt="Key insights" width="95%">
</div>

<br>

1. **Early-period MoM growth (+144.19%, +140.95% in the first two months) is real but not representative.** It reflects a near-zero starting base, not a repeatable growth rate.
2. **Revenue shows a ramp-then-plateau shape.** Steep growth through a Nov-2017 spike (**1,027,013**), then a stable band of roughly **860,000 to 1,061,000** through Aug-2018.
3. **The Nov-2017 spike was a one-off followed by reversion**, not a new baseline. Dec-2017 posted the series' worst MoM growth (**−24.05%**).
4. **No sustained decline exists anywhere in the data.** The longest consecutive-decline streak across all 23 months is **1 month**, including the most recent month on record (Aug-2018, **−4.00%**, following a positive July).
5. **Recent performance is flat, not deteriorating.** Last 3 months vs. prior 3 months: **−1.59%**.

📄 Evidence and recommended actions: [`analysis/key_insights.md`](analysis/key_insights.md) · 📕 PDF: [`analysis/key_insights.pdf`](analysis/key_insights.pdf)

---

## 🗄️ SQL Engineering

**23 SQL files** across five layers. Every query carries a purpose comment and, where non-obvious, the reasoning behind a design choice (for example, why month 1 MoM growth is `NULL` rather than `0`).

| Layer | Folder | Purpose |
|---|---|---|
| 0 | `sql/00_schema/` | Table definition |
| 1 | `sql/01_data_quality/` | Null, duplicate, date-gap, and revenue-validity checks |
| 2 | `sql/02_cleaning/` | Type normalization into `vw_clean_monthly_revenue` |
| 3 | `sql/03_analysis/` | MoM, YoY, running revenue, growth diagnostics |
| 4 | `sql/04_business_cases/` | Decline detection, acceleration, best/worst months, recent performance |

**Techniques:** CTEs · `LAG()` · `SUM() OVER` · gaps-and-islands streak detection · `RANK()` · zero-division guards · ANSI / PostgreSQL-compatible syntax

---

## 🐍 Python Validation Layer

Five notebooks, each following the same structure: **Purpose → Imports → Data Loading → Analysis → Findings → Conclusion.**

| Notebook | Role |
|---|---|
| [`01_data_loading.ipynb`](python/01_data_loading.ipynb) | Load the raw extract |
| [`02_data_validation.ipynb`](python/02_data_validation.ipynb) | Independent data-quality checks |
| [`03_revenue_eda.ipynb`](python/03_revenue_eda.ipynb) | Exploratory analysis |
| [`04_growth_analysis.ipynb`](python/04_growth_analysis.ipynb) | Independent reimplementation of every SQL metric |
| [`05_export_dashboard_data.ipynb`](python/05_export_dashboard_data.ipynb) | Writes `data/processed/monthly_revenue_processed.csv` |

The Python layer **independently reimplements every SQL metric** and was reconciled against it during development. See [`analysis/methodology.md`](analysis/methodology.md).

---

## ✅ Data Quality

| Check | Result |
|---|---|
| Null values | None |
| Duplicate months | None |
| Date gaps | None |
| Negative or zero revenue | None |
| Statistical outliers beyond 3σ | None |

Check-by-check detail: [`docs/data_quality.md`](docs/data_quality.md)

---

## 🧭 Business Recommendations

Five recommendations, each tied to a specific finding rather than generic advice.

- **Report growth with a rolling-average + streak view**, not a single-month MoM figure.
- **Set a 2+ month decline threshold for management review.** It has never yet been triggered in this data.
- **Close the order-level data gap.** This is the highest-leverage next step and unlocks the volume-vs-value diagnostic the business originally asked for.

Full set with rationale: [`analysis/business_recommendations.md`](analysis/business_recommendations.md)

---

## 📄 Reports & Presentation

| Deliverable | Audience | Formats |
|---|---|---|
| **Executive Summary** | C-suite | [`analysis/executive_summary.md`](analysis/executive_summary.md) |
| **Key Insights** | Leadership and analysts | [MD](analysis/key_insights.md) · [PDF](analysis/key_insights.pdf) |
| **Executive Report** | Executive leadership | [MD](reports/executive_report.md) · [PDF](reports/executive_report.pdf) |
| **Presentation** | Stakeholder walkthroughs | [MD](reports/presentation.md) · [PDF](reports/presentation.pdf) · [PPTX](reports/presentation.pptx) |

---

## 📚 Documentation

<details>
<summary><b>Click to expand the documentation inventory</b></summary>

<br>

| Document | Focus |
|---|---|
| [`docs/data_dictionary.md`](docs/data_dictionary.md) | Field-level schema for source and output data |
| [`docs/metric_definitions.md`](docs/metric_definitions.md) | Every KPI, defined once, with edge cases |
| [`docs/assumptions.md`](docs/assumptions.md) | Documented assumptions and the order-level data gap |
| [`docs/data_quality.md`](docs/data_quality.md) | Check-by-check data quality results |
| [`docs/architecture.md`](docs/architecture.md) | Pipeline design and reproduction steps |
| [`analysis/methodology.md`](analysis/methodology.md) | Validation and SQL ↔ Python reconciliation approach |
| [`data/README.md`](data/README.md) | Data folder guide |
| [`assets/README.md`](assets/README.md) | Asset inventory |

</details>

---

## 🗂️ Repository Structure

```text
monthly-revenue-growth-analysis/
├── README.md
├── LICENSE
├── requirements.txt
├── assets/                       banner · dashboard-preview · insights-preview · revenue-trend · architecture
├── data/
│   ├── raw/monthly_revenue_raw.csv
│   └── processed/monthly_revenue_processed.csv
├── sql/
│   ├── 00_schema/
│   ├── 01_data_quality/
│   ├── 02_cleaning/
│   ├── 03_analysis/
│   └── 04_business_cases/
├── python/                       5 notebooks (01 → 05)
├── dashboard/
│   ├── README.md
│   ├── dashboard-preview.png
│   └── tableau/README.md
├── analysis/                     executive_summary · key_insights (md + pdf) · business_recommendations · methodology
├── docs/                         data_dictionary · metric_definitions · assumptions · data_quality · architecture
└── reports/                      executive_report (md + pdf) · presentation (md + pdf + pptx)
```

---

## 🚀 How to Run

```bash
# 1. Clone
git clone https://github.com/theammarngp-makes/monthly-revenue-growth-analysis.git
cd monthly-revenue-growth-analysis

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the Python pipeline in order (01 → 05)
jupyter notebook python/01_data_loading.ipynb
# 05_export_dashboard_data.ipynb writes data/processed/monthly_revenue_processed.csv

# 4. (Optional) Run the SQL layer on a PostgreSQL-compatible database, in order:
#    sql/00_schema → 01_data_quality → 02_cleaning → 03_analysis → 04_business_cases

# 5. Build the Tableau dashboard from dashboard/tableau/README.md,
#    connected to data/processed/monthly_revenue_processed.csv
```

---

## 🔬 Methodology

> **Validate before calculating. Define every metric once. Reconcile SQL and Python independently. Document gaps instead of filling them. Never claim causality the data doesn't support.**

Full write-up: [`analysis/methodology.md`](analysis/methodology.md)

---

## 🚧 Limitations

- **No order-level data.** Order Count, Order Growth %, and AOV are out of scope.
- **No causal data** (marketing spend, promotions, seasonality flags). Findings describe *what* happened, never *why*, unless independently confirmed.
- **Only 11 of 23 months** have a valid YoY comparison.
- **No second-source reconciliation** against a ledger or payment processor.
- **Currency is unspecified** in the source data.

Full detail: [`reports/executive_report.md`](reports/executive_report.md), Section 11.

---

## 🛠️ Skills Demonstrated

| Category | Skills |
|---|---|
| **SQL** | CTEs, window functions (`LAG`, `SUM() OVER`, `RANK`), gaps-and-islands, layered pipeline design |
| **Python** | pandas, numpy, matplotlib, SQL ↔ Python metric reconciliation |
| **BI** | KPI governance, dashboard specification, Tableau design |
| **Data Quality** | Validation-first workflow, outlier testing, explicit gap documentation |
| **Communication** | Audience-tiered reporting: Summary → Report → Presentation, executive PDFs and PPTX |
| **Analytical Rigor** | Refusing to fabricate metrics, separating description from causation |

---

## 🌐 Enterprise BI Portfolio

This repository is **Project 4** of a four-project Business Intelligence suite built on the same descriptive-to-diagnostic arc:

- 📈 **[Project 1 — Revenue & Sales Performance Analysis](https://github.com/theammarngp-makes/olist-sales-analysis)** · what happened
- 🎯 **[Project 2 — E-Commerce RFM Customer Segmentation](https://github.com/theammarngp-makes/ecommerce-rfm-customer-segmentation)** · who matters and why
- 🔄 **[Project 3 — Customer Cohort Retention Analysis](https://github.com/theammarngp-makes/E-commerce-cohort-retention-analysis)** · how long customers stay
- 📊 **Project 4 — Monthly Revenue Growth Analysis (this repository)** · where the business is heading

---

## 👤 Author & License

**Mohammad Ammar** · Apex-Analyticx
GitHub: [@theammarngp-makes](https://github.com/theammarngp-makes) · X: [@theammarngp](https://x.com/theammarngp)

Licensed under the **MIT License**. See [`LICENSE`](LICENSE).

<div align="center">

⭐ *If this project helped you, consider starring the repo.*

</div>
