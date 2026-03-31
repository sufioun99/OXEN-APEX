
## 1) Page Summary
Proposed Page ID: 420
Page Name: Customer 360 Timeline
Module: CRM
Purpose/user story: complete customer journey timeline.
Intended roles and access rules:
1. CRM_AGENT, SALES_MANAGER, SERVICE_MANAGER, ADMIN.
2. CUSTOMER own timeline only.

## 2) UX / Layout (APEX Regions)
Left: customer profile card.
Body: timeline IR.

## 3) SQL (Build-Ready)
Customer summary
```sql
SELECT customer_id, customer_name, phone_no, email, city, rewards, remarks
FROM sufioun_customers
WHERE customer_id = :P420_CUSTOMER_ID
  AND (
    :G_ACTIVE_ROLE IN ('CRM_AGENT','SALES_MANAGER','SERVICE_MANAGER','ADMIN')
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
  );
```

Timeline
```sql
SELECT event_dt, event_type, event_ref, amount, status_text
FROM (
  SELECT m.invoice_date event_dt, 'SALE' event_type, m.invoice_no event_ref,
         m.grand_total amount, m.payment_status status_text
  FROM sufioun_sales_master m
  WHERE m.customer_id = :P420_CUSTOMER_ID
  UNION ALL
  SELECT s.service_date, 'SERVICE', s.service_no, s.grand_total, s.service_status
  FROM sufioun_service_master s
  WHERE s.customer_id = :P420_CUSTOMER_ID
  UNION ALL
  SELECT r.return_date, 'SALES_RETURN', r.return_no, r.total_amount, TO_CHAR(r.status)
  FROM sufioun_sales_return_master r
  WHERE r.customer_id = :P420_CUSTOMER_ID
)
ORDER BY event_dt DESC;
```

## 4) HTML (only if required)
```html
<span class="timeline-dot"></span>
```

## 5) CSS (REQUIRED)
```css
.timeline-dot{display:inline-block;width:10px;height:10px;background:var(--app-accent);border-radius:50%}
```

## 6) Validations, Computations, and Processes
P420_CUSTOMER_ID required.

## 7) Report/Chart Definitions
Event icon by event_type and status color badges.

## 8) Acceptance Criteria
Timeline includes sales, service, returns in reverse chronological order.

