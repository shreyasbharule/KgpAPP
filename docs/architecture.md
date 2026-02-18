# University Student App MVP Architecture

## 1) Components

### Mobile Client (Flutter)
- **Presentation layer:** Login, Institution info, Student services shell.
- **Application layer:** Auth service and API client wrappers.
- **Security controls:**
  - Token stored in OS secure enclave/keystore (`flutter_secure_storage`).
  - No embedded credentials or API keys.
  - Generic user-facing auth errors (no sensitive backend details).

### API Layer (FastAPI)
- `/api/v1/auth/login`: password verification + JWT issuance.
- `/api/v1/student/me`: student-only endpoint.
- `/api/v1/student/admin/{student_id}`: admin/staff endpoint.
- Dependency-based RBAC guard and centralized token validation.

### Data Layer (PostgreSQL)
- Users + role enum.
- Student profile and academic/fee support tables.
- Append-style audit log for sensitive actions.

## 2) Data Flow

1. Student submits credentials in the mobile app.
2. API verifies password hash and returns short-lived JWT.
3. Mobile stores JWT in secure storage and sends `Authorization: Bearer <token>`.
4. API decodes JWT, resolves user, applies role guard.
5. Authorized resource is returned; audit record is persisted.

## 3) Threat Model Summary

### Assets
- Student PII, attendance, grades, fee/library information, authentication secrets.

### Primary Threats
- Credential stuffing / brute force login.
- Token theft on compromised devices.
- Broken access control (role bypass, IDOR).
- Excessive sensitive logging.
- API misuse from untrusted origins.

### Mitigations in this MVP Scaffold
- Password hashing with bcrypt.
- JWT with expiration and server-side signature verification.
- RBAC gate per endpoint; default deny if role mismatch.
- Audit logging for login and profile reads.
- Secure token storage on-device.
- Config via environment variables (no secret in source).
- CORS allow-list support.

### Recommended Next Steps for Production
- Add MFA/SSO with university IdP (SAML/OIDC).
- Add refresh tokens + revocation list.
- Add rate limiting and bot/abuse detection.
- Add field-level encryption for highly sensitive columns.
- Add SIEM integration and immutable audit pipeline.

## 4) Security Policy Reference

- RBAC, data classification, retention, and endpoint authorization policy: `docs/security/rbac_and_data_governance.md`.
