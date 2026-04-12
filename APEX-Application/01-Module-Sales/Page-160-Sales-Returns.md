
## 1) Page Summary
Proposed Page ID: 160
Page Name: Sales Returns
Module: Sales
Purpose/user story: register sales returns and return lines.
Intended roles and access rules:
1. Sales roles create/edit.
2. Customer read-only own returns.

## 2) UX / Layout (APEX Regions)
Regions:
1. Return Header Form (sufioun_sales_return_master)
2. Return Lines IG (sufioun_sales_return_details)
3. Linked Invoice Lines IR
Items: P160_SALES_RETURN_ID, P160_INVOICE_ID, P160_CUSTOMER_ID, P160_REASON.
Buttons: Save, Add Line, Complete Return.

## 3) SQL (Build-Ready)
Header
```sql
SELECT sales_return_id, invoice_id, customer_id, return_date, return_no,
       total_amount, reason, approved_by, status
FROM sufioun_sales_return_master
WHERE sales_return_id = :P160_SALES_RETURN_ID;
```

Lines
```sql
SELECT sales_return_det_id, sales_return_id, product_id, mrp, purchase_price,
       quantity, discount_amount, item_total, qty_return, reason
FROM sufioun_sales_return_details
WHERE sales_return_id = :P160_SALES_RETURN_ID;
```

Invoice lines reference
```sql
SELECT d.product_id, p.product_name, d.quantity sold_qty, d.mrp, d.discount_amount
FROM sufioun_sales_details d
JOIN sufioun_products p ON p.product_id = d.product_id
WHERE d.invoice_id = :P160_INVOICE_ID;
```

Validation
```sql
SELECT CASE WHEN :QTY_RETURN <=
  (SELECT NVL(SUM(quantity),0) FROM sufioun_sales_details
   WHERE invoice_id = :P160_INVOICE_ID AND product_id = :PRODUCT_ID)
THEN 1 ELSE 0 END ok_flag
FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.return-alert{background:#fff4e5;border:1px solid #ffcc80;padding:10px;border-radius:10px}
```

## 6) Validations, Computations, and Processes
1. Invoice required.
2. qty_return > 0 and <= sold qty.
3. Form + IG automatic row processing.

## 7) Report/Chart Definitions
IG with returned qty highlighting.

## 8) Acceptance Criteria
1. Return saved with detail rows.
2. Stock increases by qty_return.

