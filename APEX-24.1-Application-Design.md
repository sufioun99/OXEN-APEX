# 00-Overview.md

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

# 01-Module-Sales/Module-Sales-Index.md

## Page List
1. Page 110 Sales Dashboard
2. Page 120 Product Catalog
3. Page 130 Order Entry
4. Page 140 Invoice Print Layout
5. Page 150 Customer Receipts
6. Page 160 Sales Returns
7. Page 170 Sales Reports

## Key Workflows
1. Sales rep opens dashboard, reviews KPIs.
2. Rep browses products and starts order.
3. Order header + lines saved; stock auto-updated by triggers.
4. Invoice printed via declarative report.
5. Payments received via receipts page; payment status auto-syncs.
6. Returns recorded with stock and financial effect.
7. Reports consumed by role and date filters.

# 01-Module-Sales/Page-110-Sales-Dashboard.md

## 1) Page Summary
Proposed Page ID: 110
Page Name: Sales Dashboard
Module: Sales
Purpose: Daily operational view of sales, invoice status, returns, and collections.
Intended roles and access rules:
1. SALES_MANAGER: all sales data.
2. SALES_REP: rows where sales_by = :G_EMPLOYEE_ID.
3. CUSTOMER: own invoices only where customer_id = :G_CUSTOMER_ID.

## 2) UX / Layout (APEX Regions)
Page layout structure:
Header: KPI ribbon.
Left Sidebar: date range + employee/customer filters.
Body: KPI cards/charts/report.
Footer: quick actions.

Regions:
1. RGN_KPI_CARDS (Cards, Body)
2. RGN_DAILY_TREND (Chart, Body)
3. RGN_TOP_PRODUCTS (Chart, Body)
4. RGN_RECENT_INVOICES (Interactive Report, Body)

Items:
1. P110_FROM_DT (Date Picker, source: computation, session state: yes)
2. P110_TO_DT (Date Picker, source: computation, session state: yes)
3. P110_EMPLOYEE_ID (Popup LOV, source: null, session state: yes)

Buttons and branching:
1. BTN_APPLY (refresh current page)
2. BTN_NEW_ORDER (branch to Page 130)

Dynamic Actions:
1. Event: Change on P110_FROM_DT, P110_TO_DT
   Selection: Items
   Actions: Refresh RGN_KPI_CARDS, RGN_DAILY_TREND, RGN_TOP_PRODUCTS, RGN_RECENT_INVOICES

## 3) SQL (Build-Ready)
Main KPI SQL
```sql
SELECT
  COUNT(*) invoice_count,
  NVL(SUM(grand_total),0) total_sales,
  NVL(SUM(CASE WHEN payment_status='PAID' THEN grand_total ELSE 0 END),0) paid_sales,
  NVL(SUM(CASE WHEN payment_status IN ('PENDING','PARTIAL') THEN grand_total ELSE 0 END),0) outstanding
FROM sufioun_sales_master m
WHERE m.invoice_date BETWEEN :P110_FROM_DT AND :P110_TO_DT
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  );
```

Charts SQL
```sql
SELECT TRUNC(invoice_date) sales_day,
       SUM(grand_total) amount
FROM sufioun_sales_master m
WHERE m.invoice_date BETWEEN :P110_FROM_DT AND :P110_TO_DT
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  )
GROUP BY TRUNC(invoice_date)
ORDER BY sales_day;
```

```sql
SELECT p.product_name,
       SUM(d.quantity) qty,
       SUM(d.mrp*d.quantity) gross_amount
FROM sufioun_sales_details d
JOIN sufioun_sales_master m ON m.invoice_id = d.invoice_id
JOIN sufioun_products p ON p.product_id = d.product_id
WHERE m.invoice_date BETWEEN :P110_FROM_DT AND :P110_TO_DT
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  )
GROUP BY p.product_name
ORDER BY qty DESC FETCH FIRST 10 ROWS ONLY;
```

LOV SQL
```sql
SELECT first_name||' '||last_name display_value, employee_id return_value
FROM sufioun_employees
WHERE status = 1
ORDER BY 1;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.sales-kpi-grid{display:grid;grid-template-columns:repeat(4,minmax(180px,1fr));gap:12px}
.sales-kpi{background:#fff;border-left:4px solid var(--app-accent);padding:14px;border-radius:12px}
@media (max-width:768px){.sales-kpi-grid{grid-template-columns:1fr 1fr}}
```

## 6) Validations, Computations, and Processes
1. Validation: P110_FROM_DT <= P110_TO_DT.
2. Computation/defaults: P110_FROM_DT = TRUNC(SYSDATE)-30, P110_TO_DT = TRUNC(SYSDATE).
3. Processes: none.
4. Messaging: inline notification for invalid date range.

## 7) Report/Chart Definitions
1. Recent invoices columns: invoice_no, invoice_date, customer_name, grand_total, payment_status badge.
2. Status badges: PAID green, PARTIAL amber, PENDING red.

## 8) Acceptance Criteria
1. Role-based row filtering works per active role.
2. KPI totals match invoice records.
3. Charts refresh with date filters.

# 01-Module-Sales/Page-120-Product-Catalog.md

## 1) Page Summary
Proposed Page ID: 120
Page Name: Product Catalog
Module: Sales
Purpose/user story: browse active products with facets and storefront cards.
Intended roles and access rules:
1. Sales roles: all active products.
2. Customer: all active products.

## 2) UX / Layout (APEX Regions)
Page layout structure:
Header: global search.
Left Sidebar: departments/categories.
Body: faceted region + cards.
Footer: hidden.

Regions:
1. RGN_DEPARTMENTS (Tree, Left Sidebar)
2. RGN_FACETS (Faceted Search, Body)
3. RGN_PRODUCT_CARDS (Cards, Body)

Items:
1. P120_SEARCH (Text Field, source null, session state yes)
2. P120_CATEGORY_ID (Select List, source null, session state yes)
3. P120_SUB_CAT_ID (Select List, source null, session state yes)

Buttons and branching:
1. BTN_ADD_TO_CART_PLACEHOLDER (no branch)

Dynamic Actions:
1. Change P120_SEARCH/P120_CATEGORY_ID/P120_SUB_CAT_ID -> Refresh RGN_PRODUCT_CARDS

## 3) SQL (Build-Ready)
Main cards query
```sql
SELECT p.product_id,
       p.product_name,
       p.selling_price,
       p.mrp,
       c.product_cat_name,
       s.sub_cat_name,
       CASE WHEN NVL(st.quantity,0) <= p.min_stock_level THEN 'LOW' ELSE 'OK' END stock_flag,
       apex_util.get_blob_file_src('P120_IMG', p.product_id) img_url
FROM sufioun_products p
LEFT JOIN sufioun_product_categories c ON c.product_cat_id = p.category_id
LEFT JOIN sufioun_sub_categories s ON s.sub_cat_id = p.sub_cat_id
LEFT JOIN sufioun_stock st ON st.product_id = p.product_id
WHERE p.status = 1
  AND (:P120_SEARCH IS NULL OR UPPER(p.product_name) LIKE '%'||UPPER(:P120_SEARCH)||'%')
  AND (:P120_CATEGORY_ID IS NULL OR p.category_id = :P120_CATEGORY_ID)
  AND (:P120_SUB_CAT_ID IS NULL OR p.sub_cat_id = :P120_SUB_CAT_ID);
```

