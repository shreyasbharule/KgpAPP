# Migration Strategy (Alembic + SQLAlchemy)

This backend is Python/FastAPI-based, so **Alembic** is the best fit for versioned PostgreSQL schema changes.

## Why Alembic for this backend

- Aligns with the existing FastAPI + SQLAlchemy stack.
- Produces deterministic, ordered migrations under version control.
- Supports both autogeneration (from models) and hand-written SQL for advanced indexes/constraints.
- Handles rollbacks via explicit `downgrade()` blocks.

## Recommended structure

- `backend/alembic.ini`
- `backend/alembic/env.py`
- `backend/alembic/versions/*.py`
- Existing SQL files in `backend/migrations/` can be preserved as a baseline and then ported into Alembic revisions.

## Rollout plan

1. **Baseline**
   - Create first Alembic revision representing current production schema (`001_init.sql` + `002_seed_admin.sql`).
   - Mark already-provisioned environments with `alembic stamp <baseline_revision>`.

2. **Add platform expansion**
   - Create a revision that applies the schema in `003_platform_expansion.sql`.
   - Prefer hand-authored SQL in `upgrade()` for enums, partial indexes, and check constraints.

3. **CI/CD gate**
   - Add a migration check step:
     - `alembic upgrade head` on ephemeral DB.
     - Optionally `alembic downgrade -1` smoke test where practical.

4. **Deploy safety**
   - For backwards-incompatible changes, use expand/contract:
     - expand schema (add nullable/new columns),
     - deploy app,
     - backfill,
     - enforce constraints in later migration.

## Example Alembic commands

```bash
cd backend
alembic init alembic
alembic revision -m "baseline schema"
alembic revision -m "platform expansion auth+student+admin"
alembic upgrade head
```

## Mapping from API contract to DB

The OpenAPI contract in `backend/openapi/university-api.v1.yaml` maps directly to the expanded schema in `backend/migrations/003_platform_expansion.sql`:

- Auth lifecycle: `auth_invites`, `refresh_tokens`, `password_reset_tokens`, `mfa_enrollments`
- Public info: `departments`, `contacts`, `notices`, `events`, `emergency_contacts`
- Student services: `student_timetable_entries`, `student_attendance`, `library_accounts` + enhanced `student_profiles`, `student_grades`, `fee_status`
- Admin/audit: enhanced `users`, `audit_logs`

