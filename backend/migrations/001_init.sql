-- Initial schema for University Student App MVP
CREATE TYPE role_enum AS ENUM ('student', 'faculty', 'staff', 'admin');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    role role_enum NOT NULL DEFAULT 'student',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE student_profiles (
    id SERIAL PRIMARY KEY,
    user_id INT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    roll_number VARCHAR(20) UNIQUE NOT NULL,
    department VARCHAR(120) NOT NULL,
    semester INT NOT NULL,
    attendance_percentage NUMERIC(5,2) NOT NULL DEFAULT 0
);

CREATE TABLE student_grades (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    course_code VARCHAR(20) NOT NULL,
    term VARCHAR(40) NOT NULL,
    grade VARCHAR(4) NOT NULL
);

CREATE TABLE fee_status (
    id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES student_profiles(id) ON DELETE CASCADE,
    amount_due NUMERIC(10,2) NOT NULL DEFAULT 0,
    due_date DATE NOT NULL,
    status VARCHAR(40) NOT NULL
);

CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    actor_user_id INT REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(120) NOT NULL,
    resource VARCHAR(120) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata_json VARCHAR(1000) NOT NULL DEFAULT '{}'
);

CREATE INDEX idx_student_profiles_user_id ON student_profiles(user_id);
CREATE INDEX idx_student_grades_student_id ON student_grades(student_id);
CREATE INDEX idx_fee_status_student_id ON fee_status(student_id);
CREATE INDEX idx_audit_logs_actor_user_id ON audit_logs(actor_user_id);
