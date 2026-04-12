-- 002_seed_roles_and_mappings.sql
-- Seed required application roles and map current users.

INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-001', 'ADMIN', 'Admin', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-002', 'SALES_MANAGER', 'Sales Manager', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-003', 'SALES_REP', 'Sales Representative', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-004', 'SERVICE_MANAGER', 'Service Manager', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-005', 'TECHNICIAN', 'Technician', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-006', 'INVENTORY_MANAGER', 'Inventory Manager', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-007', 'STOREKEEPER', 'Storekeeper', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-008', 'CRM_AGENT', 'CRM/Support Agent', 1);
INSERT INTO sufioun_app_roles (role_id, role_code, role_name, status)
VALUES ('ROL-009', 'CUSTOMER', 'Customer', 1);

-- Backfill email for existing users from employee records where available.
UPDATE sufioun_com_users u
SET email = (
  SELECT LOWER(e.email)
  FROM sufioun_employees e
  WHERE e.employee_id = u.employee_id
)
WHERE u.employee_id IS NOT NULL
  AND u.email IS NULL
  AND EXISTS (
    SELECT 1 FROM sufioun_employees e2 WHERE e2.employee_id = u.employee_id AND e2.email IS NOT NULL
  );

-- Map legacy single-role records into new role model.
INSERT INTO sufioun_user_roles (user_id, role_id, is_default, status)
SELECT u.user_id,
       CASE u.role
         WHEN 'admin' THEN 'ROL-001'
         WHEN 'manager' THEN 'ROL-002'
         WHEN 'technician' THEN 'ROL-005'
         WHEN 'cashier' THEN 'ROL-003'
         ELSE 'ROL-003'
       END,
       1,
      1
FROM sufioun_com_users u
WHERE NOT EXISTS (
  SELECT 1
  FROM sufioun_user_roles ur
  WHERE ur.user_id = u.user_id
);

-- Optional second role grants to satisfy multi-role support for managers.
INSERT INTO sufioun_user_roles (user_id, role_id, is_default, status)
SELECT u.user_id, 'ROL-004', 0, 1
FROM sufioun_com_users u
WHERE u.role = 'manager'
  AND NOT EXISTS (
    SELECT 1
    FROM sufioun_user_roles ur
    WHERE ur.user_id = u.user_id
      AND ur.role_id = 'ROL-004'
  );

INSERT INTO sufioun_user_roles (user_id, role_id, is_default, status)
SELECT u.user_id, 'ROL-006', 0, 1
FROM sufioun_com_users u
WHERE u.role IN ('manager', 'user')
  AND NOT EXISTS (
    SELECT 1
    FROM sufioun_user_roles ur
    WHERE ur.user_id = u.user_id
      AND ur.role_id = 'ROL-006'
  );

COMMIT;
