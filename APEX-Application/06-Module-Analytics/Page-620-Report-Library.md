
## 1) Page Summary
Proposed Page ID: 620
Page Name: Report Library
Module: Analytics
Purpose/user story: role-aware index of available reports.
Intended roles and access rules: all authenticated users, filtered by role.

## 2) UX / Layout (APEX Regions)
Cards region grouped by module.

## 3) SQL (Build-Ready)
```sql
SELECT report_name, module_name, page_id, required_role
FROM (
  SELECT 'Sales Daily Report' report_name, 'Sales' module_name, 170 page_id, 'SALES' required_role FROM dual
  UNION ALL SELECT 'Service Analytics','Services',250,'SERVICE' FROM dual
  UNION ALL SELECT 'Stock Movement','Inventory',340,'INVENTORY' FROM dual
  UNION ALL SELECT 'Customer Segmentation','CRM',430,'CRM' FROM dual
  UNION ALL SELECT 'Audit Logs','Admin',550,'ADMIN' FROM dual
)
WHERE (
  required_role='ADMIN' AND :G_ACTIVE_ROLE='ADMIN'
  OR required_role='SALES' AND :G_ACTIVE_ROLE IN ('SALES_MANAGER','SALES_REP')
  OR required_role='SERVICE' AND :G_ACTIVE_ROLE IN ('SERVICE_MANAGER','TECHNICIAN')
  OR required_role='INVENTORY' AND :G_ACTIVE_ROLE IN ('INVENTORY_MANAGER','STOREKEEPER')
  OR required_role='CRM' AND :G_ACTIVE_ROLE='CRM_AGENT'
);
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.report-card{background:#fff;border-radius:12px;padding:14px}
```

## 6) Validations, Computations, and Processes
None.

## 7) Report/Chart Definitions
Cards with deep links to report pages.

## 8) Acceptance Criteria
Library shows only reports available to active role.

