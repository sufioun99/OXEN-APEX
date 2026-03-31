
## 1) Page Summary
Proposed Page ID: 410
Page Name: Customer Master
Module: CRM
Purpose/user story: customer CRUD and profile maintenance.
Intended roles and access rules:
1. CRM_AGENT and ADMIN: full.
2. CUSTOMER: own record.

## 2) UX / Layout (APEX Regions)
Regions:
1. Customer form
2. Customer list IR
Items: customer fields including image.
Buttons: Save, Create, Delete.

## 3) SQL (Build-Ready)
List
```sql
SELECT customer_id, customer_name, phone_no, email, city, rewards, status
FROM sufioun_customers
WHERE (
  :G_ACTIVE_ROLE IN ('CRM_AGENT','ADMIN')
  OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
);
```

Validation
```sql
SELECT CASE WHEN COUNT(*)=0 THEN 1 ELSE 0 END ok_flag
FROM sufioun_customers
WHERE phone_no = :P410_PHONE_NO
  AND customer_id <> :P410_CUSTOMER_ID;
```

Process
APEX Form DML on sufioun_customers.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.crm-card{background:#fff;padding:12px;border-radius:12px}
```

## 6) Validations, Computations, and Processes
1. customer_name required.
2. phone unique.
3. Non-admin/non-agent cannot toggle status.

## 7) Report/Chart Definitions
IR with row links.

## 8) Acceptance Criteria
Customer create/update/search works and follows role rules.

