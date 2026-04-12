
## 1) Page Summary
Proposed Page ID: 340
Page Name: Inventory Movements
Module: Inventory
Purpose/user story: unified movement ledger.
Intended roles and access rules: Inventory roles and Admin.

## 2) UX / Layout (APEX Regions)
Single IR with movement facets and date filters.

## 3) SQL (Build-Ready)
```sql
SELECT movement_dt,
       movement_type,
       ref_no,
       product_id,
       product_name,
       qty_change,
       source_table
FROM (
  SELECT m.receive_date movement_dt, 'PURCHASE_RECEIVE' movement_type, m.receive_no ref_no,
         d.product_id, p.product_name, d.receive_quantity qty_change, 'Sufioun_Purchase_receive_Detailss' source_table
  FROM Sufioun_Purchase_receive_master m
  JOIN Sufioun_Purchase_receive_Detailss d ON d.receive_id = m.receive_id
  JOIN sufioun_products p ON p.product_id = d.product_id

  UNION ALL

  SELECT m.invoice_date, 'SALES', m.invoice_no, d.product_id, p.product_name, -d.quantity, 'sufioun_sales_details'
  FROM sufioun_sales_master m
  JOIN sufioun_sales_details d ON d.invoice_id = m.invoice_id
  JOIN sufioun_products p ON p.product_id = d.product_id

  UNION ALL

  SELECT r.return_date, 'SALES_RETURN', r.return_no, d.product_id, p.product_name, d.qty_return, 'sufioun_sales_return_details'
  FROM sufioun_sales_return_master r
  JOIN sufioun_sales_return_details d ON d.sales_return_id = r.sales_return_id
  JOIN sufioun_products p ON p.product_id = d.product_id

  UNION ALL

  SELECT d.damage_date, 'DAMAGE', d.damage_no, dd.product_id, p.product_name, -dd.damage_quantity, 'sufioun_damage_details'
  FROM sufioun_damage d
  JOIN sufioun_damage_details dd ON dd.damage_id = d.damage_id
  JOIN sufioun_products p ON p.product_id = dd.product_id

  UNION ALL

  SELECT a.posted_date, 'STOCK_ADJUST', a.adjust_no, ad.product_id, p.product_name, ad.adjust_qty, 'sufioun_stock_adjust_detail'
  FROM sufioun_stock_adjust_master a
  JOIN sufioun_stock_adjust_detail ad ON ad.adjust_id = a.adjust_id
  JOIN sufioun_products p ON p.product_id = ad.product_id
  WHERE a.adjust_status = 'POSTED'
)
WHERE movement_dt BETWEEN :P340_FROM_DT AND :P340_TO_DT
  AND (:P340_MOVEMENT_TYPE IS NULL OR movement_type = :P340_MOVEMENT_TYPE)
ORDER BY movement_dt DESC;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.qty-neg{color:#b71c1c}
.qty-pos{color:#1b5e20}
```

## 6) Validations, Computations, and Processes
Query-only page.

## 7) Report/Chart Definitions
Conditional formatting by qty sign.

## 8) Acceptance Criteria
All movement sources appear with correct quantity direction.

