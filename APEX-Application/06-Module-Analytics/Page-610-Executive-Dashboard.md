
## 1) Page Summary
Proposed Page ID: 610
Page Name: Executive Dashboard
Module: Analytics
Purpose/user story: consolidated business KPIs and trends.
Intended roles and access rules:
1. ADMIN
2. SALES_MANAGER
3. SERVICE_MANAGER
4. INVENTORY_MANAGER

## 2) UX / Layout (APEX Regions)
Regions: KPI cards, trend chart, SLA chart, low-stock risk chart.

## 3) SQL (Build-Ready)
KPI
```sql
SELECT
  (SELECT NVL(SUM(grand_total),0) FROM sufioun_sales_master WHERE invoice_date >= ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)) monthly_sales,
  (SELECT COUNT(*) FROM sufioun_service_master WHERE service_status IN ('RECEIVED','DIAGNOSIS','IN_PROGRESS')) open_tickets,
  (SELECT COUNT(*) FROM sufioun_stock s JOIN sufioun_products p ON p.product_id=s.product_id WHERE s.quantity<=p.min_stock_level) low_stock_items
FROM dual;
```

Trend
```sql
SELECT TRUNC(invoice_date,'MM') month_dt, SUM(grand_total) amount
FROM sufioun_sales_master
WHERE invoice_date >= ADD_MONTHS(TRUNC(SYSDATE,'MM'),-12)
GROUP BY TRUNC(invoice_date,'MM')
ORDER BY month_dt;
```

SLA
```sql
SELECT service_status, COUNT(*) cnt
FROM sufioun_service_master
GROUP BY service_status;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.exec-kpi{background:#fff;border-top:4px solid var(--app-primary);padding:12px;border-radius:12px}
```

## 6) Validations, Computations, and Processes
Query-only.

## 7) Report/Chart Definitions
Line + donut + bar charts.

## 8) Acceptance Criteria
Dashboard renders role-allowed KPIs and trends accurately.

