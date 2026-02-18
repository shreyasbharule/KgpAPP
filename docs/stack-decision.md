# Technology Stack Decision

## 1) Final stack choice

After evaluating the allowed options against security and maintainability needs, the selected stack is:

- **Mobile:** Flutter (Dart)
- **Backend:** Python FastAPI
- **Database:** PostgreSQL
- **Auth:** OAuth2/OIDC-aligned JWT access tokens + rotating refresh tokens, with MFA-ready enrollment/challenge flows
- **Infrastructure:** Docker Compose for local development; cloud-neutral containers deployable to any Kubernetes or VM-based environment

### Why this stack fits

- **Flutter** supports high-quality cross-platform mobile delivery from a single codebase and already matches the current repository baseline.
- **FastAPI** provides strong typing, fast async APIs, and built-in OpenAPI for secure API contracts and easier client generation.
- **PostgreSQL** is a mature relational database with robust ACID guarantees, constraints, indexing, and row-level security options.
- **JWT + refresh token pattern** supports modern mobile auth ergonomics while preserving strong revocation controls when refresh tokens are persisted server-side.
- **Docker Compose + containerized services** keeps local dev consistent and cloud provider lock-in low.

## 2) Monorepo folder structure

```text
KgpAPP/
├─ apps/
│  └─ mobile/                    # Flutter app
│     ├─ lib/
│     ├─ assets/
│     └─ test/
├─ services/
│  └─ api/                       # FastAPI backend
│     ├─ app/
│     │  ├─ api/
│     │  ├─ core/
│     │  ├─ auth/
│     │  ├─ models/
│     │  ├─ schemas/
│     │  └─ services/
│     ├─ migrations/
│     ├─ tests/
│     └─ requirements.txt
├─ infra/
│  ├─ docker/
│  │  ├─ api.Dockerfile
│  │  └─ mobile.Dockerfile
│  └─ compose/
│     └─ docker-compose.yml      # api + postgres + optional redis
├─ docs/
│  ├─ architecture.md
│  └─ stack-decision.md
├─ .env.example
└─ README.md
```

## 3) Key libraries/packages

### Mobile (Flutter)

- `dio` (HTTP client with interceptors)
- `flutter_secure_storage` (encrypted at-rest token storage)
- `riverpod` or `flutter_bloc` (predictable state management)
- `go_router` (typed navigation and route guards)
- `freezed` + `json_serializable` (immutable models and safe serialization)
- `local_auth` (biometric unlock for local session re-auth)

### Backend (FastAPI)

- `fastapi`, `uvicorn` (API framework/runtime)
- `pydantic-settings` (typed environment config)
- `sqlalchemy` + `alembic` (ORM + migrations)
- `psycopg` (Postgres driver)
- `python-jose` or `PyJWT` (JWT signing/validation)
- `passlib[bcrypt]` or `argon2-cffi` (password hashing)
- `httpx` (OIDC provider communication)
- `slowapi` or `fastapi-limiter` (rate limiting)
- `structlog` (structured logging)

### Data/infra

- PostgreSQL 15+
- Redis (optional, recommended for rate limits, token denylist, and short-lived OTP/MFA challenges)
- Docker and Docker Compose

## 4) Security defaults

### Token handling

- Access tokens: short TTL (10–15 min), audience/issuer validated, minimal claims.
- Refresh tokens: long TTL (7–30 days), **rotated on every refresh**, hashed before DB persistence, device/session-bound metadata captured.
- Reuse detection: if an old refresh token is replayed, revoke token family and force re-authentication.

### Mobile storage and transport

- Store tokens only in platform-secure storage (`flutter_secure_storage`), never in SharedPreferences.
- Enforce TLS for all API traffic; pin certificates in high-risk deployments.
- Avoid logging PII or tokens in mobile logs/crash reports.

### Password and credential security

- Password hashing with Argon2id (preferred) or bcrypt with strong cost factor.
- Server-side password policy and breached-password checks where feasible.
- MFA readiness: TOTP + recovery codes data model, with backup channel hooks (email/SMS) abstracted via provider adapters.

### API hardening

- Rate limiting by IP + account + endpoint sensitivity tier.
- Strict input validation with Pydantic schemas.
- RBAC/ABAC authorization checks at route and service layers.
- CORS allowlist by environment; deny-by-default origins.
- Security headers and request size/time limits.

### Secrets/configuration

- No hardcoded secrets in source.
- Load config from environment variables and secret stores in production (Vault, AWS/GCP/Azure secret managers).
- Separate keys per environment; scheduled secret rotation.

### Logging and audit

- Structured logs with correlation IDs.
- Audit trail for login, token refresh, privilege changes, profile updates, grade/fees access, and admin operations.
- Centralized log retention with integrity controls; redact PII/token fields.

### Cloud-neutral hosting pattern

- Build OCI images for `api` and supporting workers.
- Run behind reverse proxy/load balancer (Nginx/Traefik/Cloud LB).
- Deploy to Kubernetes (any cloud) or Docker hosts.
- Use managed or self-hosted Postgres; apply least-privilege DB roles and network segmentation.
