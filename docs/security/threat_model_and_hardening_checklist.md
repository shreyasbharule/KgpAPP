# University Student App: Threat Model & Security Hardening Checklist

This checklist is tailored to the current Flutter mobile + FastAPI backend architecture.

## 1) Scope and assets

**Primary assets**
- Student PII and academic records (profile, grades, timetable, fees/library proxies).
- Credentials, JWT access/refresh tokens, session metadata.
- Administrative capabilities (role change, student-record access).
- Audit trails and security telemetry.

**Trust boundaries**
- Mobile device and app runtime.
- Public network between app and API.
- API tier and authorization layer.
- Database and logs.

## 2) Threat model (required threat categories)

| Threat | Where it applies in this app | Current posture | Production hardening checklist |
|---|---|---|---|
| Credential theft | Login API, reused passwords, phishing, device malware | Login abuse blocking and generic invalid-credential response are present. | Add MFA (TOTP/push), breached-password checks, risk-based auth, impossible-travel alerts. |
| Token leakage | Mobile logs, proxy tools, crash dumps, local backup extraction | Tokens use secure storage; access tokens are short-lived and refresh flow exists. | Rotate refresh tokens per use, hash refresh tokens server-side, bind tokens to device/session, implement revocation list and replay detection. |
| Insecure storage | Device persistence and local caches | Sensitive tokens are in `flutter_secure_storage`; student cache is memory-only with short TTL. | Add root/jailbreak checks, disable screenshots on sensitive screens, biometric re-auth for high-risk actions, secure backup policy. |
| Broken access control | API role bypass, weak default policies | Backend uses `role_required` guards and denies on role mismatch. | Add fine-grained ABAC (faculty assignment/ownership at query layer), central policy tests, and deny-by-default service-layer checks. |
| IDOR | Endpoints with `student_id` path params | Student self-access checks exist on grades/timetable APIs. | Use opaque identifiers externally, enforce row-level scoping in all data fetches, return ambiguity-safe 404 where appropriate. |
| MITM | Mobile ↔ API transport | HTTPS expected by config, CORS allowlist exists at API. | Enforce TLS 1.2+, cert pinning in mobile, HSTS on edge, strict proxy/load balancer TLS configuration. |
| Logging leaks | Auth/audit events and exception paths | Audit logging is implemented for auth/admin/student events. | Redact tokens/passwords/PII centrally, structured log schema with redaction filters, log retention + immutable archive. |
| Injection | API inputs, query parameters, potential SQL/command injection | SQLAlchemy ORM + Pydantic models reduce common injection risk. | Add strict request size/type validation, centralized output encoding, semgrep rules for dangerous dynamic execution paths. |
| Enumeration | User existence probing via login and student endpoints | Login errors are generic; rate limiting + abuse throttling are present. | Keep response timing and message parity, add account/IP progressive throttling, protect forgot-password and user-lookup endpoints similarly. |
| Scraping / bulk extraction | Public endpoints and privileged data reads | Global per-IP+path rate limiter exists. | Add per-token/user quotas, bot detection, response watermarking for exports, anomaly detection on high-volume reads. |
| Device compromise | Rooted devices, malware, token exfiltration | Secure storage mitigates baseline local extraction risk. | Device posture checks, remote session kill, forced re-auth on risk signals, minimize offline sensitive data footprint. |

## 3) Mitigations already implemented

### Backend
- Password hashing via bcrypt and JWT signing/verification with expiry.
- Role-based route guards (`student`, `staff`, `admin`) and explicit 403 on mismatch.
- Login abuse controls (attempt caps + temporary blocking).
- Rate-limiting middleware (IP + path windowing).
- Audit logging for login, token refresh, profile/record reads, and admin role changes.
- CORS allowlist configured from environment settings.

### Mobile
- Session tokens persisted in platform secure storage (not `SharedPreferences`).
- Access token attachment via interceptor and refresh-on-401 flow.
- Public cache in local prefs with timestamp; student cache is in-memory short TTL.

