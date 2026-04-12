## Page 710: Purchase Order - Build Log

Purpose: Step-by-step working log while designing and building the Purchase Order transactional page.

## Build Tracker

| Date | Step | Area | Action | Output | Status |
|---|---:|---|---|---|---|
| 2026-04-08 | 1 | Scope | Finalized user story, role scope, and table mapping | Functional scope approved | Done |
| 2026-04-08 | 2 | UX | Defined region layout and interaction flow | Page wireframe documented | Done |
| 2026-04-08 | 3 | Data | Defined header, lines, LOV, and totals SQL | Build-ready SQL blocks ready | Done |
| 2026-04-08 | 4 | Logic | Defined DA, validations, and save lifecycle | Transaction rules documented | Done |
| 2026-04-08 | 5 | UI | Added CSS and JS behavior for better operator workflow | Responsive card/grid behavior ready | Done |
| 2026-04-08 | 6 | QA | Defined acceptance checklist and edge cases | Test matrix ready | Done |
| 2026-04-08 | 7 | Build Guide | Added APEX page-creation guide (Blank Page approach) with exact design/code placement steps | Implementation path finalized | Done |

---

## Step 0 - APEX Page Creation Guide (Start Point)

### Which page type should be used?
Use **Blank Page** for Page 710.

Why Blank Page:
1. Purchase Order is a composite transactional page (Header Form + Editable IG + Summary + Actions).
2. Wizard pages are fast for simple CRUD, but this page needs custom layout and status workflow.
3. Blank Page gives full control over region order, button behavior, and dynamic actions.

### Page Wizard Steps
1. App Builder -> Create -> Page.
2. Select: **Blank Page**.
3. Page Number: `710`.
4. Name: `Purchase Order`.
5. Navigation: add under Procurement menu.
6. Authentication: required.
7. Authorization Scheme: Procurement roles (Admin, Inventory Manager, Storekeeper).
8. Create page.

### Immediately after page creation
1. Set Page Template Options as needed (standard content container).
2. Add static page items first:
- `P710_ORDER_ID` hidden (primary key holder)
- `P710_ORDER_STATUS` hidden/display
- `P710_GRAND_TOTAL` hidden/display for JS stat binding
3. Save page once before adding regions.

---

## Step 1 - Scope Definition

### User Story
As a purchase operator, I can create a Purchase Order with header and lines, save draft, submit for approval, and print/export when approved.

### Access and Role Policy
- ADMIN: full access.
- INVENTORY_MANAGER: create/edit/approve.
- STOREKEEPER: create/edit draft, submit.

### Transaction States
- DRAFT
- SUBMITTED
- APPROVED
- REJECTED
- CLOSED

---

## Step 2 - UX and Page Structure

### Regions
1. `RGN_PO_HERO` (Display Only)
- PO title, status badge, supplier quick info, action shortcuts.

2. `RGN_PO_HEADER` (Form)
- Supplier, expected delivery date, order by, totals, notes, image upload.

3. `RGN_PO_LINES` (Editable IG)
- Product, UOM, quantity, cost, tax %, discount %, line net.

4. `RGN_PO_SUMMARY` (Display)
- Subtotal, discount total, tax total, net total.

5. `RGN_PO_ACTIVITY` (optional report)
- Created by/on, last update, status history.

### Buttons
- `BTN_NEW`
- `BTN_SAVE_DRAFT`
- `BTN_SUBMIT`
- `BTN_APPROVE`
- `BTN_REJECT`
- `BTN_ADD_LINE`
- `BTN_DELETE_LINE`

### Branching
- Save stays on page.
- Submit/Approve refreshes header + lines + summary regions.

### Region Creation Order (exact build order)
1. Create `RGN_PO_HERO` as **Static Content** (top of page).
2. Create `RGN_PO_HEADER` as **Form Region** using header SQL/table mapping.
3. Create `RGN_PO_LINES` as **Interactive Grid (Editable)** using lines SQL.
4. Create `RGN_PO_SUMMARY` as **Classic Report or Static SQL region**.
5. Create `RGN_PO_ACTIVITY` as optional report region.
6. Add action buttons to Header region: Save Draft, Submit, Approve, Reject.

### Static IDs (recommended)
- `R710_PO_HERO`
- `R710_PO_HEADER`
- `R710_PO_LINES`
- `R710_PO_SUMMARY`

