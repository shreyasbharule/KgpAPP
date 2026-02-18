# University Student API (Backend Scaffold)

Security-focused FastAPI backend with real auth refresh flow, public institutional feeds, and student read-only academic endpoints.

## Included capabilities

- JWT login + refresh (`/api/v1/auth/login`, `/api/v1/auth/refresh`).
- Role-based access control (student/faculty/staff/admin).
- Public endpoints for university content:
  - `/api/v1/public/departments`
  - `/api/v1/public/notices`
  - `/api/v1/public/events`
- Student endpoints:
  - `/api/v1/student/me`
  - `/api/v1/student/me/timetable`
  - `/api/v1/student/me/grades`
- Global rate limiting and login abuse protection.
- Audit logging for auth and sensitive student/admin reads.
- Seed SQL for demo users + demo university data.

## Run locally

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.template .env
psql "$DATABASE_URL" -f migrations/001_init.sql
psql "$DATABASE_URL" -f migrations/003_platform_expansion.sql
psql "$DATABASE_URL" -f migrations/004_seed_demo_data.sql
uvicorn app.main:app --reload --port 8000
```

## Demo users

- `student@university.edu` / `StudentPass123!`
- `faculty@university.edu` / `FacultyPass123!`
- `admin@university.edu` / `AdminPass123!`

## Run tests

```bash
cd backend
pytest -q
```
