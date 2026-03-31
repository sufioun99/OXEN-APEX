
## 1) Page Summary
Proposed Page ID: 220
Page Name: Ticket Queue and Assignment
Module: Services
Purpose/user story: operational queue and assignment control.
Intended roles and access rules:
1. SERVICE_MANAGER all rows.
2. TECHNICIAN own rows.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_TICKET_QUEUE (IR)
2. RGN_ASSIGN_MODAL (Dialog)
Items: P220_STATUS, P220_TECH_ID.
Buttons: Assign, Mark In Progress, Mark Completed.

## 3) SQL (Build-Ready)
Queue
```sql
SELECT m.service_id, m.service_no, m.service_date, c.customer_name,
       m.service_status, m.warranty_applicable,
       e.first_name||' '||e.last_name technician,
       (TRUNC(SYSDATE)-TRUNC(m.service_date)) aging_days
FROM sufioun_service_master m
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
LEFT JOIN sufioun_employees e ON e.employee_id = m.service_by
WHERE (:P220_STATUS IS NULL OR m.service_status = :P220_STATUS)
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND m.service_by=:G_EMPLOYEE_ID)
  )
ORDER BY m.service_date DESC;
```

Technician LOV
```sql
SELECT first_name||' '||last_name display_value, employee_id return_value
FROM sufioun_employees
WHERE status=1
ORDER BY 1;
```

Assignment process
```sql
UPDATE sufioun_service_master
SET service_by = :P220_TECH_ID,
    upd_by = :APP_USER,
    upd_dt = SYSDATE
WHERE service_id = :P220_SERVICE_ID;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.aging-high{color:#b71c1c;font-weight:700}
```

## 6) Validations, Computations, and Processes
1. Assignment allowed only for SERVICE_MANAGER.
2. Validate legal status transitions.

## 7) Report/Chart Definitions
Status badges and aging conditional formatting.

## 8) Acceptance Criteria
Assignment updates technician and status workflow correctly.