## 4) Recommended production hardening backlog

## P0 (before broad rollout)
- Enforce refresh-token rotation + server-side hashed storage + family revocation.
- Move from in-memory abuse/rate-limit state to shared store (Redis) for multi-instance deployments.
- Introduce MFA for admins/staff first, then students.
- Add secrets management + key rotation SOP (JWT keys, DB creds, third-party tokens).
- Implement centralized log redaction and sensitive-field denylist.

## P1 (early production)
- Certificate pinning in mobile and stricter TLS policies on edge.
- Fine-grained authorization (ABAC) for faculty/student/resource relationships.
- Export controls: justification, watermarking, dual-approval for high-risk datasets.
- Device risk controls: root/jailbreak signal, step-up auth, remote logout.

## P2 (maturity)
- SIEM integration with alert tuning for auth anomalies and data exfil indicators.
- Tamper-evident audit pipeline with retention/legal-hold controls.
- Data minimization and automated retention/purge workflows by data class.

## 5) Security testing plan

### SAST (CI gate)
- Python: Bandit + Semgrep (auth, JWT, SQL, logging rules).
- Flutter/Dart: `dart analyze` + Semgrep Dart rules for insecure storage/logging and unsafe network behavior.
- Secrets scanning: Gitleaks/TruffleHog on every PR and protected branch.

### Dependency and supply-chain scanning
- Python: `pip-audit` and `safety` for transitive dependency CVEs.
- Flutter: `flutter pub outdated` + OSS vulnerability feed checks.
- Container: Trivy/Grype on backend image.
- SBOM generation (CycloneDX/SPDX) and artifact signing for release builds.

### DAST / API security testing
- Authenticated/unauthenticated API scan (OWASP ZAP/Burp) against staging.
- Fuzz key endpoints (`/auth/login`, `/auth/refresh`, `/student/*`, `/admin/*`) for auth bypass, schema confusion, and rate-limit bypass.
- Verify CORS behavior, HTTP header hygiene, and TLS config externally.

### Pentest focus areas (most relevant)
- Broken access control and IDOR across all `student_id`-based routes.
- Token lifecycle attacks: refresh replay, token theft, revocation gaps.
- Enumeration and brute-force resistance on auth and account-recovery flows.
- Data exfiltration vectors via scraping/export and log leakage.
- Mobile reverse engineering and runtime tampering (certificate pinning bypass, token extraction from compromised devices).

## 6) Compliance readiness notes (FERPA-like and Indian context; not legal advice)

> This section is implementation guidance only, not legal advice.

### FERPA-like principles to operationalize
- **Purpose limitation:** expose student records only for academic/support purposes tied to role.
- **Data minimization:** avoid collecting/storing fields not required for app workflows.
- **Access transparency:** maintain auditable access logs for who viewed/changed student records.
- **Correction workflow:** enable controlled correction requests and tracked approval steps.
- **Retention controls:** define retention and deletion schedules by record category.

### India context readiness (practical engineering checklist)
- Build for consent notice, purpose specification, and revocation flows in user journeys.
- Support parental/guardian or institutional authority workflows where policy requires.
- Implement incident response runbooks (detection, containment, notification decision logs).
- Keep data residency and cross-border transfer controls configurable at infrastructure level.
- Classify education records as high-sensitivity and apply least-privilege + encryption in transit/at rest.

## 7) Quick go-live checklist

- [ ] MFA enforced for privileged users.
- [ ] Refresh token rotation + revocation + replay detection live.
- [ ] Centralized throttling (Redis/API gateway) enabled.
- [ ] Log redaction and retention controls validated.
- [ ] ABAC/ownership checks test-covered for all record endpoints.
- [ ] SAST/DAST/dependency scans green in CI.
- [ ] External pentest closed for critical/high findings.
- [ ] Incident response drill and access-review cadence documented.