Faceted dataset
```sql
SELECT p.product_id,
       p.product_name,
       c.product_cat_name category_name,
       s.sub_cat_name sub_category_name,
       b.brand_name,
       p.selling_price,
       NVL(st.quantity,0) stock_qty
FROM sufioun_products p
LEFT JOIN sufioun_product_categories c ON c.product_cat_id = p.category_id
LEFT JOIN sufioun_sub_categories s ON s.sub_cat_id = p.sub_cat_id
LEFT JOIN sufioun_brand b ON b.brand_id = p.brand_id
LEFT JOIN sufioun_stock st ON st.product_id = p.product_id
WHERE p.status = 1;
```

LOV SQL
```sql
SELECT product_cat_name display_value, product_cat_id return_value
FROM sufioun_product_categories
WHERE status = 1
ORDER BY sort_order, product_cat_name;
```

## 4) HTML (only if required)
```html
<div class="product-actions">
  <button class="t-Button t-Button--hot">View</button>
  <button class="t-Button">Add</button>
</div>
```

## 5) CSS (REQUIRED)
```css
.product-actions{display:flex;gap:8px;padding:10px}
.product-title{font-weight:700;min-height:42px}
.product-price{color:var(--app-primary);font-size:18px;font-weight:800}
```

## 6) Validations, Computations, and Processes
1. Computation: no default category.
2. Process: none.

## 7) Report/Chart Definitions
Product cards with image, title, category, price, stock badge.

## 8) Acceptance Criteria
1. Search/filter returns expected products.
2. Low-stock badge appears by min_stock_level.
3. Mobile layout is readable.

# 01-Module-Sales/Page-130-Order-Entry.md

## 1) Page Summary
Proposed Page ID: 130
Page Name: Order Entry
Module: Sales
Purpose/user story: create and edit sales invoice (header + lines).
Intended roles and access rules:
1. SALES_MANAGER unrestricted.
2. SALES_REP own invoices.

## 2) UX / Layout (APEX Regions)
Page layout structure:
Header: invoice metadata.
Left Sidebar: customer/pricing inputs.
Body: header form + lines IG + totals.
Footer: action buttons.

Regions:
1. RGN_INVOICE_HEADER (Form, Body)
2. RGN_INVOICE_LINES (Editable IG, Body)
3. RGN_TOTALS (Display, Right)

Items:
1. P130_INVOICE_ID (Hidden, PK)
2. P130_CUSTOMER_ID (Popup LOV)
3. P130_DISCOUNT (Number)
4. P130_VAT (Number)
5. P130_ADJUST_AMOUNT (Number)
6. P130_SALES_BY (Hidden, default :G_EMPLOYEE_ID)

Buttons and branching:
1. BTN_CREATE
2. BTN_SAVE
3. BTN_ADD_LINE
4. BTN_DELETE
5. BTN_PRINT -> branch Page 140 with P140_INVOICE_ID

Dynamic Actions:
1. IG save success -> refresh totals region.

## 3) SQL (Build-Ready)
Header query
```sql
SELECT invoice_id, invoice_date, invoice_no, discount, vat, adjust_ref,
       total_amount, adjust_amount, grand_total, customer_id, sales_by,
       payment_status, notes, status
FROM sufioun_sales_master
WHERE invoice_id = :P130_INVOICE_ID;
```

Lines query
```sql
SELECT sales_det_id, invoice_id, product_id, mrp, purchase_price,
       discount_amount, quantity, line_total, description
FROM sufioun_sales_details
WHERE invoice_id = :P130_INVOICE_ID;
```

LOV SQL
```sql
SELECT product_name||' ('||product_id||')' display_value, product_id return_value
FROM sufioun_products
WHERE status = 1
ORDER BY product_name;
```

```sql
SELECT customer_name||' - '||phone_no display_value, customer_id return_value
FROM sufioun_customers
WHERE status = 1
ORDER BY customer_name;
```

Validation SQL
```sql
SELECT CASE
  WHEN NVL((SELECT quantity FROM sufioun_stock WHERE product_id = :PRODUCT_ID),0) >= :QUANTITY
  THEN 1 ELSE 0 END ok_flag
FROM dual;
```

Processes (DML)
1. APEX Form DML on sufioun_sales_master.
2. IG Automatic Row Processing on sufioun_sales_details.
3. Trigger sufioun_trg_sales_detail_sync recalculates totals.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.invoice-panel{background:#fff;border-radius:12px;padding:14px}
.totals-box{background:#0A2540;color:#fff;border-radius:12px;padding:14px}
```

## 6) Validations, Computations, and Processes
1. Customer required.
2. Quantity > 0.
3. Optional uniqueness validation (product per invoice line).
4. Computation: P130_SALES_BY = :G_EMPLOYEE_ID when create.
5. Error handling: inline notifications and IG row errors.

## 7) Report/Chart Definitions
IG columns: product LOV, mrp, quantity, discount_amount, line_total (read only).

## 8) Acceptance Criteria
1. Invoice and lines save successfully.
2. Grand total auto-updates.
3. Stock decreases on line insert/update.

# 01-Module-Sales/Page-140-Invoice-Print-Layout.md

## 1) Page Summary
Proposed Page ID: 140
Page Name: Invoice Print Layout
Module: Sales
Purpose/user story: declarative printable invoice page.
Intended roles and access rules:
1. Sales roles with own/all filter.
2. Customer own invoice only.

## 2) UX / Layout (APEX Regions)
Body:
1. RGN_INVOICE_HEADER_STATIC (SQL report single-row)
2. RGN_INVOICE_LINES_PRINT (Classic report)
3. RGN_TERMS (Static content)
Buttons: Print, Back.

## 3) SQL (Build-Ready)
Header
```sql
SELECT m.invoice_no, m.invoice_date, c.customer_name, c.phone_no, c.address,
       e.first_name||' '||e.last_name sales_person,
       m.total_amount, m.discount, m.adjust_amount, m.vat, m.grand_total, m.payment_status
FROM sufioun_sales_master m
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
LEFT JOIN sufioun_employees e ON e.employee_id = m.sales_by
WHERE m.invoice_id = :P140_INVOICE_ID
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE = 'CUSTOMER' AND m.customer_id = :G_CUSTOMER_ID)
  );
```

Lines
```sql
SELECT p.product_name, d.quantity, d.mrp, d.discount_amount, d.line_total
FROM sufioun_sales_details d
JOIN sufioun_products p ON p.product_id = d.product_id
WHERE d.invoice_id = :P140_INVOICE_ID
ORDER BY p.product_name;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
@media print{
  .t-Header,.t-Body-nav,.t-Footer{display:none !important}
  .t-Body-content{margin:0;padding:0}
}
```

## 6) Validations, Computations, and Processes
Validation: invoice exists and user authorized.

## 7) Report/Chart Definitions
Classic report totals in footer.

## 8) Acceptance Criteria
1. Print button generates clean printable layout.
2. Unauthorized user cannot print restricted invoice.

# 01-Module-Sales/Page-150-Customer-Receipts.md

## 1) Page Summary
Proposed Page ID: 150
Page Name: Customer Receipts
Module: Sales
Purpose/user story: capture customer receipts against invoices.
Intended roles and access rules:
1. SALES_MANAGER, SALES_REP create/update.
2. CUSTOMER read-only own receipts.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_RECEIPT_FORM (Form)
2. RGN_RECEIPT_HISTORY (IR)
Items: P150_RECEIPT_ID, P150_INVOICE_ID, P150_CUSTOMER_ID, P150_AMOUNT, P150_PAYMENT_METHOD, P150_REFERENCE_NO.
Buttons: Create Receipt, Save, New.
Dynamic Actions: Invoice change fetches due amount.

## 3) SQL (Build-Ready)
Form source
```sql
SELECT receipt_id, receipt_date, invoice_id, customer_id, amount,
       payment_method, reference_no, notes, received_by, status
