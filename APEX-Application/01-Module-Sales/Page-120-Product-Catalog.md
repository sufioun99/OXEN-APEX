
## 1) Page Summary
Proposed Page ID: 120
Page Name: Product Catalog
Module: Sales
Purpose/user story: browse active products with facets and storefront cards.
Intended roles and access rules:
1. Sales roles: all active products.
2. Customer: all active products.

## 2) UX / Layout (APEX Regions)
Page layout structure:
Header: global search.
Left Sidebar: departments/categories.
Body: faceted region + cards.
Footer: hidden.

Regions:
1. RGN_DEPARTMENTS (Tree, Left Sidebar)
2. RGN_FACETS (Faceted Search, Body)
3. RGN_PRODUCT_CARDS (Cards, Body)

Items:
1. P120_SEARCH (Text Field, source null, session state yes)
2. P120_CATEGORY_ID (Select List, source null, session state yes)
3. P120_SUB_CAT_ID (Select List, source null, session state yes)

Buttons and branching:
1. BTN_ADD_TO_CART_PLACEHOLDER (no branch)

Dynamic Actions:
1. Change P120_SEARCH/P120_CATEGORY_ID/P120_SUB_CAT_ID -> Refresh RGN_PRODUCT_CARDS

## 3) SQL (Build-Ready)
Main cards query
```sql
SELECT p.product_id,
       p.product_name,
       p.selling_price,
       p.mrp,
       c.product_cat_name,
       s.sub_cat_name,
       CASE WHEN NVL(st.quantity,0) <= p.min_stock_level THEN 'LOW' ELSE 'OK' END stock_flag,
       apex_util.get_blob_file_src('P120_IMG', p.product_id) img_url
FROM sufioun_products p
LEFT JOIN sufioun_product_categories c ON c.product_cat_id = p.category_id
LEFT JOIN sufioun_sub_categories s ON s.sub_cat_id = p.sub_cat_id
LEFT JOIN sufioun_stock st ON st.product_id = p.product_id
WHERE p.status = 1
  AND (:P120_SEARCH IS NULL OR UPPER(p.product_name) LIKE '%'||UPPER(:P120_SEARCH)||'%')
  AND (:P120_CATEGORY_ID IS NULL OR p.category_id = :P120_CATEGORY_ID)
  AND (:P120_SUB_CAT_ID IS NULL OR p.sub_cat_id = :P120_SUB_CAT_ID);
```

Faceted dataset
```sql
SELECT p.product_id,
       p.product_name,
       c.product_cat_name category_name,
       s.sub_cat_name sub_category_name,
       b.brand_name,
       p.selling_price,
       NVL(st.quantity,0) stock_qty
FROM sufioun_products p
LEFT JOIN sufioun_product_categories c ON c.product_cat_id = p.category_id
LEFT JOIN sufioun_sub_categories s ON s.sub_cat_id = p.sub_cat_id
LEFT JOIN sufioun_brand b ON b.brand_id = p.brand_id
LEFT JOIN sufioun_stock st ON st.product_id = p.product_id
WHERE p.status = 1;
```

LOV SQL
```sql
SELECT product_cat_name display_value, product_cat_id return_value
FROM sufioun_product_categories
WHERE status = 1
ORDER BY sort_order, product_cat_name;
```

## 4) HTML (only if required)
```html
<div class="product-actions">
  <button class="t-Button t-Button--hot">View</button>
  <button class="t-Button">Add</button>
</div>
```

## 5) CSS (REQUIRED)
```css
.product-actions{display:flex;gap:8px;padding:10px}
.product-title{font-weight:700;min-height:42px}
.product-price{color:var(--app-primary);font-size:18px;font-weight:800}
```

## 6) Validations, Computations, and Processes
1. Computation: no default category.
2. Process: none.

## 7) Report/Chart Definitions
Product cards with image, title, category, price, stock badge.

## 8) Acceptance Criteria
1. Search/filter returns expected products.
2. Low-stock badge appears by min_stock_level.
3. Mobile layout is readable.

