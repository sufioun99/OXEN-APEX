
## 1) Page Summary
Proposed Page ID: 360
Page Name: Stock Adjustment Request
Module: Inventory
Purpose/user story: submit stock adjustment requests.
Intended roles and access rules:
1. STOREKEEPER
2. INVENTORY_MANAGER

## 2) UX / Layout (APEX Regions)
Master-detail:
1. Adjustment header form
2. Adjustment detail IG
Buttons: Save Request, Submit.

## 3) SQL (Build-Ready)
Header
```sql
SELECT adjust_id, adjust_no, request_date, requested_by, reason,
       adjust_status, approved_by, approved_date, posted_date
FROM sufioun_stock_adjust_master
WHERE adjust_id = :P360_ADJUST_ID;
```

Details
```sql
SELECT adjust_det_id, adjust_id, product_id, current_qty, adjust_qty, line_note
FROM sufioun_stock_adjust_detail
WHERE adjust_id = :P360_ADJUST_ID;
```

Current qty fetch
```sql
SELECT NVL(quantity,0) qty
FROM sufioun_stock
WHERE product_id = :PRODUCT_ID;
```

Validation
```sql
SELECT CASE WHEN :P360_REASON IS NOT NULL THEN 1 ELSE 0 END ok_flag FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.adj-request{background:#f0f9ff;border-radius:12px;padding:12px}
```

## 6) Validations, Computations, and Processes
1. At least one detail row.
2. adjust_qty <> 0.
3. default adjust_status = REQUESTED.

## 7) Report/Chart Definitions
Detail IG with +/- formatting.

## 8) Acceptance Criteria
New request saved in REQUESTED status with valid lines.