FROM sufioun_customer_receipts
WHERE receipt_id = :P150_RECEIPT_ID;
```

Invoice LOV
```sql
SELECT m.invoice_no||' | Due: '||
       TO_CHAR(m.grand_total - NVL((SELECT SUM(r.amount) FROM sufioun_customer_receipts r WHERE r.invoice_id=m.invoice_id),0)) display_value,
       m.invoice_id return_value
FROM sufioun_sales_master m
WHERE m.status = 1
  AND m.payment_status IN ('PENDING','PARTIAL')
  AND (
    :G_ACTIVE_ROLE = 'SALES_MANAGER'
    OR (:G_ACTIVE_ROLE = 'SALES_REP' AND m.sales_by = :G_EMPLOYEE_ID)
  )
ORDER BY m.invoice_date DESC;
```

History
```sql
SELECT r.receipt_id, r.receipt_date, c.customer_name, m.invoice_no,
       r.amount, r.payment_method, r.reference_no
FROM sufioun_customer_receipts r
JOIN sufioun_sales_master m ON m.invoice_id = r.invoice_id
JOIN sufioun_customers c ON c.customer_id = r.customer_id
WHERE (
  :G_ACTIVE_ROLE IN ('SALES_MANAGER','SALES_REP')
  OR (:G_ACTIVE_ROLE='CUSTOMER' AND r.customer_id = :G_CUSTOMER_ID)
)
ORDER BY r.receipt_date DESC;
```

Validation
```sql
SELECT CASE WHEN :P150_AMOUNT <=
  (SELECT m.grand_total - NVL((SELECT SUM(r.amount) FROM sufioun_customer_receipts r WHERE r.invoice_id=m.invoice_id AND r.receipt_id <> :P150_RECEIPT_ID),0)
   FROM sufioun_sales_master m WHERE m.invoice_id = :P150_INVOICE_ID)
THEN 1 ELSE 0 END ok_flag
FROM dual;
```

Processes
1. APEX Form DML on sufioun_customer_receipts.
2. Trigger sufioun_trg_sales_receipt_sync updates payment_status.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.receipt-strip{display:flex;gap:10px;flex-wrap:wrap}
.receipt-pill{background:#e6f7f7;border-radius:999px;padding:6px 10px}
```

## 6) Validations, Computations, and Processes
1. Amount positive.
2. Amount <= due.
3. received_by default :G_EMPLOYEE_ID.

## 7) Report/Chart Definitions
IR export enabled.

## 8) Acceptance Criteria
1. Receipts create/update correctly.
2. Invoice payment_status updates correctly.

# 01-Module-Sales/Page-160-Sales-Returns.md

## 1) Page Summary
Proposed Page ID: 160
Page Name: Sales Returns
Module: Sales
Purpose/user story: register sales returns and return lines.
Intended roles and access rules:
1. Sales roles create/edit.
2. Customer read-only own returns.

## 2) UX / Layout (APEX Regions)
Regions:
1. Return Header Form (sufioun_sales_return_master)
2. Return Lines IG (sufioun_sales_return_details)
3. Linked Invoice Lines IR
Items: P160_SALES_RETURN_ID, P160_INVOICE_ID, P160_CUSTOMER_ID, P160_REASON.
Buttons: Save, Add Line, Complete Return.

## 3) SQL (Build-Ready)
Header
```sql
SELECT sales_return_id, invoice_id, customer_id, return_date, return_no,
       total_amount, reason, approved_by, status
FROM sufioun_sales_return_master
WHERE sales_return_id = :P160_SALES_RETURN_ID;
```

Lines
```sql
SELECT sales_return_det_id, sales_return_id, product_id, mrp, purchase_price,
       quantity, discount_amount, item_total, qty_return, reason
FROM sufioun_sales_return_details
WHERE sales_return_id = :P160_SALES_RETURN_ID;
```

Invoice lines reference
```sql
SELECT d.product_id, p.product_name, d.quantity sold_qty, d.mrp, d.discount_amount
FROM sufioun_sales_details d
JOIN sufioun_products p ON p.product_id = d.product_id
WHERE d.invoice_id = :P160_INVOICE_ID;
```

Validation
```sql
SELECT CASE WHEN :QTY_RETURN <=
  (SELECT NVL(SUM(quantity),0) FROM sufioun_sales_details
   WHERE invoice_id = :P160_INVOICE_ID AND product_id = :PRODUCT_ID)
THEN 1 ELSE 0 END ok_flag
FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.return-alert{background:#fff4e5;border:1px solid #ffcc80;padding:10px;border-radius:10px}
```

## 6) Validations, Computations, and Processes
1. Invoice required.
2. qty_return > 0 and <= sold qty.
3. Form + IG automatic row processing.

## 7) Report/Chart Definitions
IG with returned qty highlighting.

## 8) Acceptance Criteria
1. Return saved with detail rows.
2. Stock increases by qty_return.

# 01-Module-Sales/Page-170-Sales-Reports.md

## 1) Page Summary
Proposed Page ID: 170
Page Name: Sales Reports
Module: Sales
Purpose/user story: daily sales and dimensional analysis reports.
Intended roles and access rules:
1. SALES_MANAGER full data.
2. SALES_REP own data.
3. CUSTOMER own data.

## 2) UX / Layout (APEX Regions)
Regions:
1. Report tabs: Daily, Product, Category, Customer.
2. Export toolbar.
Items: P170_FROM_DT, P170_TO_DT.

## 3) SQL (Build-Ready)
Daily
```sql
SELECT TRUNC(m.invoice_date) sales_day,
       COUNT(*) invoice_count,
       SUM(m.grand_total) sales_amount
FROM sufioun_sales_master m
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY TRUNC(m.invoice_date)
ORDER BY sales_day;
```

By product
```sql
SELECT p.product_name, SUM(d.quantity) qty, SUM(d.mrp*d.quantity) gross
FROM sufioun_sales_details d
JOIN sufioun_sales_master m ON m.invoice_id=d.invoice_id
JOIN sufioun_products p ON p.product_id=d.product_id
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY p.product_name
ORDER BY gross DESC;
```

By category
```sql
SELECT c.product_cat_name, SUM(d.quantity) qty, SUM(d.mrp*d.quantity) gross
FROM sufioun_sales_details d
JOIN sufioun_sales_master m ON m.invoice_id=d.invoice_id
JOIN sufioun_products p ON p.product_id=d.product_id
LEFT JOIN sufioun_product_categories c ON c.product_cat_id=p.category_id
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY c.product_cat_name
ORDER BY gross DESC;
```

By customer
```sql
SELECT cu.customer_name, COUNT(DISTINCT m.invoice_id) invoices, SUM(m.grand_total) amount
FROM sufioun_sales_master m
JOIN sufioun_customers cu ON cu.customer_id = m.customer_id
WHERE m.invoice_date BETWEEN :P170_FROM_DT AND :P170_TO_DT
  AND (
    :G_ACTIVE_ROLE='SALES_MANAGER'
    OR (:G_ACTIVE_ROLE='SALES_REP' AND m.sales_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
GROUP BY cu.customer_name
ORDER BY amount DESC;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.report-toolbar{display:flex;gap:10px;align-items:center;flex-wrap:wrap}
```

## 6) Validations, Computations, and Processes
1. from date <= to date.

## 7) Report/Chart Definitions
All report tabs as Interactive Reports with export enabled.

## 8) Acceptance Criteria
1. All four dimensions report correctly.
2. Exports work.

# 02-Module-Services/Module-Services-Index.md

## Page List
1. Page 210 Service Intake
2. Page 220 Ticket Queue and Assignment
3. Page 230 Ticket Detail
4. Page 240 Warranty Tracker
5. Page 250 Service Analytics

