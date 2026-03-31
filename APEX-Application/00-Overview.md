
## Application Purpose and Scope
This Oracle APEX 24.1 Universal Theme application delivers an end-to-end Electronics Sales and Services system using the provided SUFIOUN schema as the core source, with approved schema extensions for:
1. Multi-role users with session role switching.
2. OAuth identity mapping by email.
3. Customer receipts/payments.
4. Stock adjustment request-approve-post flow.
5. App settings and audit/error logging.

## Module Overview
1. Sales: dashboard, product browse, order entry, invoice print, receipts, returns, reporting.
2. Services: intake, queue/assignment, ticket detail, warranty tracking, service analytics.
3. Inventory: products/categories, stock dashboard, movement tracking, low stock, stock adjustments with approval.
4. CRM: customer master, customer 360 timeline, customer segmentation.
5. Admin/Setup: OAuth user mapping, role assignment, lookup/status setup, settings, audit/error logs.
6. Analytics: executive KPIs, report library, export-ready operational reports.

## Navigation / Sitemap by Module
1. Sales
   1. Page 110 Sales Dashboard
   2. Page 120 Product Catalog
   3. Page 130 Order Entry
   4. Page 140 Invoice Print Layout
   5. Page 150 Customer Receipts
   6. Page 160 Sales Returns
   7. Page 170 Sales Reports
2. Services
   1. Page 210 Service Intake
   2. Page 220 Ticket Queue and Assignment
   3. Page 230 Ticket Detail (Labor, Parts, Notes)
   4. Page 240 Warranty Tracker
   5. Page 250 Service Analytics
3. Inventory
   1. Page 310 Product Master
   2. Page 320 Categories and Departments
   3. Page 330 Stock on Hand Dashboard
   4. Page 340 Inventory Movements
   5. Page 350 Low Stock and Reorder
   6. Page 360 Stock Adjustment Request
   7. Page 370 Stock Adjustment Approve/Post
4. CRM
   1. Page 410 Customer Master
   2. Page 420 Customer 360 Timeline
   3. Page 430 CRM Segmentation
5. Admin/Setup
   1. Page 510 OAuth User Provisioning
   2. Page 520 Role Assignment and Session Role Switch
   3. Page 530 Lookup and Status Setup
   4. Page 540 Settings
   5. Page 550 Audit and Error Logs
6. Analytics
   1. Page 610 Executive Dashboard
   2. Page 620 Report Library
   3. Page 630 Export Center

## Authentication Overview (OAuth2/OIDC Providers)
1. Authentication Scheme: Social Sign-In (APEX native), email as unique identity key.
2. Providers
   1. Google
      Authorization: https://accounts.google.com/o/oauth2/v2/auth
      Token: https://oauth2.googleapis.com/token
      UserInfo: https://openidconnect.googleapis.com/v1/userinfo
      JWKS: https://www.googleapis.com/oauth2/v3/certs
   2. Microsoft Entra ID
      Authorization: https://login.microsoftonline.com/common/oauth2/v2.0/authorize
      Token: https://login.microsoftonline.com/common/oauth2/v2.0/token
      UserInfo: https://graph.microsoft.com/oidc/userinfo
      JWKS: https://login.microsoftonline.com/common/discovery/v2.0/keys
   3. Facebook
      Authorization: https://www.facebook.com/v18.0/dialog/oauth
      Token: https://graph.facebook.com/v18.0/oauth/access_token
      UserInfo: https://graph.facebook.com/me?fields=id,name,email
3. Post-auth mapping flow
   1. Extract provider, subject, email from OAuth claims.
   2. Resolve or create row in sufioun_oauth_identities.
   3. Resolve user in sufioun_com_users by email mapping.
   4. Set APEX app items:
      G_USER_ID
      G_EMPLOYEE_ID
      G_CUSTOMER_ID
      G_ACTIVE_ROLE
      G_IS_CUSTOMER
   5. Redirect to role-aware home page.

## Role Model and Authorization Strategy
1. Multi-role supported via sufioun_user_roles.
2. Session role switching via page 520 selector; active role stored in G_ACTIVE_ROLE.
3. Authorization scheme pattern
   1. Is Admin
   2. Is Sales Role (SALES_MANAGER or SALES_REP)
   3. Is Service Role (SERVICE_MANAGER or TECHNICIAN)
   4. Is Inventory Role (INVENTORY_MANAGER or STOREKEEPER)
   5. Is CRM Role (CRM_AGENT)
   6. Is Customer (CUSTOMER)
4. Row-level security rules implemented in SQL predicates
   1. Sales Rep sees rows where sales_by = :G_EMPLOYEE_ID.
   2. Technician sees service rows where service_by = :G_EMPLOYEE_ID.
   3. Inventory Manager unrestricted for stock.
   4. Customer sees own rows where customer_id = :G_CUSTOMER_ID.
5. Stock adjustment approval policy
   1. REQUESTED by storekeeper/inventory role.
   2. APPROVED by inventory manager.
   3. POSTED updates stock quantities.
   4. REJECTED optional final state.

