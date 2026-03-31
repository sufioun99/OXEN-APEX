-- 005_oauth_post_auth_process.sql
-- Post-authentication process helper package for APEX social sign-in.
-- Identity key is email and users exist in sufioun_com_users.

CREATE OR REPLACE PACKAGE sufioun_auth_map AS
  PROCEDURE map_oauth_login(
    p_provider_code    IN VARCHAR2,
    p_provider_subject IN VARCHAR2,
    p_email            IN VARCHAR2
  );
END sufioun_auth_map;
/

CREATE OR REPLACE PACKAGE BODY sufioun_auth_map AS
  PROCEDURE map_oauth_login(
    p_provider_code    IN VARCHAR2,
    p_provider_subject IN VARCHAR2,
    p_email            IN VARCHAR2
  ) IS
    v_user_id        sufioun_com_users.user_id%TYPE;
    v_employee_id    sufioun_com_users.employee_id%TYPE;
    v_customer_id    sufioun_customers.customer_id%TYPE;
    v_default_role   sufioun_app_roles.role_code%TYPE;
    v_exists         NUMBER;
  BEGIN
    SELECT u.user_id, u.employee_id
    INTO v_user_id, v_employee_id
    FROM sufioun_com_users u
    WHERE UPPER(u.email) = UPPER(p_email)
      AND u.status = 1;

    BEGIN
      SELECT customer_id
      INTO v_customer_id
      FROM sufioun_customers
      WHERE UPPER(email) = UPPER(p_email)
        AND status = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_customer_id := NULL;
    END;

    SELECT COUNT(*)
    INTO v_exists
    FROM sufioun_oauth_identities
    WHERE provider_code = UPPER(p_provider_code)
      AND provider_subject = p_provider_subject;

    IF v_exists = 0 THEN
      INSERT INTO sufioun_oauth_identities (
        identity_id,
        user_id,
        provider_code,
        provider_subject,
        email,
        email_verified,
        last_login_dt,
        status,
        cre_by,
        cre_dt
      ) VALUES (
        'OID' || TO_CHAR(sufioun_oauth_seq.NEXTVAL),
        v_user_id,
        UPPER(p_provider_code),
        p_provider_subject,
        LOWER(p_email),
        'Y',
        SYSDATE,
        1,
        USER,
        SYSDATE
      );
    ELSE
      UPDATE sufioun_oauth_identities
      SET user_id = v_user_id,
          email = LOWER(p_email),
          last_login_dt = SYSDATE,
          upd_by = USER,
          upd_dt = SYSDATE
      WHERE provider_code = UPPER(p_provider_code)
        AND provider_subject = p_provider_subject;
    END IF;

    UPDATE sufioun_com_users
    SET last_login = SYSDATE,
        is_online = 1,
        upd_by = USER,
        upd_dt = SYSDATE
    WHERE user_id = v_user_id;

    SELECT ar.role_code
    INTO v_default_role
    FROM sufioun_user_roles ur
    JOIN sufioun_app_roles ar ON ar.role_id = ur.role_id
    WHERE ur.user_id = v_user_id
      AND ur.status = 1
      AND ar.status = 1
      AND ur.is_default = 1
      AND ROWNUM = 1;

    apex_util.set_session_state('G_USER_ID', v_user_id);
    apex_util.set_session_state('G_EMPLOYEE_ID', v_employee_id);
    apex_util.set_session_state('G_CUSTOMER_ID', v_customer_id);
    apex_util.set_session_state('G_ACTIVE_ROLE', v_default_role);
    apex_util.set_session_state('G_IS_CUSTOMER', CASE WHEN v_customer_id IS NULL THEN 'N' ELSE 'Y' END);

    INSERT INTO sufioun_audit_log (
      log_id, log_ts, module_name, action_name, user_id, role_code, entity_name, entity_id, severity, message
    ) VALUES (
      'LOG' || TO_CHAR(sufioun_audit_seq.NEXTVAL),
      SYSTIMESTAMP,
      'AUTH',
      'OAUTH_LOGIN',
      v_user_id,
      v_default_role,
      'OAUTH',
      p_provider_subject,
      'INFO',
      'OAuth login mapped by email'
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'No active application user found for email: ' || p_email);
  END map_oauth_login;
END sufioun_auth_map;
/

-- Example usage in APEX post-authentication procedure:
-- BEGIN
--   sufioun_auth_map.map_oauth_login(
--     p_provider_code    => :APEX$OAUTH_PROVIDER,
--     p_provider_subject => :APEX$OAUTH_SUB,
--     p_email            => :APEX$OAUTH_EMAIL
--   );
-- END;
-- /
