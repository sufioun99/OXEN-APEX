
## 1) Page Summary
Proposed Page ID: 230
Page Name: Ticket Detail
Module: Services
Purpose/user story: capture parts/labor/notes for service ticket.
Intended roles and access rules:
1. SERVICE_MANAGER all rows.
2. TECHNICIAN own rows.
3. CUSTOMER read-only own rows.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_TICKET_SUMMARY
2. RGN_SERVICE_DETAILS_IG
3. RGN_RESOLUTION_NOTES
Items: P230_SERVICE_ID, P230_SERVICE_STATUS, P230_RESOLUTION_DESC.
Buttons: Save Detail, Close Ticket.

## 3) SQL (Build-Ready)
Summary
```sql
SELECT service_no, service_date, customer_id, service_status, problem_desc, resolution_desc
FROM sufioun_service_master
WHERE service_id = :P230_SERVICE_ID
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND service_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
  );
```

IG dataset
```sql
SELECT service_det_id, service_id, product_id, servicelist_id, parts_id,
       service_charge, parts_price, quantity, line_total, description, warranty_status
FROM sufioun_service_details
WHERE service_id = :P230_SERVICE_ID;
```

Service LOV
```sql
SELECT service_name||' ('||service_cost||')' display_value, servicelist_id return_value
FROM sufioun_service_list
WHERE status=1
ORDER BY service_name;
```

Parts LOV
```sql
SELECT parts_name display_value, parts_id return_value
FROM sufioun_parts
WHERE status=1
ORDER BY parts_name;
```

Validation
```sql
SELECT CASE WHEN :QUANTITY > 0 THEN 1 ELSE 0 END ok_flag FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.ticket-shell{background:#fff;border-radius:12px;padding:12px}
```

## 6) Validations, Computations, and Processes
1. IG Automatic Row Processing on sufioun_service_details.
2. Header update process for resolution and status.
3. Compute completed_date when status becomes COMPLETED.

## 7) Report/Chart Definitions
IG totals for service_charge/parts_price.

## 8) Acceptance Criteria
Ticket detail lines persist and roll into ticket totals.