These IDs are referenced by CSS/JS and DA refresh actions.

---

## Step 3 - SQL Design (Build-Ready)

### Where to paste SQL in APEX
1. Header SQL -> Region `RGN_PO_HEADER` -> Source -> SQL Query.
2. Lines SQL -> Region `RGN_PO_LINES` -> Source -> SQL Query.
3. LOV SQL -> Shared Components -> LOVs, then bind LOV to page/IG columns.
4. Totals SQL -> Region `RGN_PO_SUMMARY` -> Source -> SQL Query.

### Header Form SQL
```sql
SELECT order_id,
       order_no,
       order_date,
       supplier_id,
       expected_delivery_date,
       order_by,
       total_amount,
       vat,
       grand_total,
       order_status,
       notes,
       image_name,
       image_mime_type,
       image_blob,
       status,
       cre_by,
       cre_dt,
       upd_by,
       upd_dt
FROM sufioun_Purchase_order_master
WHERE order_id = :P710_ORDER_ID;
```

### Lines IG SQL
```sql
SELECT order_detail_id,
       order_id,
       line_no,
       product_id,
       mrp,
       purchase_price,
       quantity,
       delivered_qty,
       line_total,
       image_name,
       image_mime_type,
       image_blob
FROM sufioun_Purchase_order_details
WHERE order_id = :P710_ORDER_ID
ORDER BY line_no;
```

### Supplier LOV
```sql
SELECT supplier_name||' ['||supplier_code||']' display_value,
       supplier_id return_value
FROM sufioun_suppliers
WHERE status = 1
ORDER BY supplier_name;
```

### Warehouse LOV
```sql
SELECT warehouse_name display_value,
       warehouse_id return_value
FROM sufioun_warehouse
WHERE status = 1
ORDER BY warehouse_name;
```

### Product LOV (line level)
```sql
SELECT p.product_name||' ('||p.product_code||')' display_value,
       p.product_id return_value
FROM sufioun_products p
WHERE p.status = 1
ORDER BY p.product_name;
```

### Product Snapshot (for line autofill)
```sql
SELECT p.product_id,
       p.uom_id,
       NVL(p.purchase_price,0) default_cost,
       NVL(p.tax_rate,0) default_tax_pct
FROM sufioun_products p
WHERE p.product_id = :P710_PRODUCT_ID;
```

### Totals Region SQL
```sql
SELECT NVL(SUM(purchase_price * quantity),0) total_amount,
       NVL(SUM(vat_amount),0)               vat,
       NVL(SUM(grand_total),0)              grand_total
FROM sufioun_Purchase_order_details
WHERE order_id = :P710_ORDER_ID;
```

---

## Step 4 - Dynamic Actions and Validations

### Where to configure logic in APEX
1. Dynamic Actions: Page Designer -> Dynamic Actions (page or region scope).
2. Validations: Page Designer -> Processing -> Validations.
3. DML/IG ARP processes: Page Designer -> Processing.
4. Button conditions by status/role: Button -> Server-side Condition + Authorization Scheme.

### Dynamic Actions
1. On change `P710_SUPPLIER_ID`
- Action: set payment terms and supplier currency defaults.

2. On change `PRODUCT_ID` in IG row
- Action: fetch default UOM, cost, tax.

3. On IG save
- Action: refresh `RGN_PO_SUMMARY`, recompute header totals.

4. On click `BTN_SUBMIT`
- Action: validate mandatory lines before status move.

### Validations
1. Supplier required.
2. Warehouse required.
3. At least one PO line required before submit.
4. `order_qty > 0`.
5. `unit_cost >= 0`.
6. No duplicate product line for same PO unless allowed by policy.

### Process Flow
1. `PRC_PO_HEADER_DML` (form process)
2. `PRC_PO_LINES_IG_ARP` (IG row processing)
3. `PRC_PO_RECALC_TOTALS` (after line changes)
4. `PRC_PO_STATUS_TRANSITION` (submit/approve/reject)

---

## Step 5 - UI Design (HTML/CSS/JS)

### HTML Skeleton (Display region)
```html
<div class="poHero">
  <div>
    <h2 class="poHero__title">Purchase Order</h2>
    <div class="poHero__sub">Manage supplier ordering with line-level cost and tax controls.</div>
  </div>
  <div class="poHero__stats">
    <span class="poStat"><b id="poLineCount">0</b> Lines</span>
    <span class="poStat"><b id="poGrandTotal">0</b> Grand Total</span>
  </div>
</div>
```

