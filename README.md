# University Student App MVP

Production-oriented scaffold for a university mobile application and secure backend APIs.

## Deliverables Included

- Architecture overview and threat model: `docs/architecture.md`
- Technology stack decision and security defaults: `docs/stack-decision.md`
- Flutter mobile app scaffold with modular feature structure and secure session handling.
- FastAPI backend scaffold with JWT auth, RBAC, and audit logging.
- PostgreSQL SQL migration scripts under `backend/migrations/`.

## Mobile App (Flutter)

### Scaffold highlights

- Modular app structure by features (`auth`, `dashboard`, `institution`, `student`, `admin`, `profile`).
- API client with request/response interceptor pipeline.
- Secure token persistence using `flutter_secure_storage`.
- Session expiry + automatic refresh flow.
- Role-aware UI (admin actions hidden for non-admin users).
- Public content cached safely using `shared_preferences`; student data cached minimally in-memory with short TTL.
- Environment configuration (`dev` / `stage` / `prod`) via `--dart-define`.
- Basic themed UI for all core screens.

### Run instructions

1. Install Flutter SDK and platform toolchains.
2. Fetch packages:

```bash
flutter pub get
```

3. Run on Android emulator/device (dev):

```bash
flutter run \
  --flavor dev \
  --dart-define=APP_ENV=dev \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

4. Run on iOS simulator/device (stage example):

```bash
flutter run \
  -d ios \
  --dart-define=APP_ENV=stage \
  --dart-define=API_BASE_URL=https://stage-api.university.edu
```

5. Production build example:

```bash
flutter build apk --release --dart-define=APP_ENV=prod
flutter build ios --release --dart-define=APP_ENV=prod
```

> Note: if flavors are not configured yet in native projects, omit `--flavor` and use only `--dart-define` values.

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
