
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

