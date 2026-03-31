
## 1) Page Summary
Proposed Page ID: 370
Page Name: Stock Adjustment Approve/Post
Module: Inventory
Purpose/user story: approve and post stock adjustments.
Intended roles and access rules:
1. INVENTORY_MANAGER approve/post.
2. STOREKEEPER read-only.

## 2) UX / Layout (APEX Regions)
Regions:
1. Pending requests IR
2. Request detail IR
Buttons: Approve, Reject, Post.

## 3) SQL (Build-Ready)
Pending
```sql
SELECT adjust_id, adjust_no, request_date, requested_by, adjust_status, reason
FROM sufioun_stock_adjust_master
WHERE adjust_status IN ('REQUESTED','APPROVED')
ORDER BY request_date DESC;
```

Approve process
```sql
UPDATE sufioun_stock_adjust_master
SET adjust_status = 'APPROVED',
    approved_by = :G_EMPLOYEE_ID,
    approved_date = SYSDATE,
    upd_by = :APP_USER,
    upd_dt = SYSDATE
WHERE adjust_id = :P370_ADJUST_ID
  AND adjust_status = 'REQUESTED';
```

Post process
```plsql
DECLARE
BEGIN
  FOR r IN (
    SELECT product_id, adjust_qty
    FROM sufioun_stock_adjust_detail
    WHERE adjust_id = :P370_ADJUST_ID
  ) LOOP
    sufioun_update_stock_qty(r.product_id, r.adjust_qty);
  END LOOP;

  UPDATE sufioun_stock_adjust_master
  SET adjust_status = 'POSTED',
      posted_date = SYSDATE,
      upd_by = :APP_USER,
      upd_dt = SYSDATE
  WHERE adjust_id = :P370_ADJUST_ID
    AND adjust_status = 'APPROVED';
END;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.status-requested{color:#ef6c00}
.status-approved{color:#1565c0}
.status-posted{color:#2e7d32}
.status-rejected{color:#b71c1c}
```

## 6) Validations, Computations, and Processes
1. Authorization: INVENTORY_MANAGER only for Approve/Post.
2. Post allowed only from APPROVED state.

## 7) Report/Chart Definitions
Status badge + action links.

## 8) Acceptance Criteria
Approved requests post exactly once and update stock.

