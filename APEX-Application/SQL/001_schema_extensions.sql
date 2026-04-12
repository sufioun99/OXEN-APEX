-- 001_schema_extensions.sql
-- Approved schema extensions for APEX 24.1 application requirements

CREATE TABLE sufioun_app_roles (
  role_id        VARCHAR2(50) PRIMARY KEY,
  role_code      VARCHAR2(50) UNIQUE NOT NULL,
  role_name      VARCHAR2(150) NOT NULL,
  status         NUMBER(1) DEFAULT 1 CHECK (status IN (0,1))
);

CREATE TABLE sufioun_user_roles (
  user_role_id   VARCHAR2(50) PRIMARY KEY,
  user_id        VARCHAR2(50) NOT NULL REFERENCES sufioun_com_users(user_id) ON DELETE CASCADE,
  role_id        VARCHAR2(50) NOT NULL REFERENCES sufioun_app_roles(role_id),
  is_default     NUMBER(1) DEFAULT 0 CHECK (is_default IN (0,1)),
  status         NUMBER(1) DEFAULT 1 CHECK (status IN (0,1)),
  CONSTRAINT sufioun_uk_user_role UNIQUE (user_id, role_id)
);

CREATE TABLE sufioun_oauth_identities (
  identity_id        VARCHAR2(50) PRIMARY KEY,
  user_id            VARCHAR2(50) NOT NULL REFERENCES sufioun_com_users(user_id) ON DELETE CASCADE,
  provider_code      VARCHAR2(30) NOT NULL CHECK (provider_code IN ('GOOGLE','MICROSOFT','FACEBOOK')),
  provider_subject   VARCHAR2(255) NOT NULL,
  email              VARCHAR2(200) NOT NULL,
  email_verified     CHAR(1) DEFAULT 'Y' CHECK (email_verified IN ('Y','N')),
  last_login_dt      DATE,
  status             NUMBER(1) DEFAULT 1 CHECK (status IN (0,1)),
  cre_by             VARCHAR2(100),
  cre_dt             DATE,
  upd_by             VARCHAR2(100),
  upd_dt             DATE,
  CONSTRAINT sufioun_uk_oauth_sub UNIQUE (provider_code, provider_subject)
);

ALTER TABLE sufioun_com_users ADD (
  email VARCHAR2(200) UNIQUE
);

CREATE TABLE sufioun_customer_receipts (
  receipt_id        VARCHAR2(50) PRIMARY KEY,
  receipt_date      DATE DEFAULT SYSDATE NOT NULL,
  invoice_id        VARCHAR2(50) NOT NULL REFERENCES sufioun_sales_master(invoice_id),
  customer_id       VARCHAR2(50) NOT NULL REFERENCES sufioun_customers(customer_id),
  amount            NUMBER(20,4) NOT NULL CHECK (amount > 0),
  payment_method    VARCHAR2(30) NOT NULL CHECK (payment_method IN ('CASH','ONLINE','BANK','CHEQUE')),
  reference_no      VARCHAR2(100),
  notes             VARCHAR2(1000),
  received_by       VARCHAR2(50) REFERENCES sufioun_employees(employee_id),
  status            NUMBER(1) DEFAULT 1 CHECK (status IN (0,1)),
  cre_by            VARCHAR2(100),
  cre_dt            DATE,
  upd_by            VARCHAR2(100),
  upd_dt            DATE
);

CREATE TABLE sufioun_stock_adjust_master (
  adjust_id         VARCHAR2(50) PRIMARY KEY,
  adjust_no         VARCHAR2(50) UNIQUE,
  request_date      DATE DEFAULT SYSDATE,
  requested_by      VARCHAR2(50) REFERENCES sufioun_employees(employee_id),
  reason            VARCHAR2(1000),
  adjust_status     VARCHAR2(20) DEFAULT 'REQUESTED'
                    CHECK (adjust_status IN ('REQUESTED','APPROVED','POSTED','REJECTED')),
  approved_by       VARCHAR2(50) REFERENCES sufioun_employees(employee_id),
  approved_date     DATE,
  posted_date       DATE,
  status            NUMBER(1) DEFAULT 1 CHECK (status IN (0,1)),
  cre_by            VARCHAR2(100),
  cre_dt            DATE,
  upd_by            VARCHAR2(100),
  upd_dt            DATE
);

CREATE TABLE sufioun_stock_adjust_detail (
  adjust_det_id     VARCHAR2(50) PRIMARY KEY,
  adjust_id         VARCHAR2(50) NOT NULL REFERENCES sufioun_stock_adjust_master(adjust_id) ON DELETE CASCADE,
  product_id        VARCHAR2(50) NOT NULL REFERENCES sufioun_products(product_id),
  current_qty       NUMBER(10),
  adjust_qty        NUMBER(10) NOT NULL,
  line_note         VARCHAR2(500)
);

CREATE TABLE sufioun_app_settings (
  setting_key       VARCHAR2(100) PRIMARY KEY,
  setting_value     VARCHAR2(4000),
  setting_group     VARCHAR2(100),
  status            NUMBER(1) DEFAULT 1 CHECK (status IN (0,1)),
  upd_by            VARCHAR2(100),
  upd_dt            DATE
);

