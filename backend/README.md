# University Student API (MVP Scaffold)

Security-focused FastAPI backend scaffold that provides authentication, RBAC, student data endpoints, and audit logging.

## Features

- JWT authentication (`/api/v1/auth/login`)
- Role-based access control for student and admin/staff endpoints
- Audit logging for login and profile reads
- PostgreSQL schema migration scripts
- Environment-based configuration (no hardcoded secrets)

## Local Run

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# update JWT_SECRET_KEY and DATABASE_URL in .env
psql "$DATABASE_URL" -f migrations/001_init.sql
psql "$DATABASE_URL" -f migrations/002_seed_admin.sql
uvicorn app.main:app --reload --port 8000
```

## Security Notes

- Use HTTPS in all non-local environments.
- Rotate and manage JWT secret via a secret manager.
- Keep access token lifetime short and add refresh tokens before production.
- Restrict CORS origins to trusted university domains.
- Store audit logs in append-only storage for compliance workflows.

## API and Schema Design Artifacts

- OpenAPI 3.0 spec: `openapi/university-api.v1.yaml`
- Expanded PostgreSQL schema migration: `migrations/003_platform_expansion.sql`
- Migration approach (Alembic): `docs/migration_strategy.md`
