
## 1) Page Summary
Proposed Page ID: 330
Page Name: Stock on Hand Dashboard
Module: Inventory
Purpose/user story: real-time stock visibility.
Intended roles and access rules:
1. INVENTORY_MANAGER unrestricted
2. STOREKEEPER unrestricted

## 2) UX / Layout (APEX Regions)
Regions:
1. KPI cards
2. Category chart
3. Stock snapshot IR

## 3) SQL (Build-Ready)
Snapshot
```sql
SELECT p.product_id, p.product_name, c.product_cat_name, s.location, s.rack_no,
       s.quantity, p.min_stock_level,
       CASE WHEN s.quantity <= p.min_stock_level THEN 'LOW' ELSE 'OK' END stock_state
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id
LEFT JOIN sufioun_product_categories c ON c.product_cat_id = s.product_cat_id
ORDER BY c.product_cat_name, p.product_name;
```

KPI
```sql
SELECT COUNT(*) product_count,
       SUM(quantity) total_units,
       SUM(CASE WHEN s.quantity <= p.min_stock_level THEN 1 ELSE 0 END) low_stock_items
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.stock-low{color:#c62828;font-weight:700}
```

## 6) Validations, Computations, and Processes
None.

## 7) Report/Chart Definitions
Bar chart by product category.

## 8) Acceptance Criteria
Dashboard totals match stock table.