Where to place HTML:
1. Region `RGN_PO_HERO` -> Type: Static Content.
2. Paste HTML in Source field.

### CSS (Page 710)
```css
.t-Body-content{
  background:
    radial-gradient(1200px 300px at 10% -10%, rgba(14,116,144,.12), transparent 60%),
    radial-gradient(1000px 250px at 90% -20%, rgba(21,128,61,.10), transparent 55%),
    #f8fafc;
}

.poHero{
  display:flex;
  justify-content:space-between;
  align-items:flex-end;
  gap:12px;
  padding:14px 16px;
  border:1px solid #dbe7ef;
  border-radius:14px;
  background:#ffffff;
  box-shadow:0 12px 28px rgba(2,12,27,.06);
  margin-bottom:12px;
}

.poHero__title{margin:0;font-size:22px;font-weight:900;color:#0b2239}
.poHero__sub{margin-top:4px;font-size:12px;color:#5b7087}
.poHero__stats{display:flex;gap:8px;flex-wrap:wrap}

.poStat{
  padding:8px 10px;
  border-radius:999px;
  border:1px solid #d9e4f0;
  background:#f3f8fd;
  font-size:12px;
  color:#12324f;
}

#R710_PO_SUMMARY .t-Region-body,
#R710_PO_HEADER .t-Region-body,
#R710_PO_LINES .t-Region-body{
  border-radius:12px;
}

@media (max-width: 900px){
  .poHero{flex-direction:column;align-items:flex-start}
}
```

Where to place CSS:
1. Page Designer -> Page -> CSS -> Inline.
2. Paste the CSS block.
3. If this style will be reused, move it to app static CSS file later.

### JavaScript (Page 710 - Function and Global Variable Declaration)
```javascript
(function () {
  function updatePoStats(){
    var rows = document.querySelectorAll('#R710_PO_LINES .a-GV-row');
    var lineCount = rows ? rows.length : 0;
    var lineCountEl = document.getElementById('poLineCount');
    if (lineCountEl) {
      lineCountEl.textContent = String(lineCount);
    }

    var grandItem = document.getElementById('P710_GRAND_TOTAL');
    var grandEl = document.getElementById('poGrandTotal');
    if (grandItem && grandEl) {
      grandEl.textContent = grandItem.value || '0';
    }
  }

  function initPoUi(){
    updatePoStats();
  }

  document.addEventListener('apexreadyend', initPoUi);
  document.addEventListener('apexafterrefresh', initPoUi);
})();
```

Where to place JavaScript:
1. Page Designer -> Page -> JavaScript -> Function and Global Variable Declaration.
2. Paste the JS block.
3. Ensure item `P710_GRAND_TOTAL` exists so `poGrandTotal` stat can be updated.

### Quick verification after UI paste
1. Run page 710.
2. Confirm hero section appears above header form.
3. Confirm line count changes after IG refresh/save.
4. Confirm grand total stat updates from `P710_GRAND_TOTAL`.

---

## Step 6 - QA and Acceptance Checklist

### Functional
- Create PO header and save draft.
- Add, edit, delete PO lines.
- Totals recompute correctly.
- Submit changes status to SUBMITTED.
- Approve changes status to APPROVED by authorized role.

### Data Integrity
- No lines with negative quantity.
- No null supplier on submit.
- Header totals equal sum of line totals.

### UI
- Hero section renders on desktop and mobile.
- Summary values refresh after IG save.
- Button visibility follows status and role.

### Security
- STOREKEEPER cannot approve.
- Unauthorized users cannot access page.

---

## Open Items

1. Confirm whether duplicate product lines are allowed.
2. Confirm approval hierarchy (single-step or multi-step).
3. Confirm exact procurement authorization scheme names in this app.

---

## End-to-End Build Sequence (One-pass execution)

Use this order when implementing from zero:
1. Create Page 710 as Blank Page.
2. Create all regions in the specified order.
3. Add items and set item-level LOVs.
4. Paste SQL sources (header, lines, summary).
5. Add buttons and branch logic.
6. Add validations and processes.
7. Paste HTML, CSS, and JS.
8. Configure authorization and status-based conditions.
9. Run QA checklist.
10. Update clean documentation after every accepted change.
