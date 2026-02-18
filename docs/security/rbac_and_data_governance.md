# University App RBAC, Data Classification, and API Authorization Policy

This policy defines **least-privilege** access for the current university app (Flutter + FastAPI) and can be implemented directly with the existing role-guard pattern in `backend/app/api/deps.py`.

## 1) RBAC roles

### Canonical roles
- **Public**: Unauthenticated users.
- **Student**: Authenticated student account, access limited to own records.
- **Faculty**: Authenticated teaching staff, access limited to students/courses assigned to them.
- **Admin**: Split by scope for least privilege:
  - **Registrar Admin**: Student-record lifecycle and academic administration.
  - **IT Admin**: Identity/access, system configuration, and security operations.

> Implementation note: keep a single `admin` enum in DB if needed, and enforce `admin_scope` claims/attributes (`registrar`, `it`) in authorization checks.

---

## 2) Permission matrix (role × actions)

Legend: ✅ allowed, ❌ denied, ◑ conditional (must pass ownership/scope checks)

| Action | Public | Student | Faculty | Registrar Admin | IT Admin |
|---|---:|---:|---:|---:|---:|
| View institution public pages, announcements, map, calendar | ✅ | ✅ | ✅ | ✅ | ✅ |
| Login | ✅ | ✅ | ✅ | ✅ | ✅ |
| View own profile (`student/me`) | ❌ | ✅ | ❌ | ❌ | ❌ |
| Update own contact info (email/phone/address) | ❌ | ✅ | ❌ | ◑ (on request/ticket) | ❌ |
| View own attendance/grades/fees/library status | ❌ | ✅ | ❌ | ◑ (support case only) | ❌ |
| View another student profile | ❌ | ❌ | ◑ (assigned advisees/courses only) | ✅ | ❌ |
| Edit grades | ❌ | ❌ | ◑ (only courses they teach, within grading window) | ◑ (correction workflow, dual approval) | ❌ |
| Update attendance | ❌ | ❌ | ◑ (only assigned sections) | ✅ | ❌ |
| Manage enrollments/course registrations | ❌ | ❌ | ❌ | ✅ | ❌ |
| Manage student status (admit/leave/graduate) | ❌ | ❌ | ❌ | ✅ | ❌ |
| Create/disable user accounts | ❌ | ❌ | ❌ | ❌ | ✅ |
| Reset passwords / enforce MFA policy | ❌ | ❌ | ❌ | ❌ | ✅ |
| Assign/revoke roles | ❌ | ❌ | ❌ | ❌ | ✅ |
| Access audit logs | ❌ | ❌ | ❌ | ◑ (read limited records tied to registrar ops) | ✅ |
| Export student dataset | ❌ | ❌ | ◑ (aggregated/pseudonymized by default) | ◑ (approved purpose + watermark) | ◑ (security/legal purpose only) |
| Configure integrations/secrets/system settings | ❌ | ❌ | ❌ | ❌ | ✅ |

### Core enforcement rules
1. **Default deny**: any action not explicitly allowed is denied.
2. **Ownership check**: student can read only `resource.user_id == current_user.id`.
3. **Faculty assignment check**: faculty can access only students linked by `faculty_course_assignment` and active term.
4. **Admin scope check**: registrar and IT permissions are disjoint unless explicitly approved.
5. **Step-up controls** for sensitive actions: strong auth + audit + reason code.

---

## 3) Data classification table

| Data type | Examples | Classification | Access baseline | Security controls |
|---|---|---|---|---|
| Public institutional content | Campus map, event calendar, public notices | **Public** | Anyone | Integrity checks; CMS change audit |
| Internal operational metadata | Non-sensitive service logs, feature flags, anonymized usage metrics | **Internal** | IT Admin; limited DevOps | Access via VPN/admin network; retention limits |
| Student directory/basic profile | Name, roll number, department, semester, university email | **Confidential** | Student (self), assigned Faculty, Registrar Admin | RBAC + row-level checks + audit on read/write |
| Academic records | Grades, transcripts, attendance, exam outcomes | **Highly Confidential** | Student (self-read), assigned Faculty (course scope), Registrar Admin | Strict RBAC, immutable audit, approval workflow for edits |
| Financial/student account records | Fee balance, payment refs, scholarships, fines | **Highly Confidential** | Student (self), Registrar Admin/Finance role only | Need-to-know, masked displays, export controls |
| Identity/authentication data | Password hashes, MFA secrets, token/session metadata | **Highly Confidential** | IT Admin/security services only | Encryption at rest/in transit, no plaintext exposure |
| Government IDs / sensitive personal data | National ID/passport, disability/health accommodations (if stored) | **Highly Confidential** | Registrar Admin (case-based), designated compliance staff | Field-level encryption, strict purpose binding, short retention |
| Audit/security logs | Auth events, privilege changes, data access trails | **Confidential** (content-dependent) | IT Admin; Registrar read subset | Append-only storage, tamper evidence, SIEM forwarding |

---

## 4) Privacy and retention rules by student-data category

