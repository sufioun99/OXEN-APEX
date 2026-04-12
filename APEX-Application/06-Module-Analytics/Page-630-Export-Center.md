
## 1) Page Summary
Proposed Page ID: 630
Page Name: Export Center
Module: Analytics
Purpose/user story: export operational datasets in IR format.
Intended roles and access rules: manager/admin role-based access per dataset.

## 2) UX / Layout (APEX Regions)
Region selector + 3 IR datasets.

## 3) SQL (Build-Ready)
Sales export dataset
```sql
SELECT m.invoice_no, m.invoice_date, c.customer_name,
       d.product_id, p.product_name, d.quantity, d.mrp, d.discount_amount, d.line_total,
       m.grand_total, m.payment_status
FROM sufioun_sales_master m
JOIN sufioun_sales_details d ON d.invoice_id = m.invoice_id
JOIN sufioun_products p ON p.product_id = d.product_id
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
WHERE m.invoice_date BETWEEN :P630_FROM_DT AND :P630_TO_DT;
```

Service export dataset
```sql
SELECT m.service_no, m.service_date, c.customer_name, m.service_status,
       d.servicelist_id, sl.service_name, d.parts_id, d.quantity, d.line_total
FROM sufioun_service_master m
LEFT JOIN sufioun_service_details d ON d.service_id = m.service_id
LEFT JOIN sufioun_service_list sl ON sl.servicelist_id = d.servicelist_id
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
WHERE m.service_date BETWEEN :P630_FROM_DT AND :P630_TO_DT;
```

Stock export dataset
```sql
SELECT s.product_id, p.product_name, s.quantity, s.location, s.rack_no, s.last_update
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.export-toolbar{display:flex;gap:10px;flex-wrap:wrap}
```

## 6) Validations, Computations, and Processes
Date range validation.

## 7) Report/Chart Definitions
Interactive Reports with CSV/XLSX/PDF export.

## 8) Acceptance Criteria
Operational exports are generated with selected filters.
