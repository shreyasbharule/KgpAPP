# Mobile App Information Architecture and Screen Design

## Scope and Principles
- Primary audiences: prospective users (public information) and authenticated students (personal academic and account data).
- Security principle: public content is broadly cacheable; student content is fetched on demand, minimized at rest, and protected via secure storage.
- Navigation principle: keep top-level tabs task-oriented and reserve deep nested navigation for detail screens.

---

## 1) Screen List and Navigation Map

### A. App Entry and Auth Flow
1. **Splash / Session Bootstrap**
   - Checks app config, network reachability, and auth token validity.
2. **Onboarding Carousel**
   - Intro slides: key features, privacy statement, offline behavior.
3. **Login Screen**
   - Email/password login + forgot password + SSO placeholder button.
4. **MFA Challenge (Optional Placeholder)**
   - OTP/TOTP code input, resend option, fallback support contact.
5. **Reset Password (if needed)**
   - Token + new password flow.

### B. Post-Login Main App Shell (Bottom Tabs)
1. **Home**
   - Personalized greeting, latest notices, upcoming events, quick links.
2. **Institution**
   - Public directory, departments, campus maps, emergency contacts.
3. **Student**
   - Authenticated student services hub.
4. **Settings**
   - Privacy preferences, logout, help, feedback.

### C. Home Branch
- **Home Dashboard**
  - Notice cards (pin/high-priority), event timeline, "view all" actions.
- **Notices List**
- **Notice Detail**
- **Events List**
- **Event Detail**

### D. Institution Branch
- **Institution Landing** (cards to directory/departments/maps/emergency)
- **Directory List**
- **Directory Contact Detail**
- **Departments List**
- **Department Detail**
- **Campus Maps & Links**
  - Building map links, route launching in external maps app.
- **Emergency Information**
  - Emergency numbers, after-hours process, one-tap call action.

### E. Student Branch
- **Student Hub** (tiles + status badges)
- **Profile**
- **Timetable**
- **Grades**
- **Attendance**
- **Fees**
- **Library**

### F. Settings Branch
- **Settings Landing**
- **Privacy & Security**
  - Session/device management summary and data handling summary.
- **Help & Support**
- **Feedback Submission**
- **Logout Confirmation Modal**

### Navigation Map (Text Diagram)
```text
Splash
 ├─(first launch)→ Onboarding → Login
 └─(has valid session)→ Main Shell (Tabs)

Login
 ├─ success (no MFA) → Main Shell
 ├─ success (MFA enabled) → MFA Challenge → Main Shell
 └─ forgot password → Reset Password → Login

Main Shell
 ├─ Home
 │   ├─ Notices List → Notice Detail
 │   └─ Events List → Event Detail
 ├─ Institution
 │   ├─ Directory → Contact Detail
 │   ├─ Departments → Department Detail
 │   ├─ Maps & Links
 │   └─ Emergency
 ├─ Student
 │   ├─ Profile
 │   ├─ Timetable
 │   ├─ Grades
 │   ├─ Attendance
 │   ├─ Fees
 │   └─ Library
 └─ Settings
     ├─ Privacy & Security
     ├─ Help
     ├─ Feedback
     └─ Logout
```

---

## 2) Data Flow per Screen (API Calls + State Management Plan)

## State Management Strategy
- **Recommended approach**: feature-based architecture with `Riverpod` (or `BLoC` equivalent) and repository pattern.
- **Layers**:
  - `ApiClient` (HTTP + auth headers + retry policy)
  - `Repository` per domain (`AuthRepository`, `PublicInfoRepository`, `StudentRepository`)
  - `State providers/notifiers` per screen/view model
  - `UI` consumes immutable state (`loading/success/empty/error`)
- **Caching tiers**:
  - Memory cache for current session.
  - Disk cache (public data only, TTL-based).
  - Secure storage for auth tokens; avoid persistent storage for sensitive student data unless explicitly required and encrypted.

### A. Auth Screens
- **Login**
  - API: `POST /auth/login`
  - On success: store access/refresh token via secure token store.
  - If MFA required: route to MFA placeholder and store temporary challenge context in memory only.
- **MFA Placeholder**
  - API: `POST /auth/mfa/verify` (if backend supports challenge)
  - Success transitions to Main Shell.
- **Session refresh**
  - API: `POST /auth/refresh` via background interceptor.
  - On refresh failure: clear session and route to Login.

### B. Home Dashboard / Notices / Events
- **Home Dashboard**
  - APIs:
    - `GET /public/notices?audience=student|public&page=1`
    - `GET /public/events?page=1`
  - State:
    - `HomeDashboardState { notices, events, lastUpdated, isOfflineData }`
