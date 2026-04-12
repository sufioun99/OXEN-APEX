## Employee Photo Not Showing - Troubleshooting Guide

This document walks through diagnosing and fixing the employee photo display issue.

### Symptoms
- Employee directory page loads, but all avatars show placeholder icon instead of actual photos
- Image URLs do not resolve

### Root Cause Analysis

The photo display requires 3 layers to work:

1. **Database Layer**: `sufioun_media_api` package with `emp_photo` procedure
2. **APEX Layer**: Application Process named `EMP_PHOTO` (On Demand)
3. **SQL Layer**: Page region SQL generating correct image URLs with `&x01` parameter

---

## Troubleshooting Checklist

### Step 1: Verify Database Objects

**Schema package and procedure:**
```sql
-- Check if media API package is compiled
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'SUFIOUN_MEDIA_API';

-- Expected result: PACKAGE (VALID) and PACKAGE BODY (VALID)

-- If INVALID, recompile:
ALTER PACKAGE sufioun_media_api COMPILE;
ALTER PACKAGE sufioun_media_api COMPILE BODY;
```

**Employee table columns:**
```sql
-- Check PHOTO column exists and has data
SELECT column_name, data_type, nullable
FROM user_tab_columns
WHERE table_name = 'SUFIOUN_EMPLOYEES'
  AND column_name IN ('PHOTO', 'IMAGE_MIME_TYPE');

-- Check if any employee records have photos
SELECT COUNT(*) total_employees,
       SUM(CASE WHEN dbms_lob.getlength(photo) > 0 THEN 1 ELSE 0 END) with_photos
FROM sufioun_employees;
```

---

### Step 2: Verify APEX Application Process

**Required Application Process:**
- Name: `EMP_PHOTO`
- Type: `On Demand`
- Execution Mode: `Database (PLSQL)`
- Code:

```plsql
BEGIN
  sufioun_media_api.emp_photo(apex_application.g_x01);
END;
```

**How to check/create in APEX:**

1. Open your application in APEX designer.
2. Go to **Shared Components** → **Application Processes**.
3. Search for `EMP_PHOTO`.
   - If exists: Verify status is **Enabled** and code is exact match above.
   - If missing: Click **Create** and add the process with exact code above.

---

### Step 3: Verify Page Region SQL

**Current region SQL should generate image URLs like:**

```sql
apex_page.get_url(
  p_page    => 0,
  p_request => 'APPLICATION_PROCESS=EMP_PHOTO'
) || '&x01=' || apex_util.url_encode(e.employee_id)
```

**This produces URLs similar to:**
```
f?p=APP_ID:0:SESSION:APPLICATION_PROCESS=EMP_PHOTO&x01=EMP001
```

**How to verify/fix in APEX:**

1. Go to page **Page 820 (or your Employees page)**.
2. Find the region with employee data (e.g., `RGN_EMPLOYEE_CARDS` or similar IR region).
3. Edit the region's SQL Source.
4. Search for the `img_url` or image URL column in the query.
5. Ensure it matches the pattern above (uses `apex_page.get_url` + `&x01=` + URL-encoded employee ID).
6. If incorrect, replace with correct code from [Master-Pages-Step-Log.md](Master-Pages-Step-Log.md#section-employee-region-sql-card-view).

---

### Step 4: Browser Network Inspection

**In your browser (Chrome/Firefox):**

1. Open **Developer Tools** (F12).
2. Go to **Network** tab.
3. Refresh the Employees page.
4. Filter for "image" requests.
5. Look for requests to `f?p=...APPLICATION_PROCESS=EMP_PHOTO...`
   - **200 OK** with image MIME type = Process OK, image returned.
   - **404/500** = Process error or employee ID not passed correctly.
   - **No requests** = Image URL never generated (SQL issue).
6. If errors, click request → **Response** to see error message.

---

### Step 5: Test Manual Photo Fetch

**In SQL or APEX SQL Workshop:**

```sql
-- If IMAGE_MIME_TYPE column exists but is null, fill it based on photo content
UPDATE sufioun_employees
SET image_mime_type = 'image/jpeg'
WHERE photo IS NOT NULL
  AND image_mime_type IS NULL;
COMMIT;
```

**Direct procedure test:**
```plsql
-- Test the media API directly (may output binary, but confirms it works)
BEGIN
  sufioun_media_api.emp_photo('EMP001');  -- Replace with actual employee_id
END;
/
```

---

## Common Fixes

| Issue | Fix |
|---|---|
| **Page says "placeholder icon only"** | Check APEX process exists and is enabled |
| **Network shows 500 error on image request** | Recompile `sufioun_media_api` package and body |
| **Network shows 404 on image request** | Verify application process name is exactly `EMP_PHOTO` |
| **No photo image requests at all in Network tab** | Fix SQL: check `img_url` column uses correct `apex_page.get_url` pattern |
| **Images show for some employees, not others** | Check those employees have PHOTO data: `SELECT dbms_lob.getlength(photo) FROM sufioun_employees WHERE employee_id = 'X'` |

---

## If Still Broken

1. Verify the SQL in [Master-Pages-Step-Log.md](Master-Pages-Step-Log.md) matches your page.
2. Copy the exact EMP_PHOTO process code into APEX.
3. Run script [APEX-Application/SQL/007_media_api.sql](../SQL/007_media_api.sql) if not yet applied.
4. Recompile package: `ALTER PACKAGE sufioun_media_api COMPILE; ALTER PACKAGE sufioun_media_api COMPILE BODY;`
5. Clear APEX cache: Application Settings → Clear Cache → Clear Global Cache.
6. Refresh page in browser.

---

## Next Steps

Once photos display:
- Test Edit button links (should go to Page 820 Employee Master).
- Test CV button links (should go to Page 830 Employee CV).
- Test grid/list mode toggle buttons.
