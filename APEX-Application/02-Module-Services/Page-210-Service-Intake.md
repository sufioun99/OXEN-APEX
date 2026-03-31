
## 1) Page Summary
Proposed Page ID: 210
Page Name: Service Intake
Module: Services
Purpose/user story: create and maintain service requests.
Intended roles and access rules:
1. SERVICE_MANAGER all rows.
2. TECHNICIAN own rows where service_by = :G_EMPLOYEE_ID.
3. CUSTOMER own rows where customer_id = :G_CUSTOMER_ID.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_SERVICE_FORM (Form)
2. RGN_IMAGE_UPLOAD (Before/After images)
Items: P210_SERVICE_ID, P210_CUSTOMER_ID, P210_INVOICE_ID, P210_PROBLEM_DESC, P210_SERVICE_STATUS.
Buttons: Save, Create Ticket, Go Detail.
DA: On invoice change refresh warranty_applicable display.

## 3) SQL (Build-Ready)
Form
```sql
SELECT service_id, service_no, service_date, customer_id, invoice_id, invoice_date,
       warranty_applicable, service_by, service_charge_total, total_price, vat, grand_total,
       service_status, problem_desc, resolution_desc, completed_date, status
FROM sufioun_service_master
WHERE service_id = :P210_SERVICE_ID
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND service_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
  );
```

Customer LOV
```sql
SELECT customer_name||' - '||phone_no display_value, customer_id return_value
FROM sufioun_customers
WHERE status=1
ORDER BY customer_name;
```

Invoice LOV
```sql
SELECT invoice_no||' - '||TO_CHAR(invoice_date,'YYYY-MM-DD') display_value, invoice_id return_value
FROM sufioun_sales_master
ORDER BY invoice_date DESC;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.svc-status{font-weight:700;padding:4px 10px;border-radius:999px;background:#e3f2fd}
```

## 6) Validations, Computations, and Processes
1. problem_desc required.
2. service_status constrained by table check values.
3. APEX Form DML on sufioun_service_master.

## 7) Report/Chart Definitions
N/A.

## 8) Acceptance Criteria
Ticket created with valid status and role-safe access.

