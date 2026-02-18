# University Student App MVP

Production-oriented scaffold for a university mobile application and secure backend APIs.

## Deliverables Included

- Architecture overview and threat model: `docs/architecture.md`
- Flutter mobile app scaffold with modular structure and secure token storage.
- FastAPI backend scaffold with JWT auth, RBAC, and audit logging.
- PostgreSQL SQL migration scripts under `backend/migrations/`.

## Mobile App (Flutter)

### Features scaffolded
- Institutional information hub:
  - Directory
  - Campus map link
  - Events
  - Notices
  - FAQs
  - Emergency contacts
- Student services hub:
  - Profile
  - Timetable
  - Attendance
  - Grades/results
  - Fee status
  - Library
  - Certificates

### Run locally

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Backend API (FastAPI)

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# update DATABASE_URL and JWT_SECRET_KEY
psql "$DATABASE_URL" -f migrations/001_init.sql
psql "$DATABASE_URL" -f migrations/002_seed_admin.sql
uvicorn app.main:app --reload --port 8000
```

Health check:

```bash
curl http://localhost:8000/health
```

## Security-First Design Choices

- Environment-driven configuration (no hardcoded runtime secrets).
- Secure token storage on device (`flutter_secure_storage`).
- Role-based access control in backend dependencies.
- Password hashing using bcrypt.
- Short-lived JWT access tokens.
- Audit logging for sensitive actions.
- Principle of least privilege by role-specific endpoint guards.

## Assumptions

- University can later integrate SIS/LMS/Library via service adapters in backend.
- Current build is MVP scaffold ready for integration hardening and CI/CD.