## Key Workflows
1. Intake captures request and problem details.
2. Queue assigns technician/manager priorities.
3. Ticket detail records parts and labor.
4. Warranty status auto-evaluated by trigger logic.
5. Service analytics tracks open vs closed, aging, MTTR.

# 02-Module-Services/Page-210-Service-Intake.md

## 1) Page Summary
Proposed Page ID: 210
Page Name: Service Intake
Module: Services
Purpose/user story: create and maintain service requests.
Intended roles and access rules:
1. SERVICE_MANAGER all rows.
2. TECHNICIAN own rows where service_by = :G_EMPLOYEE_ID.
3. CUSTOMER own rows where customer_id = :G_CUSTOMER_ID.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_SERVICE_FORM (Form)
2. RGN_IMAGE_UPLOAD (Before/After images)
Items: P210_SERVICE_ID, P210_CUSTOMER_ID, P210_INVOICE_ID, P210_PROBLEM_DESC, P210_SERVICE_STATUS.
Buttons: Save, Create Ticket, Go Detail.
DA: On invoice change refresh warranty_applicable display.

## 3) SQL (Build-Ready)
Form
```sql
SELECT service_id, service_no, service_date, customer_id, invoice_id, invoice_date,
       warranty_applicable, service_by, service_charge_total, total_price, vat, grand_total,
       service_status, problem_desc, resolution_desc, completed_date, status
FROM sufioun_service_master
WHERE service_id = :P210_SERVICE_ID
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND service_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
  );
```

Customer LOV
```sql
SELECT customer_name||' - '||phone_no display_value, customer_id return_value
FROM sufioun_customers
WHERE status=1
ORDER BY customer_name;
```

Invoice LOV
```sql
SELECT invoice_no||' - '||TO_CHAR(invoice_date,'YYYY-MM-DD') display_value, invoice_id return_value
FROM sufioun_sales_master
ORDER BY invoice_date DESC;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.svc-status{font-weight:700;padding:4px 10px;border-radius:999px;background:#e3f2fd}
```

## 6) Validations, Computations, and Processes
1. problem_desc required.
2. service_status constrained by table check values.
3. APEX Form DML on sufioun_service_master.

## 7) Report/Chart Definitions
N/A.

## 8) Acceptance Criteria
Ticket created with valid status and role-safe access.

# 02-Module-Services/Page-220-Ticket-Queue-and-Assignment.md

## 1) Page Summary
Proposed Page ID: 220
Page Name: Ticket Queue and Assignment
Module: Services
Purpose/user story: operational queue and assignment control.
Intended roles and access rules:
1. SERVICE_MANAGER all rows.
2. TECHNICIAN own rows.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_TICKET_QUEUE (IR)
2. RGN_ASSIGN_MODAL (Dialog)
Items: P220_STATUS, P220_TECH_ID.
Buttons: Assign, Mark In Progress, Mark Completed.

## 3) SQL (Build-Ready)
Queue
```sql
SELECT m.service_id, m.service_no, m.service_date, c.customer_name,
       m.service_status, m.warranty_applicable,
       e.first_name||' '||e.last_name technician,
       (TRUNC(SYSDATE)-TRUNC(m.service_date)) aging_days
FROM sufioun_service_master m
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
LEFT JOIN sufioun_employees e ON e.employee_id = m.service_by
WHERE (:P220_STATUS IS NULL OR m.service_status = :P220_STATUS)
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND m.service_by=:G_EMPLOYEE_ID)
  )
ORDER BY m.service_date DESC;
```

Technician LOV
```sql
SELECT first_name||' '||last_name display_value, employee_id return_value
FROM sufioun_employees
WHERE status=1
ORDER BY 1;
```

Assignment process
```sql
UPDATE sufioun_service_master
SET service_by = :P220_TECH_ID,
    upd_by = :APP_USER,
    upd_dt = SYSDATE
WHERE service_id = :P220_SERVICE_ID;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.aging-high{color:#b71c1c;font-weight:700}
```

## 6) Validations, Computations, and Processes
1. Assignment allowed only for SERVICE_MANAGER.
2. Validate legal status transitions.

## 7) Report/Chart Definitions
Status badges and aging conditional formatting.

## 8) Acceptance Criteria
Assignment updates technician and status workflow correctly.

# 02-Module-Services/Page-230-Ticket-Detail.md

## 1) Page Summary
Proposed Page ID: 230
Page Name: Ticket Detail
Module: Services
Purpose/user story: capture parts/labor/notes for service ticket.
Intended roles and access rules:
1. SERVICE_MANAGER all rows.
2. TECHNICIAN own rows.
3. CUSTOMER read-only own rows.

## 2) UX / Layout (APEX Regions)
Regions:
1. RGN_TICKET_SUMMARY
2. RGN_SERVICE_DETAILS_IG
3. RGN_RESOLUTION_NOTES
Items: P230_SERVICE_ID, P230_SERVICE_STATUS, P230_RESOLUTION_DESC.
Buttons: Save Detail, Close Ticket.

## 3) SQL (Build-Ready)
Summary
```sql
SELECT service_no, service_date, customer_id, service_status, problem_desc, resolution_desc
FROM sufioun_service_master
WHERE service_id = :P230_SERVICE_ID
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND service_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
  );
```

IG dataset
```sql
SELECT service_det_id, service_id, product_id, servicelist_id, parts_id,
       service_charge, parts_price, quantity, line_total, description, warranty_status
FROM sufioun_service_details
WHERE service_id = :P230_SERVICE_ID;
```

Service LOV
```sql
SELECT service_name||' ('||service_cost||')' display_value, servicelist_id return_value
FROM sufioun_service_list
WHERE status=1
ORDER BY service_name;
```

Parts LOV
```sql
SELECT parts_name display_value, parts_id return_value
FROM sufioun_parts
WHERE status=1
ORDER BY parts_name;
```

Validation
```sql
SELECT CASE WHEN :QUANTITY > 0 THEN 1 ELSE 0 END ok_flag FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.ticket-shell{background:#fff;border-radius:12px;padding:12px}
```

## 6) Validations, Computations, and Processes
1. IG Automatic Row Processing on sufioun_service_details.
2. Header update process for resolution and status.
3. Compute completed_date when status becomes COMPLETED.

## 7) Report/Chart Definitions
IG totals for service_charge/parts_price.

## 8) Acceptance Criteria
Ticket detail lines persist and roll into ticket totals.

# 02-Module-Services/Page-240-Warranty-Tracker.md

## 1) Page Summary
Proposed Page ID: 240
Page Name: Warranty Tracker
Module: Services
Purpose/user story: list tickets by warranty and status.
Intended roles and access rules:
1. Service roles as per RLS.
2. Customer own records only.

## 2) UX / Layout (APEX Regions)
Single IR with filters.

## 3) SQL (Build-Ready)
```sql
SELECT m.service_no, m.service_date, m.warranty_applicable,
       m.service_status, c.customer_name, m.invoice_id
FROM sufioun_service_master m
JOIN sufioun_customers c ON c.customer_id = m.customer_id
WHERE (:P240_WARRANTY IS NULL OR m.warranty_applicable = :P240_WARRANTY)
  AND (
    :G_ACTIVE_ROLE='SERVICE_MANAGER'
    OR (:G_ACTIVE_ROLE='TECHNICIAN' AND m.service_by=:G_EMPLOYEE_ID)
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND m.customer_id=:G_CUSTOMER_ID)
  )
ORDER BY m.service_date DESC;
```

