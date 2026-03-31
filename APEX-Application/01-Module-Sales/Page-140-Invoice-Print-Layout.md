
## 1) Page Summary
Proposed Page ID: 140
Page Name: Invoice Print Layout
Module: Sales
Purpose/user story: declarative printable invoice page.
Intended roles and access rules:
1. Sales roles with own/all filter.
2. Customer own invoice only.

## 2) UX / Layout (APEX Regions)
Body:
1. RGN_INVOICE_HEADER_STATIC (SQL report single-row)
2. RGN_INVOICE_LINES_PRINT (Classic report)
3. RGN_TERMS (Static content)
Buttons: Print, Back.

## 3) SQL (Build-Ready)
Header
```sql
SELECT m.invoice_no, m.invoice_date, c.customer_name, c.phone_no, c.address,
       e.first_name||' '||e.last_name sales_person,
       m.total_amount, m.discount, m.adjust_amount, m.vat, m.grand_total, m.payment_status
FROM sufioun_sales_master m
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
LEFT JOIN sufioun_employees e ON e.employee_id = m.sales_by
WHERE m.invoice_id = :P140_INVOICE_ID
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  );
```

Lines
```sql
SELECT p.product_name, d.quantity, d.mrp, d.discount_amount, d.line_total
FROM sufioun_sales_detail d
JOIN sufioun_products p ON p.product_id = d.product_id
WHERE d.invoice_id = :P140_INVOICE_ID
ORDER BY p.product_name;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
@media print{
  .t-Header,.t-Body-nav,.t-Footer{display:none !important}
  .t-Body-content{margin:0;padding:0}
}
```

## 6) Validations, Computations, and Processes
Validation: invoice exists and user authorized.

## 7) Report/Chart Definitions
Classic report totals in footer.

## 8) Acceptance Criteria
1. Print button generates clean printable layout.
2. Unauthorized user cannot print restricted invoice.

