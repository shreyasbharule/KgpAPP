# University Student API (Backend Scaffold)

Security-focused FastAPI backend scaffold aligned with the OpenAPI contract baseline.

## Included capabilities

- Environment-based configuration with `.env` values only (no secrets hardcoded).
- Docker Compose stack for backend + PostgreSQL.
- Authentication (`/api/v1/auth/login`) with bcrypt password verification.
- Authorization guards with role-based access control (student/staff/admin).
- Global request rate limiting middleware.
- Basic login abuse protection (temporary block after repeated failures).
- Input validation for endpoint payloads and path parameters.
- Audit logging for sensitive actions:
  - Login success/failure/block
  - Admin role changes
  - Student record access
  - Grade view
- Unit tests for auth + RBAC + student endpoint.

## Folder structure

```text
backend/
├── app/
│   ├── api/
│   │   ├── admin.py
│   │   ├── auth.py
│   │   ├── deps.py
│   │   └── student.py
│   ├── core/
│   │   ├── config.py
│   │   └── security.py
│   ├── db/session.py
│   ├── middleware/rate_limiter.py
│   ├── models/
│   ├── schemas/
│   ├── services/
│   │   ├── abuse_protection.py
│   │   └── audit.py
│   └── main.py
├── migrations/
├── openapi/university-api.v1.yaml
├── tests/
├── docker-compose.yml
├── Dockerfile
└── .env.template
```

## Run with Docker Compose

```bash
cd backend
cp .env.template .env
docker compose up --build
```

API base URL: `http://localhost:8000`

### Apply SQL migrations in Docker

```bash
docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < migrations/001_init.sql
docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" < migrations/002_seed_admin.sql
```

## Run locally (without Docker)

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.template .env
# set DATABASE_URL for your local postgres if needed
psql "$DATABASE_URL" -f migrations/001_init.sql
psql "$DATABASE_URL" -f migrations/002_seed_admin.sql
uvicorn app.main:app --reload --port 8000
```

## Run tests

```bash
cd backend
pytest -q
```
