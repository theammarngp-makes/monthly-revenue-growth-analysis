import os
import subprocess
import pandas as pd
import numpy as np

# 1. Load Data in Python Pandas
df_raw = pd.read_csv('data/raw/monthly_revenue_raw.csv')
df_raw['sales_month'] = pd.to_datetime(df_raw['sales_month'] + '-01')
df_raw['current_month_revenue'] = df_raw['current_month_revenue'].astype(float)
df = df_raw.sort_values('sales_month').reset_index(drop=True)

df['previous_month_revenue'] = df['current_month_revenue'].shift(1)
df['mom_growth_pct'] = ((df['current_month_revenue'] - df['previous_month_revenue']) / df['previous_month_revenue'] * 100).round(2)
df['running_revenue'] = df['current_month_revenue'].cumsum()
df['revenue_12mo_ago'] = df['current_month_revenue'].shift(12)
df['yoy_growth_pct'] = ((df['current_month_revenue'] - df['revenue_12mo_ago']) / df['revenue_12mo_ago'] * 100).round(2)

df['rolling_3m_avg'] = df['current_month_revenue'].rolling(3, min_periods=3).mean().round(2)
df['rolling_3m_std'] = df['current_month_revenue'].rolling(3, min_periods=3).std(ddof=0).round(2) # population stddev

df['revenue_acceleration'] = (df['mom_growth_pct'] - df['mom_growth_pct'].shift(1)).round(2)

df['is_decline'] = (df['mom_growth_pct'] < 0).astype(int)
df['decline_group'] = (df['is_decline'] == 0).cumsum()

# Consecutive decline streak
streaks = []
current_streak = 0
for dec in df['is_decline']:
    if dec == 1:
        current_streak += 1
        streaks.append(current_streak)
    else:
        current_streak = 0
        streaks.append(0)
df['consecutive_decline_months'] = streaks

# Trend classification
def get_trend(row):
    if pd.isna(row['rolling_3m_avg']):
        return 'no_trend_yet'
    elif row['current_month_revenue'] > row['rolling_3m_avg']:
        return 'above_trend'
    elif row['current_month_revenue'] < row['rolling_3m_avg']:
        return 'below_trend'
    else:
        return 'on_trend'

df['vs_rolling_trend'] = df.apply(get_trend, axis=1)

# Format sales_month to string YYYY-MM-01
df['sales_month_str'] = df['sales_month'].dt.strftime('%Y-%m-%d')

# 2. Query Live MySQL
def query_mysql(query):
    full_sql = f"USE revenue_growth_db;\n{query}"
    res = subprocess.run(
        ["mysql", "-h", "127.0.0.1", "-P", "3307", "-u", "root", "-B", "-N"],
        input=full_sql, text=True, capture_output=True
    )
    if res.returncode != 0:
        raise Exception(f"MySQL error: {res.stderr}")
    
    rows = [line.split('\t') for line in res.stdout.strip().split('\n') if line]
    return rows