| Student-data category | Privacy rule (collection/use/share) | Retention | Disposal/archival |
|---|---|---|---|
| Account identity (name, roll, email, role) | Collect minimum needed for identity and academic operations; no external sharing except required institutional/legal processes | Active enrollment + **7 years** | Archive with restricted access; secure delete after retention expires |
| Contact information | Student self-service updates preferred; disclose only for official communication and emergency/legal basis | Active enrollment + **2 years** | Purge or anonymize unless legal hold exists |
| Attendance records | Use only for course progression/compliance; faculty write access limited to assigned sections | Current term + **5 years** | Archive read-only; purge at term+5y unless policy/legal hold |
| Grades/transcripts | Use for academic evaluation and certification only; corrections require controlled workflow and audit | Permanent transcript record; working gradebooks **7 years** | Permanent transcript archive; working records purged per schedule |
| Financial records | Use only for billing/payment/scholarship operations; minimal staff visibility | Fiscal close + **7 years** (or jurisdictional requirement) | Encrypted archive; purge after statutory period |
| Disciplinary/support case notes | Access strictly case-based and role-restricted; avoid over-collection | Case close + **5 years** | Restricted archive then purge; maintain legal hold capability |
| Authentication/security logs tied to student actions | Purpose limited to security, incident response, and compliance | **1 year hot** + **2 years cold** (aggregated where possible) | Immutable archive then secure deletion |
| Student-submitted documents (certificates/forms) | Collect only required documents; malware scan on upload; no secondary use | Decision/event close + **2 years** unless needed longer | Delete originals when no longer needed; retain metadata trail |

### Privacy guardrails
- Purpose limitation and data minimization are mandatory.
- Consent/notice required where policy or law requires it.
- Any bulk export requires documented business purpose, approver, and expiration.
- DSAR-style capabilities (access/correction) should be routed via Registrar workflow.

---

## 5) API authorization rules (endpoint-level)

The following rules align with existing endpoints and extend them in an implementable way.

## Existing endpoints in this repository

| Endpoint | Method | Public | Student | Faculty | Registrar Admin | IT Admin | Notes |
|---|---|---:|---:|---:|---:|---:|---|
| `/api/v1/auth/login` | POST | ✅ | ✅ | ✅ | ✅ | ✅ | Unauthenticated allowed; rate limit + lockout recommended |
| `/api/v1/student/me` | GET | ❌ | ✅ | ❌ | ❌ | ❌ | Must enforce `user.role == student` and `user_id == token.sub` |
| `/api/v1/student/admin/{student_id}` | GET | ❌ | ❌ | ❌ (current) | ✅ | ❌ (unless break-glass) | Replace broad `staff/admin` with scope-based admin check |

## Recommended near-term endpoints/rules

| Endpoint | Method | Authorization rule |
|---|---|---|
| `/api/v1/student/{student_id}` | GET | Student: self only; Faculty: assigned-student only; Registrar: all; IT: denied |
| `/api/v1/student/{student_id}/attendance` | PUT | Faculty: assigned-section only; Registrar: allowed; others denied |
| `/api/v1/student/{student_id}/grades` | PUT | Faculty: assigned-course + grading window; Registrar: correction workflow only |
| `/api/v1/admin/users/{user_id}/role` | PATCH | IT Admin only; require MFA + reason + audit event |
| `/api/v1/admin/users/{user_id}/reset-password` | POST | IT Admin only; audit and notify user |
| `/api/v1/audit/events` | GET | IT Admin full; Registrar filtered subset by domain/resource |
| `/api/v1/reports/student-export` | POST | Registrar/IT by policy with async job, approval id, watermark |

### Authorization implementation contract (FastAPI)

1. **Token claims**: include `sub`, `role`, and optional `admin_scope`.
2. **Dependency guards**: keep `role_required(...)` and add:
   - `scope_required(...)` for admin scope.
   - `ownership_required(resource_user_id)` for student self-access.
   - `faculty_assignment_required(student_id, course_id)` for faculty-limited access.
3. **Audit on sensitive actions**: login, profile reads, grade changes, role changes, exports.
4. **Consistent deny response**: `403` for unauthorized, `404` when resource existence should be hidden.
5. **No privilege by client hint**: never trust client-provided role/department/student id without server-side validation.

### Minimal policy constants (example)

```python
ROLE_STUDENT = "student"
ROLE_FACULTY = "faculty"
ROLE_ADMIN = "admin"

SCOPE_REGISTRAR = "registrar"
SCOPE_IT = "it"
```

---

## 6) Rollout plan (practical)

1. **Phase 1**: codify endpoint matrix and deny-by-default checks in backend dependencies.
2. **Phase 2**: add faculty assignment table + checks; remove broad staff access.
3. **Phase 3**: add admin scope claim and split registrar vs IT operations.
4. **Phase 4**: enforce retention schedules via periodic archival/purge jobs and legal-hold tags.
5. **Phase 5**: add export approval workflow + immutable audit verification.

This gives immediate least-privilege controls while staying compatible with the current MVP codebase.
