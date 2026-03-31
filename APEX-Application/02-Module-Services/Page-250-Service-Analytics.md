
## 1) Page Summary
Proposed Page ID: 250
Page Name: Service Analytics
Module: Services
Purpose/user story: monitor open/closed, aging, MTTR.
Intended roles and access rules:
1. SERVICE_MANAGER all.
2. TECHNICIAN own.

## 2) UX / Layout (APEX Regions)
Regions: KPI cards, donut, aging bar, MTTR line.

## 3) SQL (Build-Ready)
KPI
```sql
SELECT
  SUM(CASE WHEN service_status IN ('RECEIVED','DIAGNOSIS','IN_PROGRESS') THEN 1 ELSE 0 END) open_tickets,
  SUM(CASE WHEN service_status IN ('COMPLETED','DELIVERED') THEN 1 ELSE 0 END) closed_tickets
FROM sufioun_service_master
WHERE (
  :G_ACTIVE_ROLE='SERVICE_MANAGER'
  OR (:G_ACTIVE_ROLE='TECHNICIAN' AND service_by=:G_EMPLOYEE_ID)
);
```

Aging
```sql
SELECT CASE
         WHEN TRUNC(SYSDATE)-TRUNC(service_date) <= 2 THEN '0-2'
         WHEN TRUNC(SYSDATE)-TRUNC(service_date) <= 5 THEN '3-5'
         WHEN TRUNC(SYSDATE)-TRUNC(service_date) <= 10 THEN '6-10'
         ELSE '10+'
       END aging_bucket,
       COUNT(*) ticket_count
FROM sufioun_service_master
WHERE service_status NOT IN ('DELIVERED','CANCELLED')
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND service_by=:G_EMPLOYEE_ID)
  )
GROUP BY CASE
         WHEN TRUNC(SYSDATE)-TRUNC(service_date) <= 2 THEN '0-2'
         WHEN TRUNC(SYSDATE)-TRUNC(service_date) <= 5 THEN '3-5'
         WHEN TRUNC(SYSDATE)-TRUNC(service_date) <= 10 THEN '6-10'
         ELSE '10+'
       END;
```

MTTR
```sql
SELECT TRUNC(completed_date,'MM') mth,
       ROUND(AVG(completed_date - service_date),2) mttr_days
FROM sufioun_service_master
WHERE completed_date IS NOT NULL
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND service_by=:G_EMPLOYEE_ID)
  )
GROUP BY TRUNC(completed_date,'MM')
ORDER BY mth;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.svc-kpi{background:#fff;border-radius:10px;padding:12px}
```

## 6) Validations, Computations, and Processes
None.

## 7) Report/Chart Definitions
KPI cards + chart trio.

## 8) Acceptance Criteria
Open/closed, aging, and MTTR values are correct.

