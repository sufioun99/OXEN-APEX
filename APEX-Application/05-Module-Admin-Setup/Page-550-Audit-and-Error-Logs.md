
## 1) Page Summary
Proposed Page ID: 550
Page Name: Audit and Error Logs
Module: Admin/Setup
Purpose/user story: monitor user actions and application errors.
Intended roles and access rules:
1. ADMIN only.

## 2) UX / Layout (APEX Regions)
Filter toolbar + IR.

## 3) SQL (Build-Ready)
```sql
SELECT log_ts, module_name, action_name, user_id, role_code, entity_name, entity_id, severity, message
FROM sufioun_audit_log
WHERE (:P550_SEVERITY IS NULL OR severity=:P550_SEVERITY)
  AND (:P550_FROM_TS IS NULL OR log_ts >= :P550_FROM_TS)
  AND (:P550_TO_TS IS NULL OR log_ts < :P550_TO_TS + 1)
ORDER BY log_ts DESC;
```

LOV
```sql
SELECT 'INFO' display_value, 'INFO' return_value FROM dual
UNION ALL SELECT 'WARN','WARN' FROM dual
UNION ALL SELECT 'ERROR','ERROR' FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.sev-error{color:#b71c1c;font-weight:700}
.sev-warn{color:#ef6c00;font-weight:700}
.sev-info{color:#1565c0;font-weight:700}
```

## 6) Validations, Computations, and Processes
Query-only.

## 7) Report/Chart Definitions
Conditional severity formatting.

## 8) Acceptance Criteria
Admin can filter and export logs.

