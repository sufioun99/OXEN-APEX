-- 003_security_context_package.sql
-- Session role and authorization helper package for Oracle APEX.

CREATE OR REPLACE PACKAGE sufioun_app_security AS
  FUNCTION get_user_id_by_name(p_user_name IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION user_has_role(p_user_id IN VARCHAR2, p_role_code IN VARCHAR2) RETURN NUMBER;
  FUNCTION can_view_sales(p_sales_by IN VARCHAR2, p_customer_id IN VARCHAR2, p_emp_id IN VARCHAR2, p_cust_id IN VARCHAR2, p_active_role IN VARCHAR2) RETURN NUMBER;
  FUNCTION can_view_service(p_service_by IN VARCHAR2, p_customer_id IN VARCHAR2, p_emp_id IN VARCHAR2, p_cust_id IN VARCHAR2, p_active_role IN VARCHAR2) RETURN NUMBER;
END sufioun_app_security;
/

CREATE OR REPLACE PACKAGE BODY sufioun_app_security AS

  FUNCTION get_user_id_by_name(p_user_name IN VARCHAR2) RETURN VARCHAR2 IS
    v_user_id sufioun_com_users.user_id%TYPE;
  BEGIN
    SELECT user_id
    INTO v_user_id
    FROM sufioun_com_users
    WHERE UPPER(user_name) = UPPER(p_user_name)
      AND status = 1;
    RETURN v_user_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;

  FUNCTION user_has_role(p_user_id IN VARCHAR2, p_role_code IN VARCHAR2) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM sufioun_user_roles ur
    JOIN sufioun_app_roles ar ON ar.role_id = ur.role_id
    WHERE ur.user_id = p_user_id
      AND ur.status = 1
      AND ar.status = 1
      AND ar.role_code = p_role_code;

    RETURN CASE WHEN v_count > 0 THEN 1 ELSE 0 END;
  END;

  FUNCTION can_view_sales(
    p_sales_by    IN VARCHAR2,
    p_customer_id IN VARCHAR2,
    p_emp_id      IN VARCHAR2,
    p_cust_id     IN VARCHAR2,
    p_active_role IN VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    IF p_active_role IN ('ADMIN','SALES_MANAGER') THEN
      RETURN 1;
    ELSIF p_active_role = 'SALES_REP' AND p_sales_by = p_emp_id THEN
      RETURN 1;
    ELSIF p_active_role = 'CUSTOMER' AND p_customer_id = p_cust_id THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

  FUNCTION can_view_service(
    p_service_by  IN VARCHAR2,
    p_customer_id IN VARCHAR2,
    p_emp_id      IN VARCHAR2,
    p_cust_id     IN VARCHAR2,
    p_active_role IN VARCHAR2
  ) RETURN NUMBER IS
  BEGIN
    IF p_active_role IN ('ADMIN','SERVICE_MANAGER') THEN
      RETURN 1;
    ELSIF p_active_role = 'TECHNICIAN' AND p_service_by = p_emp_id THEN
      RETURN 1;
    ELSIF p_active_role = 'CUSTOMER' AND p_customer_id = p_cust_id THEN
      RETURN 1;
    ELSE
      RETURN 0;
    END IF;
  END;

END sufioun_app_security;
/
