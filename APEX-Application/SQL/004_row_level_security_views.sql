-- 004_row_level_security_views.sql
-- Role-aware views to simplify APEX report SQL.
-- Assumes APEX application items:
--   G_ACTIVE_ROLE, G_EMPLOYEE_ID, G_CUSTOMER_ID

CREATE OR REPLACE VIEW sufioun_v_sales_secure AS
SELECT m.*
FROM sufioun_sales_master m
WHERE sufioun_app_security.can_view_sales(
        m.sales_by,
        m.customer_id,
        V('G_EMPLOYEE_ID'),
        V('G_CUSTOMER_ID'),
        V('G_ACTIVE_ROLE')
      ) = 1;
/

CREATE OR REPLACE VIEW sufioun_v_service_secure AS
SELECT s.*
FROM sufioun_service_master s
WHERE sufioun_app_security.can_view_service(
        s.service_by,
        s.customer_id,
        V('G_EMPLOYEE_ID'),
        V('G_CUSTOMER_ID'),
        V('G_ACTIVE_ROLE')
      ) = 1;
/

CREATE OR REPLACE VIEW sufioun_v_receipts_secure AS
SELECT r.*
FROM sufioun_customer_receipts r
WHERE (
  V('G_ACTIVE_ROLE') IN ('ADMIN','SALES_MANAGER')
  OR (V('G_ACTIVE_ROLE') = 'SALES_REP' AND EXISTS (
      SELECT 1
      FROM sufioun_sales_master m
      WHERE m.invoice_id = r.invoice_id
        AND m.sales_by = V('G_EMPLOYEE_ID')
  ))
  OR (V('G_ACTIVE_ROLE') = 'CUSTOMER' AND r.customer_id = V('G_CUSTOMER_ID'))
);
/

CREATE OR REPLACE VIEW sufioun_v_stock_secure AS
SELECT s.*
FROM sufioun_stock s
WHERE (
  V('G_ACTIVE_ROLE') IN ('ADMIN','INVENTORY_MANAGER','STOREKEEPER')
);
/
