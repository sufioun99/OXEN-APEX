
## 1) Page Summary
Proposed Page ID: 530
Page Name: Lookup and Status Setup
Module: Admin/Setup
Purpose/user story: maintain lookups and status masters.
Intended roles and access rules:
1. ADMIN only.

## 2) UX / Layout (APEX Regions)
Tabbed editable IG regions for service, expense, categories.

## 3) SQL (Build-Ready)
```sql
SELECT servicelist_id, service_name, service_cost, estimated_time, status
FROM sufioun_service_list;
```

```sql
SELECT expense_type_id, expense_code, type_name, default_amount, expense_category, status
FROM sufioun_expense_list;
```

```sql
SELECT product_cat_id, product_cat_name, sort_order, status
FROM sufioun_product_categories;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.lookup-tabs{background:#fff;border-radius:12px}
```

## 6) Validations, Computations, and Processes
IG automatic row processing by tab.

## 7) Report/Chart Definitions
Inline editable grids.

## 8) Acceptance Criteria
Lookup edits persist and drive LOVs across app.

