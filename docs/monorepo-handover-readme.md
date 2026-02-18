# Monorepo Handover README

This document summarizes how to set up, run, and test the University Student App monorepo (Flutter mobile app + FastAPI backend), and lists the key environment variables needed for day-1 handover.

## 1) Repository structure

- `lib/`, `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`: Flutter client application.
- `backend/`: FastAPI API service, migrations, and backend tests.
- `docs/`: Architecture and operations/security documentation.

## 2) Prerequisites

### Client (Flutter)

- Flutter SDK (stable channel)
- Android Studio/Xcode toolchains for target platforms
- A running backend API endpoint for non-demo mode

### Backend (FastAPI)

- Python 3.11+
- PostgreSQL 14+
- `psql` CLI

## 3) Local setup

### 3.1 Flutter app

```bash
flutter pub get
```

Run in development:

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

> If you use emulator/network alternatives, replace `API_BASE_URL` accordingly.

### 3.2 Backend API

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.template .env
```

Apply DB migrations/seeds:

```bash
psql "$DATABASE_URL" -f migrations/001_init.sql
psql "$DATABASE_URL" -f migrations/003_platform_expansion.sql
psql "$DATABASE_URL" -f migrations/004_seed_demo_data.sql
```

Run backend:

```bash
uvicorn app.main:app --reload --port 8000
```

Health check:

```bash
curl http://localhost:8000/health
```

## 4) Running tests

### Flutter tests

```bash
flutter test
```

### Backend tests

```bash
cd backend
pytest -q
```

## 5) Environment variables

Backend configuration is loaded from `.env` using Pydantic settings.

| Variable | Required | Description | Example |
|---|---|---|---|
| `APP_ENV` | No | Runtime environment label | `development` |
| `APP_NAME` | No | API display name | `University Student API` |
| `APP_VERSION` | No | API semantic version | `1.0.0` |
| `DATABASE_URL` | Yes | SQLAlchemy PostgreSQL DSN | `postgresql+psycopg2://user:pass@host:5432/db` |
| `JWT_SECRET_KEY` | Yes | JWT signing secret (>=32 chars) | `<from secret manager>` |
| `JWT_ALGORITHM` | No | JWT algorithm | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | No | Access token TTL in minutes | `30` |
| `CORS_ORIGINS` | No | Comma-separated allowed origins | `http://localhost:3000,http://localhost:8080` |
| `RATE_LIMIT_REQUESTS` | No | Allowed requests in rate window | `120` |
| `RATE_LIMIT_WINDOW_SECONDS` | No | Global rate limit window | `60` |
| `LOGIN_MAX_ATTEMPTS` | No | Max login failures before temporary block | `5` |
| `LOGIN_BLOCK_SECONDS` | No | Temporary lockout period after abuse | `300` |

Optional local DB vars used by Docker Compose template:

- `POSTGRES_DB`
- `POSTGRES_USER`
- `POSTGRES_PASSWORD`

## 6) Demo credentials (seeded non-production data)

- `student@university.edu` / `StudentPass123!`
- `faculty@university.edu` / `FacultyPass123!`
- `admin@university.edu` / `AdminPass123!`

## 7) Handover checklist

- [ ] Confirm secrets are sourced from a secret manager (not checked into git).
- [ ] Confirm migration execution in the target environment.
- [ ] Confirm CORS origins for deployed client URLs.
- [ ] Confirm JWT key rotation process is documented.
- [ ] Confirm monitoring and incident contacts are up to date.