CREATE TABLE sufioun_audit_log (
  log_id            VARCHAR2(50) PRIMARY KEY,
  log_ts            TIMESTAMP DEFAULT SYSTIMESTAMP,
  module_name       VARCHAR2(100),
  action_name       VARCHAR2(100),
  user_id           VARCHAR2(50),
  role_code         VARCHAR2(50),
  entity_name       VARCHAR2(100),
  entity_id         VARCHAR2(100),
  severity          VARCHAR2(20) CHECK (severity IN ('INFO','WARN','ERROR')),
  message           VARCHAR2(4000)
);

CREATE INDEX idx_usr_roles_user ON sufioun_user_roles(user_id);
CREATE INDEX idx_usr_roles_role ON sufioun_user_roles(role_id);
CREATE INDEX idx_oauth_email ON sufioun_oauth_identities(email);
CREATE INDEX idx_receipts_invoice ON sufioun_customer_receipts(invoice_id);
CREATE INDEX idx_receipts_customer ON sufioun_customer_receipts(customer_id);
CREATE INDEX idx_stock_adj_status ON sufioun_stock_adjust_master(adjust_status);
CREATE INDEX idx_audit_ts ON sufioun_audit_log(log_ts);

CREATE SEQUENCE sufioun_oauth_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE sufioun_user_role_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE sufioun_receipt_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE sufioun_stock_adj_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE sufioun_stock_adj_det_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE sufioun_audit_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

CREATE OR REPLACE TRIGGER sufioun_trg_oauth_bi
BEFORE INSERT OR UPDATE ON sufioun_oauth_identities
FOR EACH ROW
BEGIN
  IF INSERTING AND :NEW.identity_id IS NULL THEN
    :NEW.identity_id := 'OID' || TO_CHAR(sufioun_oauth_seq.NEXTVAL);
  END IF;
  IF INSERTING THEN
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
  ELSE
    :NEW.upd_by := USER;
    :NEW.upd_dt := SYSDATE;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER sufioun_trg_user_roles_bi
BEFORE INSERT OR UPDATE ON sufioun_user_roles
FOR EACH ROW
BEGIN
  IF INSERTING AND :NEW.user_role_id IS NULL THEN
    :NEW.user_role_id := 'URL' || TO_CHAR(sufioun_user_role_seq.NEXTVAL);
  END IF;
END;
/

CREATE OR REPLACE TRIGGER sufioun_trg_receipt_bi
BEFORE INSERT OR UPDATE ON sufioun_customer_receipts
FOR EACH ROW
BEGIN
  IF INSERTING AND :NEW.receipt_id IS NULL THEN
    :NEW.receipt_id := 'RCT' || TO_CHAR(sufioun_receipt_seq.NEXTVAL);
  END IF;
  IF INSERTING THEN
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
  ELSE
    :NEW.upd_by := USER;
    :NEW.upd_dt := SYSDATE;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER sufioun_trg_stock_adj_master_bi
BEFORE INSERT OR UPDATE ON sufioun_stock_adjust_master
FOR EACH ROW
BEGIN
  IF INSERTING AND :NEW.adjust_id IS NULL THEN
    :NEW.adjust_id := 'SAM' || TO_CHAR(sufioun_stock_adj_seq.NEXTVAL);
  END IF;
  IF INSERTING AND :NEW.adjust_no IS NULL THEN
    :NEW.adjust_no := 'ADJ-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || LPAD(sufioun_stock_adj_seq.CURRVAL, 6, '0');
  END IF;
  IF INSERTING THEN
    IF :NEW.cre_by IS NULL THEN :NEW.cre_by := USER; END IF;
    IF :NEW.cre_dt IS NULL THEN :NEW.cre_dt := SYSDATE; END IF;
  ELSE
    :NEW.upd_by := USER;
    :NEW.upd_dt := SYSDATE;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER sufioun_trg_stock_adj_detail_bi
BEFORE INSERT ON sufioun_stock_adjust_detail
FOR EACH ROW
BEGIN
  IF INSERTING AND :NEW.adjust_det_id IS NULL THEN
    :NEW.adjust_det_id := 'SAD' || TO_CHAR(sufioun_stock_adj_det_seq.NEXTVAL);
  END IF;
END;
/

CREATE OR REPLACE TRIGGER sufioun_trg_sales_receipt_sync
AFTER INSERT OR UPDATE OR DELETE ON sufioun_customer_receipts
FOR EACH ROW
DECLARE
  v_invoice_id sufioun_sales_master.invoice_id%TYPE;
BEGIN
  v_invoice_id := NVL(:NEW.invoice_id, :OLD.invoice_id);

  UPDATE sufioun_sales_master m
  SET m.payment_status =
      CASE
        WHEN NVL((SELECT SUM(r.amount)
                  FROM sufioun_customer_receipts r
                  WHERE r.invoice_id = m.invoice_id), 0) <= 0
        THEN 'PENDING'
        WHEN NVL((SELECT SUM(r.amount)
                  FROM sufioun_customer_receipts r
                  WHERE r.invoice_id = m.invoice_id), 0) >= NVL(m.grand_total, 0)
        THEN 'PAID'
        ELSE 'PARTIAL'
      END,
      m.upd_by = USER,
      m.upd_dt = SYSDATE
  WHERE m.invoice_id = v_invoice_id;
END;
/