LOV
```sql
SELECT 'Yes' display_value, 'Y' return_value FROM dual
UNION ALL
SELECT 'No','N' FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.warranty-yes{background:#e8f5e9;padding:4px 8px;border-radius:8px}
.warranty-no{background:#ffebee;padding:4px 8px;border-radius:8px}
```

## 6) Validations, Computations, and Processes
Query-only page.

## 7) Report/Chart Definitions
Warranty badge and link to page 230.

## 8) Acceptance Criteria
Warranty filter and ticket drill-in operate correctly.

# 02-Module-Services/Page-250-Service-Analytics.md

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

# 03-Module-Inventory/Module-Inventory-Index.md

## Page List
1. Page 310 Product Master
2. Page 320 Categories and Departments
3. Page 330 Stock On Hand Dashboard
4. Page 340 Inventory Movements
5. Page 350 Low Stock/Reorder
6. Page 360 Stock Adjustment Request
7. Page 370 Stock Adjustment Approve/Post

## Key Workflows
1. Product/category maintenance.
2. Stock monitoring and movement tracking.
3. Adjustment request submission.
4. Approval and posting by inventory manager.

# 03-Module-Inventory/Page-310-Product-Master.md

## 1) Page Summary
Proposed Page ID: 310
Page Name: Product Master
Module: Inventory
Purpose/user story: CRUD for sufioun_products.
Intended roles and access rules:
1. INVENTORY_MANAGER
2. STOREKEEPER

## 2) UX / Layout (APEX Regions)
Regions:
1. Product form region
2. Product list IR region
Items: product attributes and image upload fields.
Buttons: Create, Save, Delete.

## 3) SQL (Build-Ready)
Main report
```sql
SELECT product_id, product_code, product_name, category_id, sub_cat_id, brand_id,
       purchase_price, selling_price, min_stock_level, max_stock_level, status
FROM sufioun_products
ORDER BY product_name;
```

Category LOV
```sql
SELECT product_cat_name display_value, product_cat_id return_value
FROM sufioun_product_categories
WHERE status=1
ORDER BY sort_order;
```

Subcategory LOV
```sql
SELECT sub_cat_name display_value, sub_cat_id return_value
FROM sufioun_sub_categories
WHERE product_cat_id = :P310_CATEGORY_ID
ORDER BY sort_order;
```

Validation
```sql
SELECT CASE WHEN :P310_SELLING_PRICE >= :P310_PURCHASE_PRICE THEN 1 ELSE 0 END ok_flag
FROM dual;
```

