
## 1) Page Summary
Proposed Page ID: 240
Page Name: Warranty Tracker
Module: Services
Purpose/user story: list tickets by warranty and status.
Intended roles and access rules:
1. Service roles as per RLS.
2. Customer own records only.

## 2) UX / Layout (APEX Regions)
Single IR with filters.

## 3) SQL (Build-Ready)
```sql
SELECT m.service_no, m.service_date, m.warranty_applicable,
       m.service_status, c.customer_name, m.invoice_id
FROM sufioun_service_master m
JOIN sufioun_customers c ON c.customer_id = m.customer_id
WHERE (:P240_WARRANTY IS NULL OR m.warranty_applicable = :P240_WARRANTY)
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND m.service_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
ORDER BY m.service_date DESC;
```

LOV
```sql
SELECT 'Yes' display_value, 'Y' return_value FROM dual
UNION ALL
SELECT 'No','N' FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.warranty-yes{background:#e8f5e9;padding:4px 8px;border-radius:8px}
.warranty-no{background:#ffebee;padding:4px 8px;border-radius:8px}
```

## 6) Validations, Computations, and Processes
Query-only page.

## 7) Report/Chart Definitions
Warranty badge and link to page 230.

## 8) Acceptance Criteria
Warranty filter and ticket drill-in operate correctly.

