
## 1) Page Summary
Proposed Page ID: 110
Page Name: Sales Dashboard
Module: Sales
Purpose: Daily operational view of sales, invoice status, returns, and collections.
Intended roles and access rules:
1. SALES_MANAGER: all sales data.
2. SALES_REP: rows where sales_by = :G_EMPLOYEE_ID.
3. CUSTOMER: own invoices only where customer_id = :G_CUSTOMER_ID.

## 2) UX / Layout (APEX Regions)
Page layout structure:
Header: KPI ribbon.
Left Sidebar: date range + employee/customer filters.
Body: KPI cards/charts/report.
Footer: quick actions.

Regions:
1. RGN_KPI_CARDS (Cards, Body)
2. RGN_DAILY_TREND (Chart, Body)
3. RGN_TOP_PRODUCTS (Chart, Body)
4. RGN_RECENT_INVOICES (Interactive Report, Body)

Items:
1. P110_FROM_DT (Date Picker, source: computation, session state: yes)
2. P110_TO_DT (Date Picker, source: computation, session state: yes)
3. P110_EMPLOYEE_ID (Popup LOV, source: null, session state: yes)

Buttons and branching:
1. BTN_APPLY (refresh current page)
2. BTN_NEW_ORDER (branch to Page 130)

Dynamic Actions:
1. Event: Change on P110_FROM_DT, P110_TO_DT
   Selection: Items
   Actions: Refresh RGN_KPI_CARDS, RGN_DAILY_TREND, RGN_TOP_PRODUCTS, RGN_RECENT_INVOICES

## 3) SQL (Build-Ready)
Main KPI SQL
```sql
SELECT
  COUNT(*) invoice_count,
  NVL(SUM(grand_total),0) total_sales,
  NVL(SUM(CASE WHEN payment_status='PAID' THEN grand_total ELSE 0 END),0) paid_sales,
  NVL(SUM(CASE WHEN payment_status IN ('PENDING','PARTIAL') THEN grand_total ELSE 0 END),0) outstanding
FROM sufioun_sales_master m
WHERE m.invoice_date BETWEEN :P110_FROM_DT AND :P110_TO_DT
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  );
```

Charts SQL
```sql
SELECT TRUNC(invoice_date) sales_day,
       SUM(grand_total) amount
FROM sufioun_sales_master m
WHERE m.invoice_date BETWEEN :P110_FROM_DT AND :P110_TO_DT
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  )
GROUP BY TRUNC(invoice_date)
ORDER BY sales_day;
```

```sql
SELECT p.product_name,
       SUM(d.quantity) qty,
       SUM(d.mrp*d.quantity) gross_amount
FROM sufioun_sales_detail d
JOIN sufioun_sales_master m ON m.invoice_id = d.invoice_id
JOIN sufioun_products p ON p.product_id = d.product_id
WHERE m.invoice_date BETWEEN :P110_FROM_DT AND :P110_TO_DT
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  )
GROUP BY p.product_name
ORDER BY qty DESC FETCH FIRST 10 ROWS ONLY;
```

LOV SQL
```sql
SELECT first_name||' '||last_name display_value, employee_id return_value
FROM sufioun_employees
WHERE status = 1
ORDER BY 1;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.sales-kpi-grid{display:grid;grid-template-columns:repeat(4,minmax(180px,1fr));gap:12px}
.sales-kpi{background:#fff;border-left:4px solid var(--app-accent);padding:14px;border-radius:12px}
@media (max-width:768px){.sales-kpi-grid{grid-template-columns:1fr 1fr}}
```

## 6) Validations, Computations, and Processes
1. Validation: P110_FROM_DT <= P110_TO_DT.
2. Computation/defaults: P110_FROM_DT = TRUNC(SYSDATE)-30, P110_TO_DT = TRUNC(SYSDATE).
3. Processes: none.
4. Messaging: inline notification for invalid date range.

## 7) Report/Chart Definitions
1. Recent invoices columns: invoice_no, invoice_date, customer_name, grand_total, payment_status badge.
2. Status badges: PAID green, PARTIAL amber, PENDING red.

## 8) Acceptance Criteria
1. Role-based row filtering works per active role.
2. KPI totals match invoice records.
3. Charts refresh with date filters.