## Naming Conventions
1. Pages: Functional prefixes by module range.
2. Items: PNNN_ITEM_NAME.
3. Regions: RGN_<business purpose>.
4. Processes: PRC_<table>_<action>.
5. Dynamic Actions: DA_<event>_<result>.
6. Computations: CMP_<derived value>.
7. Validations: VAL_<business rule>.

## Reusable UI Patterns
1. Storefront header: logo + global search + role badge + notification + cart placeholder.
2. Left departments menu: category/subcategory accordion.
3. Product cards grid: image, name, price, stock badge, actions.
4. Smart reports: faceted search + IR/IG hybrid.
5. Form + details master-detail pages for all transactional flows.

## Global Styling Plan
1. Theme Roller for tokens
   1. Primary: #0A2540
   2. Accent: #00A3A3
   3. Highlight: #FFB703
   4. Surface: #F5F7FA
2. Static Application File for custom CSS:
   app-electro-ui.css
3. Place shared CSS at application level and page-level override CSS only where needed.

## Global CSS (Static Application File: app-electro-ui.css)
```css
:root{
  --app-primary:#0A2540;
  --app-accent:#00A3A3;
  --app-highlight:#FFB703;
  --app-bg:#F5F7FA;
  --app-card:#FFFFFF;
  --app-text:#1F2937;
  --app-muted:#6B7280;
  --app-danger:#C62828;
  --app-radius:14px;
}
body.t-PageBody{background:linear-gradient(180deg,#f8fbff 0%,#eef4f8 100%);} 
.app-header{
  display:grid;grid-template-columns:220px 1fr 240px;gap:14px;align-items:center;
  background:var(--app-primary);padding:10px 16px;border-radius:0 0 14px 14px;color:#fff;
  box-shadow:0 8px 20px rgba(10,37,64,.22);
}
.app-search input{border-radius:30px;border:none;padding:10px 16px;width:100%;}
.app-header-icons{display:flex;justify-content:flex-end;gap:10px}
.app-badge{background:var(--app-highlight);color:#111;padding:4px 10px;border-radius:999px;font-weight:700}
.dept-nav{
  background:#fff;border-radius:var(--app-radius);padding:12px;
  box-shadow:0 3px 12px rgba(0,0,0,.07)
}
.dept-nav .a-TreeView-label{font-weight:600;color:var(--app-text)}
.product-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:14px}
.product-card{
  background:var(--app-card);border-radius:var(--app-radius);overflow:hidden;
  box-shadow:0 4px 18px rgba(0,0,0,.08);transition:transform .2s ease, box-shadow .2s ease;
}
.product-card:hover{transform:translateY(-3px);box-shadow:0 10px 24px rgba(0,0,0,.14)}
.product-card .price{font-size:20px;font-weight:800;color:var(--app-primary)}
.stock-low{color:var(--app-danger);font-weight:700}
.stock-ok{color:#2e7d32;font-weight:700}
@media (max-width:1024px){
  .app-header{grid-template-columns:1fr;gap:8px}
}
@media (max-width:768px){
  .product-grid{grid-template-columns:repeat(auto-fill,minmax(170px,1fr))}
  .t-Body-content{padding:10px}
}
```

## Approved Schema Extensions (Run Before APEX Build)
```sql
CREATE TABLE sufioun_app_roles (
  role_id        VARCHAR2(50) PRIMARY KEY,
  role_code      VARCHAR2(50) UNIQUE NOT NULL,
  role_name      VARCHAR2(150) NOT NULL,
  status         NUMBER(1) DEFAULT 1 CHECK (status IN (0,1)),
  cre_by         VARCHAR2(100),
  cre_dt         DATE,
  upd_by         VARCHAR2(100),
  upd_dt         DATE
);

CREATE TABLE sufioun_user_roles (
  user_role_id   VARCHAR2(50) PRIMARY KEY,
  user_id        VARCHAR2(50) NOT NULL REFERENCES sufioun_com_users(user_id) ON DELETE CASCADE,
  role_id        VARCHAR2(50) NOT NULL REFERENCES sufioun_app_roles(role_id),
  is_default     NUMBER(1) DEFAULT 0 CHECK (is_default IN (0,1)),
  status         NUMBER(1) DEFAULT 1 CHECK (status IN (0,1)),
  cre_by         VARCHAR2(100),
  cre_dt         DATE,
  upd_by         VARCHAR2(100),
  upd_dt         DATE,
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
  email             VARCHAR2(200) UNIQUE
);

CREATE TABLE sufioun_customer_receipts (
  receipt_id        VARCHAR2(50) PRIMARY KEY,
  receipt_no        VARCHAR2(50) UNIQUE,
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
      WHEN NVL((SELECT SUM(r.amount) FROM sufioun_customer_receipts r WHERE r.invoice_id = m.invoice_id),0) <= 0 THEN 'PENDING'
      WHEN NVL((SELECT SUM(r.amount) FROM sufioun_customer_receipts r WHERE r.invoice_id = m.invoice_id),0) >= NVL(m.grand_total,0) THEN 'PAID'
      ELSE 'PARTIAL'
    END,
    m.upd_by = USER,
    m.upd_dt = SYSDATE
  WHERE m.invoice_id = v_invoice_id;
END;
/
```

