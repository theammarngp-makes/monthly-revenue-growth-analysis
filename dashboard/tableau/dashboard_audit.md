# Dashboard Audit Checklist

Based on the earlier screenshot of the existing workbook
("Monthly growth analysis"). Items marked VERIFY are things visible in the
screenshot that I could not confirm without the .twbx file.

| # | Issue seen | Fix |
|---|---|---|
| 1 | Title reads "Monthly growth analysis" | Rename to **Revenue Intelligence** with a one-line subtitle (period covered) |
| 2 | Chart title typo: "Gorwth Percentage" | Correct to "MoM Growth %" |
| 3 | Growth chart y-axis shows 0K-600K next to a running-total line on a 0M-15M axis | Growth % is on the wrong scale. Plot `mom_growth_decimal` as % bars alone; move running revenue to its own small chart or drop it |
| 4 | Growth KPI shows "-4" | Show "-4.0%" (percentage format) |
| 5 | KPI labels truncated ("Running") and abbreviated ("Current rev") | Full labels: Total Revenue, Latest Month Revenue, Latest MoM Growth |
| 6 | Unlabeled dual axes ("Total Rev" left and right, "Previous Month") | Remove duplicate axes; one axis per chart with a clear title |
| 7 | VERIFY: bar and line peaks look near 1.1-1.2M, but the processed data peaks at 1,061,000 (May-2018) and Nov-2017 is 1,027,013 | Confirm the workbook's data source and aggregation match `tableau_extract.csv`; a mismatch means a different source or a bad aggregation |
| 8 | VERIFY: trend line appears to start at 2016-12 and dips to ~0K | Check date filter and null handling; the series should start Oct-2016 at 43,000 |
| 9 | Half the canvas is empty at the bottom | Use a fixed 1200x800 layout; KPI row, two charts, one diagnostic row |
| 10 | No takeaways on the dashboard | Add one annotation: "Aug-2018 -4.0% follows +0.5% in Jul: 1-month dip, not a trend" |

Acceptance test: every number on the dashboard equals the same month in
`tableau_extract.csv`. Spot-check Oct-2016 (43,000), Nov-2017 (1,027,013),
May-2018 (1,061,000), Aug-2018 (996,974, -4.00%), total 15,737,501.
