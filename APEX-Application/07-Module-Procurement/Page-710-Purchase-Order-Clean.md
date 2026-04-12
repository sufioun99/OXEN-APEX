## Page 710: Purchase Order - Clean Documentation

This is the clean reference version for implementation and handover.

## 0) How to Create This Page in APEX

### Page type decision
- Use **Blank Page** (recommended).
- Reason: this transactional page combines form, editable grid, summary, and custom workflow/UI.

### Creation steps
1. Create -> Page -> Blank Page.
2. Set Page Number `710`, Name `Purchase Order`.
3. Add navigation entry under Procurement.
4. Apply authentication and procurement authorization scheme.
5. Create regions in this order:
  1. `RGN_PO_HERO` (Static Content)
  2. `RGN_PO_HEADER` (Form)
  3. `RGN_PO_LINES` (Editable IG)
  4. `RGN_PO_SUMMARY` (SQL display/report)
  5. `RGN_PO_ACTIONS` (buttons)
6. Add core items and button actions.
7. Paste SQL from section 5.
8. Add validations/processes from sections 6 and 7.
9. Paste HTML/CSS/JS from section 9.
10. Run acceptance checks from section 10.

### Where code goes
- HTML: `RGN_PO_HERO` static content source.
- CSS: Page -> CSS -> Inline.
- JavaScript: Page -> JavaScript -> Function and Global Variable Declaration.
- SQL: each region Source SQL (header/lines/summary) and Shared LOV SQL.

## 1) Page Purpose
- Create and maintain Purchase Orders.
- Capture supplier, warehouse, and commercial terms.
- Manage PO lines with quantity, cost, discount, and tax.
- Route document through submit and approval states.

## 2) Roles and Access
- ADMIN: Full access.
- INVENTORY_MANAGER: Full transactional control including approval.
- STOREKEEPER: Draft and submit only.

## 3) Main Regions
1. `RGN_PO_HERO`
2. `RGN_PO_HEADER`
3. `RGN_PO_LINES`
4. `RGN_PO_SUMMARY`
5. `RGN_PO_ACTIONS`

## 4) Core Page Items
- `P710_ORDER_ID` (Hidden PK)
- `P710_ORDER_NO` (Display/Read-only)
- `P710_ORDER_DATE`
- `P710_SUPPLIER_ID`
- `P710_EXPECTED_DELIVERY_DATE`
- `P710_ORDER_BY`
- `P710_TOTAL_AMOUNT`
- `P710_VAT`
- `P710_GRAND_TOTAL`
- `P710_ORDER_STATUS`
- `P710_NOTES`
- `P710_IMAGE_NAME`
- `P710_IMAGE_MIME_TYPE`
- `P710_IMAGE_BLOB`

## 5) SQL Sources

### 5.1 Header
```sql
SELECT order_detail_id,
       order_id,
       order_date,
       supplier_id,
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
       cre_dt,
       upd_by,
       upd_dt
FROM sufioun_Purchase_order_master
WHERE order_id = :P710_ORDER_ID;
```

### 5.2 Lines
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

### 5.3 LOV: Supplier
```sql
SELECT supplier_name||' ['||supplier_code||']' display_value,
       supplier_id return_value
FROM sufioun_suppliers
WHERE status = 1
ORDER BY supplier_name;
```

### 5.4 LOV: Warehouse
```sql
SELECT warehouse_name display_value,
       warehouse_id return_value
FROM sufioun_warehouse
WHERE status = 1
ORDER BY warehouse_name;
```

### 5.5 LOV: Product
```sql
SELECT p.product_name||' ('||p.product_code||')' display_value,
       p.product_id return_value
FROM sufioun_products p
WHERE p.status = 1
ORDER BY p.product_name;
```

### 5.6 Totals
```sql
SELECT NVL(SUM(purchase_price * quantity),0) total_amount,
       NVL(SUM(vat_amount),0)               vat,
       NVL(SUM(grand_total),0)              grand_total
FROM sufioun_Purchase_order_details
WHERE order_id = :P710_ORDER_ID;
```

## 6) Validations
1. Supplier required.
2. Warehouse required.
3. At least one line before submit.
4. `order_qty > 0`.
5. `unit_cost >= 0`.
6. Optional uniqueness rule: product cannot repeat in same PO.

## 7) Processes
1. `PRC_PO_HEADER_DML`
2. `PRC_PO_LINES_IG_ARP`
3. `PRC_PO_RECALC_TOTALS`
4. `PRC_PO_STATUS_TRANSITION`

## 8) Dynamic Actions
1. Supplier change -> default commercial terms.
2. Product change in IG -> default UOM/cost/tax.
3. IG save -> refresh summary and totals.

## 9) UI Design Snippets

### 9.1 HTML
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

### 9.2 CSS
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

@media (max-width: 900px){
  .poHero{flex-direction:column;align-items:flex-start}
}
```

### 9.3 JavaScript
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

## 10) Acceptance Criteria
1. User can create PO header and lines in one flow.
2. Totals are accurate and refresh instantly after line save.
3. Submit and approval status transitions enforce role rules.
4. Page is responsive on desktop and mobile.
5. Required validations block invalid transactions.
