
## 1) Page Summary
Proposed Page ID: 320
Page Name: Categories and Departments
Module: Inventory
Purpose/user story: maintain categories, subcategories, departments.
Intended roles and access rules:
1. INVENTORY_MANAGER
2. ADMIN

## 2) UX / Layout (APEX Regions)
Tabbed regions:
1. Product Categories IG
2. Sub Categories IG
3. Departments IG

## 3) SQL (Build-Ready)
Categories
```sql
SELECT product_cat_id, product_cat_name, product_cat_desc, sort_order, status
FROM sufioun_product_categories;
```

Subcategories
```sql
SELECT sub_cat_id, sub_cat_name, product_cat_id, sort_order, status
FROM sufioun_sub_categories;
```

Departments
```sql
SELECT department_id, department_name, manager_id, company_id, location, status
FROM sufioun_departments;
```

LOV
```sql
SELECT product_cat_name display_value, product_cat_id return_value
FROM sufioun_product_categories
WHERE status=1
ORDER BY sort_order;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.tab-grid{gap:12px}
```

## 6) Validations, Computations, and Processes
IG automatic row processing for each tab.

## 7) Report/Chart Definitions
Editable IGs with row validation.

## 8) Acceptance Criteria
Edits save and are available in dependent LOVs.

