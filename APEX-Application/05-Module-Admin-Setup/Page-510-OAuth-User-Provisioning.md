
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

