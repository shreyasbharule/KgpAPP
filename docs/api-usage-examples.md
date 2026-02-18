# API Usage Examples (cURL)

This guide provides practical API usage examples against the FastAPI service.

## 1) Base URL

For local development:

```bash
export API_BASE_URL="http://localhost:8000/api/v1"
```

## 2) Health check (outside `/api/v1`)

```bash
curl -sS http://localhost:8000/health
```

Expected response:

```json
{"status":"ok"}
```

## 3) Authentication

### 3.1 Login and capture tokens

```bash
curl -sS -X POST "$API_BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@university.edu",
    "password": "StudentPass123!"
  }'
```

Export access token after login (requires `jq`):

```bash
export ACCESS_TOKEN="$(curl -sS -X POST \"$API_BASE_URL/auth/login\" \
  -H \"Content-Type: application/json\" \
  -d '{"email":"student@university.edu","password":"StudentPass123!"}' | jq -r '.access_token')"
```

### 3.2 Refresh token

```bash
export REFRESH_TOKEN="<refresh-token-from-login>"

curl -sS -X POST "$API_BASE_URL/auth/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"refresh_token\":\"$REFRESH_TOKEN\"}"
```

## 4) Public endpoints (no auth required)

### 4.1 Departments

```bash
curl -sS "$API_BASE_URL/public/departments"
```

### 4.2 Notices

```bash
curl -sS "$API_BASE_URL/public/notices"
```

### 4.3 Events

```bash
curl -sS "$API_BASE_URL/public/events"
```

## 5) Student endpoints (Bearer auth required)

> Use a token for a user with `student` role.

### 5.1 My profile

```bash
curl -sS "$API_BASE_URL/student/me" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### 5.2 My grades

```bash
curl -sS "$API_BASE_URL/student/me/grades" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### 5.3 My timetable

```bash
curl -sS "$API_BASE_URL/student/me/timetable" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

## 6) Staff/Admin-access student endpoints

> Requires role `staff` or `admin` (or `student` only for own record in role-guarded endpoints).

### 6.1 Student summary by ID (admin/staff)

```bash
curl -sS "$API_BASE_URL/student/admin/1" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### 6.2 Student grades by ID

```bash
curl -sS "$API_BASE_URL/student/1/grades" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### 6.3 Student timetable by ID

```bash
curl -sS "$API_BASE_URL/student/1/timetable" \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

## 7) Admin endpoint

### 7.1 Change user role

```bash
curl -sS -X PATCH "$API_BASE_URL/admin/users/2/role" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"role":"staff"}'
```

## 8) Error-handling tips

- `401 Unauthorized`: missing/invalid/expired token.
- `403 Forbidden`: token valid, but role is not allowed for endpoint.
- `404 Not Found`: referenced entity missing (for example, unknown student ID).
- `429 Too Many Requests`: login abuse protection or rate limiter thresholds exceeded.

## 9) OpenAPI reference

- API contract source: `backend/openapi/university-api.v1.yaml`
- Runtime interactive docs (default FastAPI):
  - Swagger UI: `http://localhost:8000/docs`
  - ReDoc: `http://localhost:8000/redoc`
