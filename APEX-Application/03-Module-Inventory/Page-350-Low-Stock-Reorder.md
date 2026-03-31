
## 1) Page Summary
Proposed Page ID: 350
Page Name: Low Stock and Reorder
Module: Inventory
Purpose/user story: prioritize replenishment.
Intended roles and access rules: inventory roles.

## 2) UX / Layout (APEX Regions)
IR + supplier chart.

## 3) SQL (Build-Ready)
Main report
```sql
SELECT p.product_id, p.product_name, s.quantity current_qty, p.min_stock_level,
       (p.min_stock_level - s.quantity) reorder_qty,
       sup.supplier_name
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id
LEFT JOIN sufioun_suppliers sup ON sup.supplier_id = p.supplier_id
WHERE s.quantity <= p.min_stock_level
ORDER BY reorder_qty DESC;
```

Chart
```sql
SELECT sup.supplier_name, SUM(p.min_stock_level - s.quantity) reorder_total
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id=s.product_id
LEFT JOIN sufioun_suppliers sup ON sup.supplier_id=p.supplier_id
WHERE s.quantity <= p.min_stock_level
GROUP BY sup.supplier_name;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.reorder-qty{font-weight:800;color:#c62828}
```

## 6) Validations, Computations, and Processes
Optional process: create purchase order draft from selected rows.

## 7) Report/Chart Definitions
IR with action column.

## 8) Acceptance Criteria
Low-stock and reorder quantities are accurate.

