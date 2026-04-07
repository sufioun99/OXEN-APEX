-- 006_integrity_checks.sql
-- Post-deployment integrity checks for schema and seed data.
-- Includes orphan checks, duplicate checks, and role-default checks.

SET SERVEROUTPUT ON;

DECLARE
  v_count      NUMBER := 0;
  v_failures   NUMBER := 0;

  PROCEDURE report_check(p_label IN VARCHAR2, p_count IN NUMBER) IS
  BEGIN
    IF p_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('PASS: ' || p_label);
    ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL: ' || p_label || ' -> ' || p_count || ' issue(s)');
      v_failures := v_failures + 1;
    END IF;
  END;
BEGIN
  DBMS_OUTPUT.PUT_LINE('============================================================');
  DBMS_OUTPUT.PUT_LINE('SUFIOUN Integrity Checks');
  DBMS_OUTPUT.PUT_LINE('============================================================');

  -- One mother-company rule.
  SELECT COUNT(*) INTO v_count FROM sufioun_company WHERE status = 1;
  IF v_count = 1 THEN
    DBMS_OUTPUT.PUT_LINE('PASS: exactly one active mother company');
  ELSE
    DBMS_OUTPUT.PUT_LINE('FAIL: expected exactly one active mother company, found ' || v_count);
    v_failures := v_failures + 1;
  END IF;

  -- Branch normalization checks.
  SELECT COUNT(*)
  INTO v_count
  FROM sufioun_branches b
  LEFT JOIN sufioun_company c ON c.company_id = b.company_id
  WHERE c.company_id IS NULL;
  report_check('orphan branches (branch->company)', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM sufioun_departments d
  LEFT JOIN sufioun_branches b ON b.branch_id = d.branch_id
  WHERE b.branch_id IS NULL;
  report_check('orphan departments (department->branch)', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT company_id
    FROM sufioun_branches
    WHERE status = 1 AND is_hq = 1
    GROUP BY company_id
    HAVING COUNT(*) > 1
  );
  report_check('companies with multiple active HQ branches', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM sufioun_branches
  WHERE status = 1
    AND NVL(TRIM(branch_name), ' ') = ' ';
  report_check('active branches with blank branch_name', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT UPPER(branch_code) AS branch_code_norm
    FROM sufioun_branches
    GROUP BY UPPER(branch_code)
    HAVING COUNT(*) > 1
  );
  report_check('duplicate branch_code (case-insensitive)', v_count);

  -- Core orphan checks.
  SELECT COUNT(*)
  INTO v_count
  FROM sufioun_employees e
  LEFT JOIN sufioun_departments d ON d.department_id = e.department_id
  WHERE e.department_id IS NOT NULL
    AND d.department_id IS NULL;
  report_check('orphan employees (employee->department)', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM sufioun_com_users u
  LEFT JOIN sufioun_employees e ON e.employee_id = u.employee_id
  WHERE u.employee_id IS NOT NULL
    AND e.employee_id IS NULL;
  report_check('orphan users (user->employee)', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM sufioun_user_roles ur
  LEFT JOIN sufioun_com_users u ON u.user_id = ur.user_id
  WHERE u.user_id IS NULL;
  report_check('orphan user_roles (user_role->user)', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM sufioun_user_roles ur
  LEFT JOIN sufioun_app_roles ar ON ar.role_id = ur.role_id
  WHERE ar.role_id IS NULL;
  report_check('orphan user_roles (user_role->role)', v_count);

  -- Duplicate and role-default checks.
  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT user_id, role_id
    FROM sufioun_user_roles
    GROUP BY user_id, role_id
    HAVING COUNT(*) > 1
  );
  report_check('duplicate user-role mappings', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT user_id
    FROM sufioun_user_roles
    WHERE status = 1 AND is_default = 1
    GROUP BY user_id
    HAVING COUNT(*) > 1
  );
  report_check('users with multiple active default roles', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT ur.user_id
    FROM sufioun_user_roles ur
    WHERE ur.status = 1
    GROUP BY ur.user_id
    HAVING SUM(CASE WHEN ur.is_default = 1 THEN 1 ELSE 0 END) = 0
  );
  report_check('users with active roles but no default role', v_count);

  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT provider_code, provider_subject
    FROM sufioun_oauth_identities
    GROUP BY provider_code, provider_subject
    HAVING COUNT(*) > 1
  );
  report_check('duplicate oauth identities (provider_code, provider_subject)', v_count);

  DBMS_OUTPUT.PUT_LINE('------------------------------------------------------------');
  IF v_failures = 0 THEN
    DBMS_OUTPUT.PUT_LINE('INTEGRITY STATUS: PASS');
  ELSE
    DBMS_OUTPUT.PUT_LINE('INTEGRITY STATUS: FAIL (' || v_failures || ' failed check groups)');
    RAISE_APPLICATION_ERROR(-20091, 'Integrity checks failed. Review DBMS_OUTPUT details.');
  END IF;
  DBMS_OUTPUT.PUT_LINE('============================================================');
END;
/
