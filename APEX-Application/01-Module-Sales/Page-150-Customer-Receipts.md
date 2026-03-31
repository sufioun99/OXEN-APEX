
## 1) Page Summary
Proposed Page ID: 150
Page Name: Customer Receipts
Module: Sales
Purpose/user story: capture customer receipts against invoices.
Intended roles and access rules:
1. SALES_MANAGER, SALES_REP create/update.
2. CUSTOMER read-only own receipts.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_RECEIPT_FORM (Form)
2. RGN_RECEIPT_HISTORY (IR)
Items: P150_RECEIPT_ID, P150_INVOICE_ID, P150_CUSTOMER_ID, P150_AMOUNT, P150_PAYMENT_METHOD, P150_REFERENCE_NO.
Buttons: Create Receipt, Save, New.
Dynamic Actions: Invoice change fetches due amount.

## 3) SQL (Build-Ready)
Form source
```sql
SELECT receipt_id, receipt_no, receipt_date, invoice_id, customer_id, amount,
       payment_method, reference_no, notes, received_by, status
FROM sufioun_customer_receipts
WHERE receipt_id = :P150_RECEIPT_ID;
```

Invoice LOV
```sql
SELECT m.invoice_no||' | Due: '||
       TO_CHAR(m.grand_total - NVL((SELECT SUM(r.amount) FROM sufioun_customer_receipts r WHERE r.invoice_id=m.invoice_id),0)) display_value,
       m.invoice_id return_value
FROM sufioun_sales_master m
WHERE m.status = 1
  AND m.payment_status IN ('PENDING','PARTIAL')
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
  )
ORDER BY m.invoice_date DESC;
```

History
```sql
SELECT r.receipt_no, r.receipt_date, c.customer_name, m.invoice_no,
       r.amount, r.payment_method, r.reference_no
FROM sufioun_customer_receipts r
JOIN sufioun_sales_master m ON m.invoice_id = r.invoice_id
JOIN sufioun_customers c ON c.customer_id = r.customer_id
WHERE (
  :G_ACTIVE_ROLE IN ('SALES_MANAGER','SALES_REP')
  OR (:G_ACTIVE_ROLE='CUSTOMER' AND r.customer_id = :G_CUSTOMER_ID)
)
ORDER BY r.receipt_date DESC;
```

Validation
```sql
SELECT CASE WHEN :P150_AMOUNT <=
  (SELECT m.grand_total - NVL((SELECT SUM(r.amount) FROM sufioun_customer_receipts r WHERE r.invoice_id=m.invoice_id AND r.receipt_id <> :P150_RECEIPT_ID),0)
   FROM sufioun_sales_master m WHERE m.invoice_id = :P150_INVOICE_ID)
THEN 1 ELSE 0 END ok_flag
FROM dual;
```

Processes
1. APEX Form DML on sufioun_customer_receipts.
2. Trigger sufioun_trg_sales_receipt_sync updates payment_status.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.receipt-strip{display:flex;gap:10px;flex-wrap:wrap}
.receipt-pill{background:#e6f7f7;border-radius:999px;padding:6px 10px}
```

## 6) Validations, Computations, and Processes
1. Amount positive.
2. Amount <= due.
3. received_by default :G_EMPLOYEE_ID.

## 7) Report/Chart Definitions
IR export enabled.

## 8) Acceptance Criteria
1. Receipts create/update correctly.
2. Invoice payment_status updates correctly.

