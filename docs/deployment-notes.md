# Deployment Notes (Cloud-Neutral)

This document outlines a cloud-neutral deployment approach for the backend API and mobile client integrations.

## 1) Recommended topology

- **Client apps** (mobile/web) call API over HTTPS.
- **Reverse proxy / ingress** terminates TLS and forwards to API service.
- **API service** runs stateless FastAPI instances.
- **PostgreSQL** is managed separately with backup and recovery controls.
- **Secret manager** stores JWT secret, DB credentials, and other sensitive values.

## 2) Reverse proxy guidance

Any mature proxy is acceptable (Nginx, HAProxy, Traefik, Envoy, managed ingress).

### Baseline requirements

- Terminate TLS at the edge.
- Forward `X-Forwarded-For`, `X-Forwarded-Proto`, and `Host` headers.
- Enforce request size and timeouts.
- Apply basic WAF/rate-limiting controls where available.
- Restrict methods to those needed (`GET`, `POST`, `PATCH` for this API).

### Suggested upstream behavior

- Use health-check endpoint: `/health`.
- Configure rolling updates with readiness checks.
- Enable keep-alive between proxy and app.

## 3) TLS recommendations

- Minimum TLS 1.2, prefer TLS 1.3.
- Use modern cipher suites and disable weak ciphers.
- Automate certificate provisioning and renewal (ACME or enterprise PKI).
- Enable HSTS for public domains.
- Redirect all HTTP traffic to HTTPS.

## 4) Secrets management

Never store production secrets in source control.

### Store externally

- `JWT_SECRET_KEY`
- `DATABASE_URL`
- DB user/password (if not embedded in DSN)
- Any future SMTP/MFA/integration credentials

### Operational controls

- Rotate secrets regularly and after incidents.
- Use least-privilege access policies for operators/services.
- Audit secret access logs.
- Prefer short-lived credentials where platform supports it.

## 5) Database deployment and backups

### Baseline DB controls

- Private network exposure only.
- Enforce TLS for DB connections where supported.
- Separate DB users by function (app runtime vs migrations/ops).
- Enable point-in-time recovery (PITR) when available.

### Backup policy (minimum)

- Nightly full backup + frequent WAL/transaction-log archiving.
- Retention policy aligned to legal/business requirements.
- Cross-zone or cross-region backup replication.
- Monthly restore drill in non-production to verify integrity.

### Suggested RPO/RTO starting point

- **RPO**: <= 15 minutes
- **RTO**: <= 4 hours

Adjust based on institutional SLA and budget.

## 6) Deployment pipeline expectations

- Build immutable artifact/container image.
- Run automated tests before deployment.
- Apply SQL migrations in controlled stage (idempotent/reviewed).
- Deploy progressively (rolling/canary) with rollback path.
- Validate `/health` and a smoke-test login flow post-deploy.

## 7) Environment configuration checklist

- [ ] `APP_ENV` set correctly (`development` / `stage` / `production` naming convention).
- [ ] `CORS_ORIGINS` limited to known client origins.
- [ ] `ACCESS_TOKEN_EXPIRE_MINUTES` policy reviewed by security.
- [ ] Rate-limiter values tuned for real traffic.
- [ ] Proxy and app logs integrated with central observability.

## 8) Hardening recommendations

- Run app as non-root user.
- Use read-only container filesystem where practical.
- Pin dependency versions and scan for vulnerabilities.
- Restrict egress network policies to required destinations only.
- Keep OS/runtime patched with regular maintenance windows.
