-- Platform expansion schema for auth + institutional info + student services + admin/audit

-- Extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Enums
DO $$ BEGIN
    CREATE TYPE user_status_enum AS ENUM ('pending_invite', 'active', 'suspended');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE audience_enum AS ENUM ('public', 'student', 'faculty', 'staff');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE contact_type_enum AS ENUM ('office', 'support', 'admissions', 'emergency');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE fee_status_enum AS ENUM ('pending', 'paid', 'overdue', 'waived');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Users/auth enhancements
ALTER TABLE users
    ADD COLUMN IF NOT EXISTS status user_status_enum NOT NULL DEFAULT 'pending_invite',
    ADD COLUMN IF NOT EXISTS mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS auth_invites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    role role_enum NOT NULL DEFAULT 'student',
    invited_by_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    accepted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_auth_invites_email_active
    ON auth_invites(email)
    WHERE accepted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_auth_invites_expires_at ON auth_invites(expires_at);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    user_agent VARCHAR(255),
    ip_address INET
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id BIGSERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

CREATE TABLE IF NOT EXISTS mfa_enrollments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mfa_type VARCHAR(20) NOT NULL DEFAULT 'totp',
    secret_encrypted VARCHAR(255) NOT NULL,
    verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, mfa_type)
);

-- Institutional public information
CREATE TABLE IF NOT EXISTS departments (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    office_location VARCHAR(150),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_departments_name ON departments(name);

CREATE TABLE IF NOT EXISTS contacts (
    id SERIAL PRIMARY KEY,
    department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    type contact_type_enum NOT NULL,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(40),
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contacts_department_id ON contacts(department_id);
CREATE INDEX IF NOT EXISTS idx_contacts_type ON contacts(type);

CREATE TABLE IF NOT EXISTS notices (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    audience audience_enum NOT NULL DEFAULT 'public',
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    published_at TIMESTAMPTZ,
    created_by_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    updated_by_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notices_published_at ON notices(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_notices_audience ON notices(audience);

CREATE TABLE IF NOT EXISTS events (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    venue VARCHAR(255),
    department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    is_published BOOLEAN NOT NULL DEFAULT FALSE,
    created_by_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_event_time CHECK (ends_at > starts_at)
);

CREATE INDEX IF NOT EXISTS idx_events_starts_at ON events(starts_at);
CREATE INDEX IF NOT EXISTS idx_events_department_id ON events(department_id);

CREATE TABLE IF NOT EXISTS emergency_contacts (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(150) NOT NULL,
    phone VARCHAR(40) NOT NULL,
    email VARCHAR(255),
    priority INT NOT NULL DEFAULT 100,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_emergency_contacts_priority ON emergency_contacts(priority);

-- Student services
ALTER TABLE student_profiles
    ADD COLUMN IF NOT EXISTS program VARCHAR(120),
    ADD COLUMN IF NOT EXISTS batch_year INT,
    ADD COLUMN IF NOT EXISTS library_card_number VARCHAR(40) UNIQUE;

CREATE TABLE IF NOT EXISTS student_timetable_entries (
    id BIGSERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    course_code VARCHAR(20) NOT NULL,
    course_name VARCHAR(150) NOT NULL,
    instructor_name VARCHAR(150),
    room VARCHAR(80),
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_timetable_time CHECK (ends_at > starts_at)
);

CREATE INDEX IF NOT EXISTS idx_student_timetable_entries_student_id ON student_timetable_entries(student_id);
CREATE INDEX IF NOT EXISTS idx_student_timetable_entries_starts_at ON student_timetable_entries(starts_at);

ALTER TABLE student_grades
    ADD COLUMN IF NOT EXISTS credits INT NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_student_grades_term ON student_grades(term);

CREATE TABLE IF NOT EXISTS student_attendance (
    id BIGSERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    course_code VARCHAR(20) NOT NULL,
    attended_classes INT NOT NULL DEFAULT 0,
    total_classes INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_attendance_counts CHECK (total_classes >= attended_classes AND attended_classes >= 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_student_attendance_unique_course
    ON student_attendance(student_id, course_code);

ALTER TABLE fee_status
    ADD COLUMN IF NOT EXISTS invoice_no VARCHAR(40),
    ADD COLUMN IF NOT EXISTS status_enum fee_status_enum,
    ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE INDEX IF NOT EXISTS idx_fee_status_due_date ON fee_status(due_date);

CREATE TABLE IF NOT EXISTS library_accounts (
    id BIGSERIAL PRIMARY KEY,
    student_id INT NOT NULL UNIQUE REFERENCES student_profiles(id) ON DELETE CASCADE,
    card_number VARCHAR(40) UNIQUE NOT NULL,
    outstanding_fine NUMERIC(10,2) NOT NULL DEFAULT 0,
    issued_books_count INT NOT NULL DEFAULT 0,
    overdue_books_count INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Audit trail enhancement
ALTER TABLE audit_logs
    ADD COLUMN IF NOT EXISTS resource_id VARCHAR(64),
    ADD COLUMN IF NOT EXISTS ip_address INET,
    ADD COLUMN IF NOT EXISTS user_agent VARCHAR(255),
    ADD COLUMN IF NOT EXISTS metadata JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON audit_logs(resource);
CREATE INDEX IF NOT EXISTS idx_audit_logs_metadata_gin ON audit_logs USING gin (metadata);
