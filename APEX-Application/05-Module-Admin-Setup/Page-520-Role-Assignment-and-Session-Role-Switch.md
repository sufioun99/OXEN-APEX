
## 1) Page Summary
Proposed Page ID: 520
Page Name: Role Assignment and Session Role Switch
Module: Admin/Setup
Purpose/user story: assign multiple roles and switch active role per session.
Intended roles and access rules:
1. ADMIN for assignment.
2. All users for self role switch.

## 2) UX / Layout (APEX Regions)
Regions:
1. Admin Role Assignment IG
2. Active Role Selector
Items: P520_USER_ID, P520_ROLE_ID, P520_ACTIVE_ROLE.
Buttons: Save Roles, Switch Role.

## 3) SQL (Build-Ready)
Assigned roles
```sql
SELECT ur.user_role_id, ur.user_id, ar.role_code, ar.role_name, ur.is_default, ur.status
FROM sufioun_user_roles ur
JOIN sufioun_app_roles ar ON ar.role_id = ur.role_id
WHERE ur.user_id = :G_USER_ID
  AND ur.status = 1
ORDER BY ur.is_default DESC, ar.role_name;
```

Selector LOV
```sql
SELECT ar.role_name display_value, ar.role_code return_value
FROM sufioun_user_roles ur
JOIN sufioun_app_roles ar ON ar.role_id = ur.role_id
WHERE ur.user_id = :G_USER_ID
  AND ur.status = 1
  AND ar.status = 1
ORDER BY ar.role_name;
```

Process
```plsql
BEGIN
  apex_util.set_session_state('G_ACTIVE_ROLE', :P520_ACTIVE_ROLE);
  INSERT INTO sufioun_audit_log(log_id, module_name, action_name, user_id, role_code, severity, message)
  VALUES ('LOG'||TO_CHAR(SYSTIMESTAMP,'YYYYMMDDHH24MISSFF3'),
          'ADMIN','ROLE_SWITCH', :G_USER_ID, :P520_ACTIVE_ROLE, 'INFO',
          'Active role switched');
END;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.role-switch{max-width:420px;background:#fff;border-radius:12px;padding:12px}
```

## 6) Validations, Computations, and Processes
1. Active role must be in current user assigned roles.
2. Admin-only authorization on assignment region.

## 7) Report/Chart Definitions
Role chips and default-role indicator.

## 8) Acceptance Criteria
Role switch updates session behavior immediately.