- **Notices/Events detail screens**
  - Data passed from list when present; fallback fetch by id endpoint (or filter from list cache).

### C. Institution Section
- **Directory**
  - API: `GET /public/contacts?type=office|support|emergency`
- **Departments**
  - API: `GET /public/departments?q=...`
- **Maps**
  - API optional for dynamic links; otherwise bundled static config JSON.
- **Emergency**
  - API: `GET /public/contacts?type=emergency` (cache aggressively for offline safety).

### D. Student Section
- **Profile**
  - API: `GET /student/me` (or dedicated profile endpoint).
- **Timetable / Grades / Attendance / Fees / Library**
  - APIs (suggested):
    - `GET /student/timetable`
    - `GET /student/grades`
    - `GET /student/attendance`
    - `GET /student/fees`
    - `GET /student/library`
  - State pattern per module:
    - `StudentModuleState<T> { data, fetchedAt, loading, error, stale }`
  - Data minimization:
    - Keep in-memory while app is active.
    - Persist only redacted summary (e.g., last synced timestamp, item counts), not full records.

### E. Settings
- **Privacy & Security**
  - APIs (optional):
    - `GET /student/privacy/preferences`
    - `PATCH /student/privacy/preferences`
- **Feedback**
  - API: `POST /public/feedback` (or support ticket endpoint).
- **Logout**
  - API: `POST /auth/logout` with refresh token.
  - Local action: wipe secure tokens, clear memory and disk caches, return to Login.

### Offline and Protection Behavior (Required)
- **Cache allowed (public)**:
  - Departments, directory, notices/events, emergency contact list, static map metadata.
  - TTL examples: directory/departments 24h, notices/events 1h, emergency contacts 7d with priority refresh.
- **Cache restricted (student)**:
  - No raw grade/attendance/fee records on disk by default.
  - Optional encrypted snapshots only if explicitly enabled by product policy.
  - Always protect tokens in OS keystore/keychain.
- **When offline**:
  - Public screens render cached data + stale badge.
  - Student screens show last-sync metadata and require reconnect to refresh sensitive content.

---

## 3) Error, Loading, and Empty States

### Shared UI State Contract
- `Initial`: first visit, nothing requested yet.
- `Loading`: skeletons/shimmer and disabled high-risk actions.
- `Success`: content rendered with updated timestamp.
- `Empty`: valid response but no items (contextual copy + recovery action).
- `Error`: actionable message + retry + fallback path.

### Examples by Area
- **Login Error**: "Could not sign in. Check credentials or try again." Avoid exposing whether email exists.
- **MFA Error**: "Code invalid or expired" with retry count hint.
- **Home/Institution Loading**: card skeletons; preserve previous cached data if available.
- **Student Data Loading**: section-level skeleton rows and "secured data" notice.
- **Offline Error (public)**: "Showing cached data from <time>."
- **Offline Error (student)**: "Secure student records require connection to refresh."
- **Empty Notices/Events**: "No current notices/events" + pull-to-refresh.
- **Empty Library/Fees**: "No outstanding items" with last updated date.

### Retry and Resilience Rules
- Read APIs: exponential backoff (e.g., 0.5s, 1s, 2s).
- Writes (feedback/preferences): explicit user retry with idempotency key where available.
- Global interceptor handles 401 → refresh token flow → replay once.

---

## 4) Accessibility Basics

### Visual Accessibility
- Minimum text contrast:
  - Normal text: WCAG AA 4.5:1.
  - Large text and UI icons: 3:1.
- Do not encode status by color alone; pair with icon and label (e.g., "Late fee due" + warning icon).
- Ensure touch targets are at least 44x44 px.

### Typography and Scaling
- Support dynamic type / font scaling up to at least 200% without clipping critical information.
- Prefer responsive layouts (wrapping labels, vertical stacking) for long department names and timetable entries.

### Screen Reader and Semantics
- Every actionable control has explicit semantic labels (e.g., "Open emergency contacts", "Retry loading grades").
- Group repeated card elements with meaningful order: title → date → summary → action.
- Announce loading and error changes using accessibility live regions.

### Interaction and Motion
- Preserve logical focus order after navigation and modal close.
- Offer reduced motion for animated transitions and skeleton shimmer.

### Forms and Validation
- Associate labels with inputs; include examples and input purpose hints.
- Error copy is specific and announced to screen readers.
- MFA code fields support auto-advance but remain fully keyboard accessible.

---

## Implementation Notes (MVP Prioritization)
1. Build shell + onboarding/login + Home + Institution first (public/offline-ready).
2. Add Student modules incrementally behind authenticated routes.
3. Introduce MFA screen as placeholder route now, backend-enforced later.
4. Add telemetry events for failures (without sensitive payloads) to improve UX and reliability.