Process
APEX Form DML on sufioun_products.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.prod-form{background:#fff;padding:12px;border-radius:12px}
```

## 6) Validations, Computations, and Processes
1. product_name required.
2. selling_price >= purchase_price.
3. min_stock_level <= max_stock_level.

## 7) Report/Chart Definitions
IR row links to form.

## 8) Acceptance Criteria
Product CRUD persists and LOV dependencies work.

# 03-Module-Inventory/Page-320-Categories-and-Departments.md

## 1) Page Summary
Proposed Page ID: 320
Page Name: Categories and Departments
Module: Inventory
Purpose/user story: maintain categories, subcategories, departments.
Intended roles and access rules:
1. INVENTORY_MANAGER
2. ADMIN

## 2) UX / Layout (APEX Regions)
Tabbed regions:
1. Product Categories IG
2. Sub Categories IG
3. Departments IG

## 3) SQL (Build-Ready)
Categories
```sql
SELECT product_cat_id, product_cat_name, product_cat_desc, sort_order, status
FROM sufioun_product_categories;
```

Subcategories
```sql
SELECT sub_cat_id, sub_cat_name, product_cat_id, sort_order, status
FROM sufioun_sub_categories;
```

Departments
```sql
SELECT department_id, department_name, manager_id, company_id, location, status
FROM sufioun_departments;
```

LOV
```sql
SELECT product_cat_name display_value, product_cat_id return_value
FROM sufioun_product_categories
WHERE status=1
ORDER BY sort_order;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.tab-grid{gap:12px}
```

## 6) Validations, Computations, and Processes
IG automatic row processing for each tab.

## 7) Report/Chart Definitions
Editable IGs with row validation.

## 8) Acceptance Criteria
Edits save and are available in dependent LOVs.

# 03-Module-Inventory/Page-330-Stock-on-Hand-Dashboard.md

## 1) Page Summary
Proposed Page ID: 330
Page Name: Stock on Hand Dashboard
Module: Inventory
Purpose/user story: real-time stock visibility.
Intended roles and access rules:
1. INVENTORY_MANAGER unrestricted
2. STOREKEEPER unrestricted

## 2) UX / Layout (APEX Regions)
Regions:
1. KPI cards
2. Category chart
3. Stock snapshot IR

## 3) SQL (Build-Ready)
Snapshot
```sql
SELECT p.product_id, p.product_name, c.product_cat_name, s.location, s.rack_no,
       s.quantity, p.min_stock_level,
       CASE WHEN s.quantity <= p.min_stock_level THEN 'LOW' ELSE 'OK' END stock_state
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id
LEFT JOIN sufioun_product_categories c ON c.product_cat_id = s.product_cat_id
ORDER BY c.product_cat_name, p.product_name;
```

KPI
```sql
SELECT COUNT(*) product_count,
       SUM(quantity) total_units,
       SUM(CASE WHEN s.quantity <= p.min_stock_level THEN 1 ELSE 0 END) low_stock_items
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.stock-low{color:#c62828;font-weight:700}
```

## 6) Validations, Computations, and Processes
None.

## 7) Report/Chart Definitions
Bar chart by product category.

## 8) Acceptance Criteria
Dashboard totals match stock table.

# 03-Module-Inventory/Page-340-Inventory-Movements.md

## 1) Page Summary
Proposed Page ID: 340
Page Name: Inventory Movements
Module: Inventory
Purpose/user story: unified movement ledger.
Intended roles and access rules: Inventory roles and Admin.

## 2) UX / Layout (APEX Regions)
Single IR with movement facets and date filters.

## 3) SQL (Build-Ready)
```sql
SELECT movement_dt,
       movement_type,
       ref_no,
       product_id,
       product_name,
       qty_change,
       source_table
FROM (
  SELECT m.receive_date movement_dt, 'PURCHASE_RECEIVE' movement_type, m.receive_no ref_no,
         d.product_id, p.product_name, d.receive_quantity qty_change, 'Sufioun_Purchase_receive_Detailss' source_table
  FROM Sufioun_Purchase_receive_master m
  JOIN Sufioun_Purchase_receive_Detailss d ON d.receive_id = m.receive_id
  JOIN sufioun_products p ON p.product_id = d.product_id

  UNION ALL

  SELECT m.invoice_date, 'SALES', m.invoice_no, d.product_id, p.product_name, -d.quantity, 'sufioun_sales_details'
  FROM sufioun_sales_master m
  JOIN sufioun_sales_details d ON d.invoice_id = m.invoice_id
  JOIN sufioun_products p ON p.product_id = d.product_id

  UNION ALL

  SELECT r.return_date, 'SALES_RETURN', r.return_no, d.product_id, p.product_name, d.qty_return, 'sufioun_sales_return_details'
  FROM sufioun_sales_return_master r
  JOIN sufioun_sales_return_details d ON d.sales_return_id = r.sales_return_id
  JOIN sufioun_products p ON p.product_id = d.product_id

  UNION ALL

  SELECT d.damage_date, 'DAMAGE', d.damage_no, dd.product_id, p.product_name, -dd.damage_quantity, 'sufioun_damage_details'
  FROM sufioun_damage d
  JOIN sufioun_damage_details dd ON dd.damage_id = d.damage_id
  JOIN sufioun_products p ON p.product_id = dd.product_id

  UNION ALL

  SELECT a.posted_date, 'STOCK_ADJUST', a.adjust_no, ad.product_id, p.product_name, ad.adjust_qty, 'sufioun_stock_adjust_detail'
  FROM sufioun_stock_adjust_master a
  JOIN sufioun_stock_adjust_detail ad ON ad.adjust_id = a.adjust_id
  JOIN sufioun_products p ON p.product_id = ad.product_id
  WHERE a.adjust_status = 'POSTED'
)
WHERE movement_dt BETWEEN :P340_FROM_DT AND :P340_TO_DT
  AND (:P340_MOVEMENT_TYPE IS NULL OR movement_type = :P340_MOVEMENT_TYPE)
ORDER BY movement_dt DESC;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.qty-neg{color:#b71c1c}
.qty-pos{color:#1b5e20}
```

## 6) Validations, Computations, and Processes
Query-only page.

## 7) Report/Chart Definitions
Conditional formatting by qty sign.

## 8) Acceptance Criteria
All movement sources appear with correct quantity direction.

# 03-Module-Inventory/Page-350-Low-Stock-Reorder.md

## 1) Page Summary
Proposed Page ID: 350
Page Name: Low Stock and Reorder
Module: Inventory
Purpose/user story: prioritize replenishment.
Intended roles and access rules: inventory roles.

## 2) UX / Layout (APEX Regions)
IR + supplier chart.

## 3) SQL (Build-Ready)
Main report
```sql
SELECT p.product_id, p.product_name, s.quantity current_qty, p.min_stock_level,
       (p.min_stock_level - s.quantity) reorder_qty,
       sup.supplier_name
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id
LEFT JOIN sufioun_suppliers sup ON sup.supplier_id = p.supplier_id
WHERE s.quantity <= p.min_stock_level
ORDER BY reorder_qty DESC;
```

Chart
```sql
SELECT sup.supplier_name, SUM(p.min_stock_level - s.quantity) reorder_total
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id=s.product_id
LEFT JOIN sufioun_suppliers sup ON sup.supplier_id=p.supplier_id
WHERE s.quantity <= p.min_stock_level
GROUP BY sup.supplier_name;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.reorder-qty{font-weight:800;color:#c62828}
```

## 6) Validations, Computations, and Processes
Optional process: create purchase order draft from selected rows.

## 7) Report/Chart Definitions
IR with action column.

## 8) Acceptance Criteria
Low-stock and reorder quantities are accurate.

# 03-Module-Inventory/Page-360-Stock-Adjustment-Request.md

## 1) Page Summary
Proposed Page ID: 360
Page Name: Stock Adjustment Request
Module: Inventory
Purpose/user story: submit stock adjustment requests.
Intended roles and access rules:
1. STOREKEEPER
2. INVENTORY_MANAGER

## 2) UX / Layout (APEX Regions)
Master-detail:
1. Adjustment header form
2. Adjustment detail IG
Buttons: Save Request, Submit.

## 3) SQL (Build-Ready)
Header
```sql
SELECT adjust_id, adjust_no, request_date, requested_by, reason,
       adjust_status, approved_by, approved_date, posted_date
FROM sufioun_stock_adjust_master
WHERE adjust_id = :P360_ADJUST_ID;
```

Details
```sql
SELECT adjust_det_id, adjust_id, product_id, current_qty, adjust_qty, line_note
FROM sufioun_stock_adjust_detail
WHERE adjust_id = :P360_ADJUST_ID;
```

Current qty fetch
```sql
SELECT NVL(quantity,0) qty
FROM sufioun_stock
WHERE product_id = :PRODUCT_ID;
```

Validation
```sql
SELECT CASE WHEN :P360_REASON IS NOT NULL THEN 1 ELSE 0 END ok_flag FROM dual;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.adj-request{background:#f0f9ff;border-radius:12px;padding:12px}
```

## 6) Validations, Computations, and Processes
1. At least one detail row.
2. adjust_qty <> 0.
3. default adjust_status = REQUESTED.

## 7) Report/Chart Definitions
Detail IG with +/- formatting.

## 8) Acceptance Criteria
New request saved in REQUESTED status with valid lines.

# 03-Module-Inventory/Page-370-Stock-Adjustment-Approve-Post.md

## 1) Page Summary
Proposed Page ID: 370
Page Name: Stock Adjustment Approve/Post
Module: Inventory
Purpose/user story: approve and post stock adjustments.
Intended roles and access rules:
1. INVENTORY_MANAGER approve/post.
2. STOREKEEPER read-only.

## 2) UX / Layout (APEX Regions)
Regions:
1. Pending requests IR
2. Request detail IR
Buttons: Approve, Reject, Post.

## 3) SQL (Build-Ready)
Pending
```sql
SELECT adjust_id, adjust_no, request_date, requested_by, adjust_status, reason
FROM sufioun_stock_adjust_master
WHERE adjust_status IN ('REQUESTED','APPROVED')
ORDER BY request_date DESC;
```

Approve process
```sql
UPDATE sufioun_stock_adjust_master
SET adjust_status = 'APPROVED',
    approved_by = :G_EMPLOYEE_ID,
    approved_date = SYSDATE,
    upd_by = :APP_USER,
    upd_dt = SYSDATE
WHERE adjust_id = :P370_ADJUST_ID
  AND adjust_status = 'REQUESTED';
```

Post process
```plsql
DECLARE
BEGIN
  FOR r IN (
    SELECT product_id, adjust_qty
    FROM sufioun_stock_adjust_detail
    WHERE adjust_id = :P370_ADJUST_ID
  ) LOOP
    sufioun_update_stock_qty(r.product_id, r.adjust_qty);
  END LOOP;

  UPDATE sufioun_stock_adjust_master
  SET adjust_status = 'POSTED',
      posted_date = SYSDATE,
      upd_by = :APP_USER,
      upd_dt = SYSDATE
  WHERE adjust_id = :P370_ADJUST_ID
    AND adjust_status = 'APPROVED';
END;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.status-requested{color:#ef6c00}
.status-approved{color:#1565c0}
.status-posted{color:#2e7d32}
.status-rejected{color:#b71c1c}
```

## 6) Validations, Computations, and Processes
1. Authorization: INVENTORY_MANAGER only for Approve/Post.
2. Post allowed only from APPROVED state.

## 7) Report/Chart Definitions
Status badge + action links.

## 8) Acceptance Criteria
Approved requests post exactly once and update stock.

# 04-Module-CRM/Module-CRM-Index.md

## Page List
1. Page 410 Customer Master
2. Page 420 Customer 360 Timeline
3. Page 430 CRM Segmentation

## Key Workflows
1. Maintain customer records.
2. Review customer timeline across sales/services/returns.
3. Run customer segmentation reports.

# 04-Module-CRM/Page-410-Customer-Master.md

## 1) Page Summary
Proposed Page ID: 410
Page Name: Customer Master
Module: CRM
Purpose/user story: customer CRUD and profile maintenance.
Intended roles and access rules:
1. CRM_AGENT and ADMIN: full.
2. CUSTOMER: own record.

## 2) UX / Layout (APEX Regions)
Regions:
1. Customer form
2. Customer list IR
Items: customer fields including image.
Buttons: Save, Create, Delete.

## 3) SQL (Build-Ready)
List
```sql
SELECT customer_id, customer_name, phone_no, email, city, rewards, status
FROM sufioun_customers
WHERE (
  :G_ACTIVE_ROLE IN ('CRM_AGENT','ADMIN')
  OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
);
```

Validation
```sql
SELECT CASE WHEN COUNT(*)=0 THEN 1 ELSE 0 END ok_flag
FROM sufioun_customers
WHERE phone_no = :P410_PHONE_NO
  AND customer_id <> :P410_CUSTOMER_ID;
```

Process
APEX Form DML on sufioun_customers.

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.crm-card{background:#fff;padding:12px;border-radius:12px}
```

## 6) Validations, Computations, and Processes
1. customer_name required.
2. phone unique.
3. Non-admin/non-agent cannot toggle status.

## 7) Report/Chart Definitions
IR with row links.

## 8) Acceptance Criteria
Customer create/update/search works and follows role rules.

# 04-Module-CRM/Page-420-Customer-360-Timeline.md

## 1) Page Summary
Proposed Page ID: 420
Page Name: Customer 360 Timeline
Module: CRM
Purpose/user story: complete customer journey timeline.
Intended roles and access rules:
1. CRM_AGENT, SALES_MANAGER, SERVICE_MANAGER, ADMIN.
2. CUSTOMER own timeline only.

## 2) UX / Layout (APEX Regions)
Left: customer profile card.
Body: timeline IR.

## 3) SQL (Build-Ready)
Customer summary
```sql
SELECT customer_id, customer_name, phone_no, email, city, rewards, remarks
FROM sufioun_customers
WHERE customer_id = :P420_CUSTOMER_ID
  AND (
    :G_ACTIVE_ROLE IN ('CRM_AGENT','SALES_MANAGER','SERVICE_MANAGER','ADMIN')
    OR (:G_ACTIVE_ROLE='CUSTOMER' AND customer_id=:G_CUSTOMER_ID)
  );
```

Timeline
```sql
SELECT event_dt, event_type, event_ref, amount, status_text
FROM (
  SELECT m.invoice_date event_dt, 'SALE' event_type, m.invoice_no event_ref,
         m.grand_total amount, m.payment_status status_text
  FROM sufioun_sales_master m
  WHERE m.customer_id = :P420_CUSTOMER_ID
  UNION ALL
  SELECT s.service_date, 'SERVICE', s.service_no, s.grand_total, s.service_status
  FROM sufioun_service_master s
  WHERE s.customer_id = :P420_CUSTOMER_ID
  UNION ALL
  SELECT r.return_date, 'SALES_RETURN', r.return_no, r.total_amount, TO_CHAR(r.status)
  FROM sufioun_sales_return_master r
  WHERE r.customer_id = :P420_CUSTOMER_ID
)
ORDER BY event_dt DESC;
```

## 4) HTML (only if required)
```html
<span class="timeline-dot"></span>
```

## 5) CSS (REQUIRED)
```css
.timeline-dot{display:inline-block;width:10px;height:10px;background:var(--app-accent);border-radius:50%}
```

## 6) Validations, Computations, and Processes
P420_CUSTOMER_ID required.

## 7) Report/Chart Definitions
Event icon by event_type and status color badges.

## 8) Acceptance Criteria
Timeline includes sales, service, returns in reverse chronological order.

# 04-Module-CRM/Page-430-CRM-Segmentation.md

## 1) Page Summary
Proposed Page ID: 430
Page Name: CRM Segmentation
Module: CRM
Purpose/user story: segment customers for targeting.
Intended roles and access rules:
1. CRM_AGENT
2. ADMIN

## 2) UX / Layout (APEX Regions)
IR + chart facets by city and value tier.

## 3) SQL (Build-Ready)
```sql
SELECT c.customer_id, c.customer_name, c.city,
       NVL(s.sales_amt,0) total_sales,
       NVL(s.invoice_cnt,0) invoice_count,
       NVL(t.ticket_cnt,0) service_tickets,
       NVL(s.last_sale_dt, DATE '1900-01-01') last_sale_dt
FROM sufioun_customers c
LEFT JOIN (
  SELECT customer_id,
         SUM(grand_total) sales_amt,
         COUNT(*) invoice_cnt,
         MAX(invoice_date) last_sale_dt
  FROM sufioun_sales_master
  GROUP BY customer_id
) s ON s.customer_id = c.customer_id
LEFT JOIN (
  SELECT customer_id, COUNT(*) ticket_cnt
  FROM sufioun_service_master
  GROUP BY customer_id
) t ON t.customer_id = c.customer_id
WHERE c.status = 1
ORDER BY total_sales DESC;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.segment-high{background:#e8f5e9}
.segment-low{background:#ffebee}
```

## 6) Validations, Computations, and Processes
Query-only.

## 7) Report/Chart Definitions
Computed value-tier badge column.

## 8) Acceptance Criteria
Segmentation metrics and filters are accurate.

# 05-Module-Admin-Setup/Module-Admin-Setup-Index.md

## Page List
1. Page 510 OAuth User Provisioning
2. Page 520 Role Assignment and Session Role Switch
3. Page 530 Lookup and Status Setup
4. Page 540 Settings
5. Page 550 Audit and Error Logs

## Key Workflows
1. OAuth identities mapped to internal users.
2. Multi-role assignments maintained.
3. Session active role switching.
4. Setup maintenance.
5. Audit/error log inspection.

# 05-Module-Admin-Setup/Page-510-OAuth-User-Provisioning.md

## 1) Page Summary
Proposed Page ID: 510
Page Name: OAuth User Provisioning
Module: Admin/Setup
Purpose/user story: map social identities to app users.
Intended roles and access rules:
1. ADMIN only.

## 2) UX / Layout (APEX Regions)
Regions:
1. OAuth Identity IG
2. Email-to-user helper report
Items: P510_EMAIL, P510_PROVIDER_CODE, P510_USER_ID.

## 3) SQL (Build-Ready)
Identity report
```sql
SELECT i.identity_id, i.provider_code, i.provider_subject, i.email, i.user_id, u.user_name, i.last_login_dt, i.status
FROM sufioun_oauth_identities i
JOIN sufioun_com_users u ON u.user_id = i.user_id
ORDER BY i.last_login_dt DESC NULLS LAST;
```

User LOV
```sql
SELECT u.user_name||' ('||u.email||')' display_value, u.user_id return_value
FROM sufioun_com_users u
WHERE u.status=1
  AND (:P510_EMAIL IS NULL OR UPPER(u.email)=UPPER(:P510_EMAIL))
ORDER BY u.user_name;
```

Validation
```sql
SELECT CASE WHEN COUNT(*)=1 THEN 1 ELSE 0 END ok_flag
FROM sufioun_com_users
WHERE UPPER(email)=UPPER(:P510_EMAIL);
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.admin-chip{background:#e3f2fd;padding:4px 8px;border-radius:999px}
```

## 6) Validations, Computations, and Processes
1. provider_code mandatory.
2. Unique provider_code + provider_subject.
3. email maps to valid internal user.

## 7) Report/Chart Definitions
Editable IG with status badge.

## 8) Acceptance Criteria
OAuth identities can be created/linked with valid constraints.

# 05-Module-Admin-Setup/Page-520-Role-Assignment-and-Session-Role-Switch.md

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

# 05-Module-Admin-Setup/Page-530-Lookup-and-Status-Setup.md

## 1) Page Summary
Proposed Page ID: 530
Page Name: Lookup and Status Setup
Module: Admin/Setup
Purpose/user story: maintain lookups and status masters.
Intended roles and access rules:
1. ADMIN only.

## 2) UX / Layout (APEX Regions)
Tabbed editable IG regions for service, expense, categories.

## 3) SQL (Build-Ready)
```sql
SELECT servicelist_id, service_name, service_cost, estimated_time, status
FROM sufioun_service_list;
```

```sql
SELECT expense_type_id, expense_code, type_name, default_amount, expense_category, status
FROM sufioun_expense_list;
```

```sql
SELECT product_cat_id, product_cat_name, sort_order, status
FROM sufioun_product_categories;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.lookup-tabs{background:#fff;border-radius:12px}
```

## 6) Validations, Computations, and Processes
IG automatic row processing by tab.

## 7) Report/Chart Definitions
Inline editable grids.

## 8) Acceptance Criteria
Lookup edits persist and drive LOVs across app.

# 05-Module-Admin-Setup/Page-540-Settings.md

## 1) Page Summary
Proposed Page ID: 540
Page Name: Settings
Module: Admin/Setup
Purpose/user story: maintain configurable app settings.
Intended roles and access rules:
1. ADMIN only.

## 2) UX / Layout (APEX Regions)
Settings IR + form popup.

## 3) SQL (Build-Ready)
```sql
SELECT setting_key, setting_value, setting_group, status, upd_by, upd_dt
FROM sufioun_app_settings
ORDER BY setting_group, setting_key;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.settings-grid{background:#fff;border-radius:12px;padding:12px}
```

## 6) Validations, Computations, and Processes
1. setting_key required.
2. setting_value required for active entries.

## 7) Report/Chart Definitions
IR export enabled.

## 8) Acceptance Criteria
Settings can be managed without code changes.

# 05-Module-Admin-Setup/Page-550-Audit-and-Error-Logs.md

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

# 06-Module-Analytics/Module-Analytics-Index.md

## Page List
1. Page 610 Executive Dashboard
2. Page 620 Report Library
3. Page 630 Export Center

## Key Workflows
1. Executive KPI monitoring.
2. Cross-module report access.
3. Export-ready operational datasets.

# 06-Module-Analytics/Page-610-Executive-Dashboard.md

## 1) Page Summary
Proposed Page ID: 610
Page Name: Executive Dashboard
Module: Analytics
Purpose/user story: consolidated business KPIs and trends.
Intended roles and access rules:
1. ADMIN
2. SALES_MANAGER
3. SERVICE_MANAGER
4. INVENTORY_MANAGER

## 2) UX / Layout (APEX Regions)
Regions: KPI cards, trend chart, SLA chart, low-stock risk chart.

## 3) SQL (Build-Ready)
KPI
```sql
SELECT
  (SELECT NVL(SUM(grand_total),0) FROM sufioun_sales_master WHERE invoice_date >= ADD_MONTHS(TRUNC(SYSDATE,'MM'),-1)) monthly_sales,
  (SELECT COUNT(*) FROM sufioun_service_master WHERE service_status IN ('RECEIVED','DIAGNOSIS','IN_PROGRESS')) open_tickets,
  (SELECT COUNT(*) FROM sufioun_stock s JOIN sufioun_products p ON p.product_id=s.product_id WHERE s.quantity<=p.min_stock_level) low_stock_items
FROM dual;
```

Trend
```sql
SELECT TRUNC(invoice_date,'MM') month_dt, SUM(grand_total) amount
FROM sufioun_sales_master
WHERE invoice_date >= ADD_MONTHS(TRUNC(SYSDATE,'MM'),-12)
GROUP BY TRUNC(invoice_date,'MM')
ORDER BY month_dt;
```

SLA
```sql
SELECT service_status, COUNT(*) cnt
FROM sufioun_service_master
GROUP BY service_status;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.exec-kpi{background:#fff;border-top:4px solid var(--app-primary);padding:12px;border-radius:12px}
```

## 6) Validations, Computations, and Processes
Query-only.

## 7) Report/Chart Definitions
Line + donut + bar charts.

## 8) Acceptance Criteria
Dashboard renders role-allowed KPIs and trends accurately.

# 06-Module-Analytics/Page-620-Report-Library.md

## 1) Page Summary
Proposed Page ID: 620
Page Name: Report Library
Module: Analytics
Purpose/user story: role-aware index of available reports.
Intended roles and access rules: all authenticated users, filtered by role.

## 2) UX / Layout (APEX Regions)
Cards region grouped by module.

## 3) SQL (Build-Ready)
```sql
SELECT report_name, module_name, page_id, required_role
FROM (
  SELECT 'Sales Daily Report' report_name, 'Sales' module_name, 170 page_id, 'SALES' required_role FROM dual
  UNION ALL SELECT 'Service Analytics','Services',250,'SERVICE' FROM dual
  UNION ALL SELECT 'Stock Movement','Inventory',340,'INVENTORY' FROM dual
  UNION ALL SELECT 'Customer Segmentation','CRM',430,'CRM' FROM dual
  UNION ALL SELECT 'Audit Logs','Admin',550,'ADMIN' FROM dual
)
WHERE (
  required_role='ADMIN' AND :G_ACTIVE_ROLE='ADMIN'
  OR required_role='SALES' AND :G_ACTIVE_ROLE IN ('SALES_MANAGER','SALES_REP')
  OR required_role='SERVICE' AND :G_ACTIVE_ROLE IN ('SERVICE_MANAGER','TECHNICIAN')
  OR required_role='INVENTORY' AND :G_ACTIVE_ROLE IN ('INVENTORY_MANAGER','STOREKEEPER')
  OR required_role='CRM' AND :G_ACTIVE_ROLE='CRM_AGENT'
);
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.report-card{background:#fff;border-radius:12px;padding:14px}
```

## 6) Validations, Computations, and Processes
None.

## 7) Report/Chart Definitions
Cards with deep links to report pages.

## 8) Acceptance Criteria
Library shows only reports available to active role.

# 06-Module-Analytics/Page-630-Export-Center.md

## 1) Page Summary
Proposed Page ID: 630
Page Name: Export Center
Module: Analytics
Purpose/user story: export operational datasets in IR format.
Intended roles and access rules: manager/admin role-based access per dataset.

## 2) UX / Layout (APEX Regions)
Region selector + 3 IR datasets.

## 3) SQL (Build-Ready)
Sales export dataset
```sql
SELECT m.invoice_no, m.invoice_date, c.customer_name,
       d.product_id, p.product_name, d.quantity, d.mrp, d.discount_amount, d.line_total,
       m.grand_total, m.payment_status
FROM sufioun_sales_master m
JOIN sufioun_sales_details d ON d.invoice_id = m.invoice_id
JOIN sufioun_products p ON p.product_id = d.product_id
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
WHERE m.invoice_date BETWEEN :P630_FROM_DT AND :P630_TO_DT;
```

Service export dataset
```sql
SELECT m.service_no, m.service_date, c.customer_name, m.service_status,
       d.servicelist_id, sl.service_name, d.parts_id, d.quantity, d.line_total
FROM sufioun_service_master m
LEFT JOIN sufioun_service_details d ON d.service_id = m.service_id
LEFT JOIN sufioun_service_list sl ON sl.servicelist_id = d.servicelist_id
LEFT JOIN sufioun_customers c ON c.customer_id = m.customer_id
WHERE m.service_date BETWEEN :P630_FROM_DT AND :P630_TO_DT;
```

Stock export dataset
```sql
SELECT s.product_id, p.product_name, s.quantity, s.location, s.rack_no, s.last_update
FROM sufioun_stock s
JOIN sufioun_products p ON p.product_id = s.product_id;
```

## 4) HTML (only if required)
Not required.

## 5) CSS (REQUIRED)
```css
.export-toolbar{display:flex;gap:10px;flex-wrap:wrap}
```

## 6) Validations, Computations, and Processes
Date range validation.

## 7) Report/Chart Definitions
Interactive Reports with CSV/XLSX/PDF export.

## 8) Acceptance Criteria
Operational exports are generated with selected filters.
