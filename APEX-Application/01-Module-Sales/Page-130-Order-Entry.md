
## 1) Page Summary
Proposed Page ID: 130
Page Name: Order Entry
Module: Sales
Purpose/user story: create and edit sales invoice (header + lines).
Intended roles and access rules:
1. SALES_MANAGER unrestricted.
2. SALES_REP own invoices.

## 2) UX / Layout (APEX Regions)
Page layout structure:
Header: invoice metadata.
Left Sidebar: customer/pricing inputs.
Body: header form + lines IG + totals.
Footer: action buttons.

Regions:
1. RGN_INVOICE_HEADER (Form, Body)
2. RGN_INVOICE_LINES (Editable IG, Body)
3. RGN_TOTALS (Display, Right)

Items:
1. P130_INVOICE_ID (Hidden, PK)
2. P130_CUSTOMER_ID (Popup LOV)
3. P130_DISCOUNT (Number)
4. P130_VAT (Number)
5. P130_ADJUST_AMOUNT (Number)
6. P130_SALES_BY (Hidden, default :G_EMPLOYEE_ID)

Buttons and branching:
1. BTN_CREATE
2. BTN_SAVE
3. BTN_ADD_LINE
4. BTN_DELETE
5. BTN_PRINT -> branch Page 140 with P140_INVOICE_ID

Dynamic Actions:
1. IG save success -> refresh totals region.

## 3) SQL (Build-Ready)
Header query
```sql
SELECT invoice_id, invoice_date, invoice_no, discount, vat, adjust_ref,
       total_amount, adjust_amount, grand_total, customer_id, sales_by,
       payment_status, notes, status
FROM sufioun_sales_master
WHERE invoice_id = :P130_INVOICE_ID;
```

Lines query
```sql
SELECT sales_det_id, invoice_id, product_id, mrp, purchase_price,
       discount_amount, quantity, line_total, description
FROM sufioun_sales_details
WHERE invoice_id = :P130_INVOICE_ID;
```

LOV SQL
```sql
SELECT product_name||' ('||product_id||')' display_value, product_id return_value
FROM sufioun_products
WHERE status = 1
ORDER BY product_name;
```

```sql
SELECT customer_name||' - '||phone_no display_value, customer_id return_value
FROM sufioun_customers
WHERE status = 1
ORDER BY customer_name;
```

Validation SQL
```sql
SELECT CASE
  WHEN NVL((SELECT quantity FROM sufioun_stock WHERE product_id = :PRODUCT_ID),0) >= :QUANTITY
  THEN 1 ELSE 0 END ok_flag
FROM dual;
```

Processes (DML)
1. APEX Form DML on sufioun_sales_master.
2. IG Automatic Row Processing on sufioun_sales_details.
3. Trigger sufioun_trg_sales_detail_sync recalculates totals.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.invoice-panel{background:#fff;border-radius:12px;padding:14px}
.totals-box{background:#0A2540;color:#fff;border-radius:12px;padding:14px}
```

## 6) Validations, Computations, and Processes
1. Customer required.
2. Quantity > 0.
3. Optional uniqueness validation (product per invoice line).
4. Computation: P130_SALES_BY = :G_EMPLOYEE_ID when create.
5. Error handling: inline notifications and IG row errors.

## 7) Report/Chart Definitions
IG columns: product LOV, mrp, quantity, discount_amount, line_total (read only).

## 8) Acceptance Criteria
1. Invoice and lines save successfully.
2. Grand total auto-updates.
3. Stock decreases on line insert/update.