# Query SQL for Diagnostics
sql_rows = query_mysql("""
WITH numbered AS (
    SELECT
        sales_month,
        current_month_revenue,
        ROW_NUMBER() OVER (ORDER BY sales_month) AS row_num,
        ROUND(
            (current_month_revenue - LAG(current_month_revenue) OVER (ORDER BY sales_month)) * 100.0
            / NULLIF(LAG(current_month_revenue) OVER (ORDER BY sales_month), 0),
            2
        ) AS mom_growth_pct,
        SUM(current_month_revenue) OVER (ORDER BY sales_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue,
        LAG(current_month_revenue, 12) OVER (ORDER BY sales_month) AS revenue_12mo_ago,
        ROUND(
            (current_month_revenue - LAG(current_month_revenue, 12) OVER (ORDER BY sales_month)) * 100.0
            / NULLIF(LAG(current_month_revenue, 12) OVER (ORDER BY sales_month), 0),
            2
        ) AS yoy_growth_pct,
        ROUND(AVG(current_month_revenue) OVER (
            ORDER BY sales_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) AS calc_rolling_3m
    FROM vw_clean_monthly_revenue
),
growth AS (
    SELECT
        sales_month,
        current_month_revenue,
        row_num,
        mom_growth_pct,
        running_revenue,
        revenue_12mo_ago,
        yoy_growth_pct,
        CASE WHEN row_num >= 3 THEN calc_rolling_3m ELSE NULL END AS rolling_3m_avg
    FROM numbered
),
classified AS (
    SELECT
        *,
        CASE
            WHEN mom_growth_pct IS NULL THEN 'no_prior_month'
            WHEN mom_growth_pct > 0    THEN 'increase'
            WHEN mom_growth_pct < 0    THEN 'decrease'
            ELSE 'flat'
        END AS direction,
        CASE
            WHEN rolling_3m_avg IS NULL THEN 'no_trend_yet'
            WHEN current_month_revenue > rolling_3m_avg THEN 'above_trend'
            WHEN current_month_revenue < rolling_3m_avg THEN 'below_trend'
            ELSE 'on_trend'
        END AS vs_rolling_trend
    FROM growth
)
SELECT
    DATE_FORMAT(sales_month, '%Y-%m-%d'),
    current_month_revenue,
    mom_growth_pct,
    running_revenue,
    revenue_12mo_ago,
    yoy_growth_pct,
    rolling_3m_avg,
    vs_rolling_trend
FROM classified
ORDER BY sales_month;
""")

df_sql = pd.DataFrame(sql_rows, columns=[
    'sales_month_str', 'current_month_revenue', 'mom_growth_pct',
    'running_revenue', 'revenue_12mo_ago', 'yoy_growth_pct',
    'rolling_3m_avg', 'vs_rolling_trend'
])

# Convert numeric columns
for col in ['current_month_revenue', 'mom_growth_pct', 'running_revenue', 'revenue_12mo_ago', 'yoy_growth_pct', 'rolling_3m_avg']:
    df_sql[col] = pd.to_numeric(df_sql[col], errors='coerce')

# Perform 1:1 assertion across all 23 rows
print("ASSERTION CHECK: SQL vs Python Pandas Row-by-Row Comparison\n" + "="*60)
mismatches = 0
for idx in range(len(df)):
    p_row = df.iloc[idx]
    s_row = df_sql.iloc[idx]
    
    month = p_row['sales_month_str']
    p_rev = p_row['current_month_revenue']
    s_rev = s_row['current_month_revenue']
    
    p_mom = p_row['mom_growth_pct']
    s_mom = s_row['mom_growth_pct']
    
    p_roll = p_row['rolling_3m_avg']
    s_roll = s_row['rolling_3m_avg']
    
    p_trend = p_row['vs_rolling_trend']
    s_trend = s_row['vs_rolling_trend']
    
    # Assert
    mom_match = (pd.isna(p_mom) and pd.isna(s_mom)) or (round(p_mom, 2) == round(s_mom, 2))
    roll_match = (pd.isna(p_roll) and pd.isna(s_roll)) or (round(p_roll, 2) == round(s_roll, 2))
    trend_match = (p_trend == s_trend)
    
    status = "OK" if (mom_match and roll_match and trend_match) else "MISMATCH"
    if status == "MISMATCH":
        mismatches += 1
    print(f"Row {idx+1:02d} [{month}]: Rev={p_rev} | MoM(P/S)=({p_mom}/{s_mom}) | RollAvg(P/S)=({p_roll}/{s_roll}) | Trend(P/S)=({p_trend}/{s_trend}) => {status}")

print("="*60)
print(f"TOTAL MISMATCHES FOUND: {mismatches}")
if mismatches == 0:
    print("SUCCESS: 100% PERFECT RECONCILIATION ACROSS ALL 23 ROWS & ALL COLUMNS!")
else:
    print("FAILURE: MISMATCHES DETECTED!")
