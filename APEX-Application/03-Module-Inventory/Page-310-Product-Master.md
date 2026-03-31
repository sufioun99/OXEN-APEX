
## 1) Page Summary
Proposed Page ID: 310
Page Name: Product Master
Module: Inventory
Purpose/user story: CRUD for sufioun_products.
Intended roles and access rules:
1. INVENTORY_MANAGER
2. STOREKEEPER

## 2) UX / Layout (APEX Regions)
Regions:
1. Product form region
2. Product list IR region
Items: product attributes and image upload fields.
Buttons: Create, Save, Delete.

## 3) SQL (Build-Ready)
Main report
```sql
SELECT product_id, product_code, product_name, category_id, sub_cat_id, brand_id,
       purchase_price, selling_price, min_stock_level, max_stock_level, status
FROM sufioun_products
ORDER BY product_name;
```

Category LOV
```sql
SELECT product_cat_name display_value, product_cat_id return_value
FROM sufioun_product_categories
WHERE status=1
ORDER BY sort_order;
```

Subcategory LOV
```sql
SELECT sub_cat_name display_value, sub_cat_id return_value
FROM sufioun_sub_categories
WHERE product_cat_id = :P310_CATEGORY_ID
ORDER BY sort_order;
```

Validation
```sql
SELECT CASE WHEN :P310_SELLING_PRICE >= :P310_PURCHASE_PRICE THEN 1 ELSE 0 END ok_flag
FROM dual;
```

Process
APEX Form DML on sufioun_products.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.prod-form{background:#fff;padding:12px;border-radius:12px}
```

## 6) Validations, Computations, and Processes
1. product_name required.
2. selling_price >= purchase_price.
3. min_stock_level <= max_stock_level.

## 7) Report/Chart Definitions
IR row links to form.

## 8) Acceptance Criteria
Product CRUD persists and LOV dependencies work.

