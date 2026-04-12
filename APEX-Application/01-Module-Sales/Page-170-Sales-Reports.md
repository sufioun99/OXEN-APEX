
## 1) Page Summary
Proposed Page ID: 170
Page Name: Sales Reports
Module: Sales
Purpose/user story: daily sales and dimensional analysis reports.
Intended roles and access rules:
1. SALES_MANAGER full data.
2. SALES_REP own data.
3. CUSTOMER own data.

## 2) UX / Layout (APEX Regions)
Regions:
1. Report tabs: Daily, Product, Category, Customer.
2. Export toolbar.
Items: P170_FROM_DT, P170_TO_DT.

## 3) SQL (Build-Ready)
Daily
```sql
SELECT TRUNC(m.invoice_date) sales_day,
       COUNT(*) invoice_count,
       SUM(m.grand_total) sales_amount
FROM sufioun_sales_master m
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY TRUNC(m.invoice_date)
ORDER BY sales_day;
```

By product
```sql
SELECT p.product_name, SUM(d.quantity) qty, SUM(d.mrp*d.quantity) gross
FROM sufioun_sales_details d
JOIN sufioun_sales_master m ON m.invoice_id=d.invoice_id
JOIN sufioun_products p ON p.product_id=d.product_id
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY p.product_name
ORDER BY gross DESC;
```

By category
```sql
SELECT c.product_cat_name, SUM(d.quantity) qty, SUM(d.mrp*d.quantity) gross
FROM sufioun_sales_details d
JOIN sufioun_sales_master m ON m.invoice_id=d.invoice_id
JOIN sufioun_products p ON p.product_id=d.product_id
LEFT JOIN sufioun_product_categories c ON c.product_cat_id=p.category_id
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY c.product_cat_name
ORDER BY gross DESC;
```

By customer
```sql
SELECT cu.customer_name, COUNT(DISTINCT m.invoice_id) invoices, SUM(m.grand_total) amount
FROM sufioun_sales_master m
JOIN sufioun_customers cu ON cu.customer_id = m.customer_id
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY cu.customer_name
ORDER BY amount DESC;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.report-toolbar{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
```

## 6) Validations, Computations, and Processes
1. from date <= to date.

## 7) Report/Chart Definitions
All report tabs as Interactive Reports with export enabled.

## 8) Acceptance Criteria
1. All four dimensions report correctly.
2. Exports work.

