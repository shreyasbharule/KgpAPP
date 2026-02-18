-- Demo seed data for local integration testing.
-- Requires 001_init.sql + 003_platform_expansion.sql and pgcrypto extension.

-- Demo users
INSERT INTO users (email, full_name, hashed_password, role, status)
VALUES
    ('student@university.edu', 'Demo Student', crypt('StudentPass123!', gen_salt('bf')), 'student', 'active'),
    ('faculty@university.edu', 'Demo Faculty', crypt('FacultyPass123!', gen_salt('bf')), 'faculty', 'active'),
    ('admin@university.edu', 'Demo Admin', crypt('AdminPass123!', gen_salt('bf')), 'admin', 'active')
ON CONFLICT (email) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    status = EXCLUDED.status;

-- Student profile + academics
WITH student_user AS (
    SELECT id FROM users WHERE email = 'student@university.edu'
)
INSERT INTO student_profiles (user_id, roll_number, department, semester, attendance_percentage, program, batch_year, library_card_number)
SELECT id, '23CS10001', 'Computer Science and Engineering', 5, 91.25, 'B.Tech CSE', 2023, 'LIB-23CS10001'
FROM student_user
ON CONFLICT (user_id) DO UPDATE SET
    department = EXCLUDED.department,
    semester = EXCLUDED.semester,
    attendance_percentage = EXCLUDED.attendance_percentage,
    program = EXCLUDED.program,
    batch_year = EXCLUDED.batch_year,
    library_card_number = EXCLUDED.library_card_number;

WITH student_profile AS (
    SELECT id FROM student_profiles WHERE roll_number = '23CS10001'
)
INSERT INTO student_grades (student_id, course_code, course_name, term, grade, credits)
SELECT id, 'CS201', 'Data Structures', 'Autumn-2026', 'A', 4 FROM student_profile
UNION ALL
SELECT id, 'CS251', 'Database Systems', 'Autumn-2026', 'A-', 4 FROM student_profile
UNION ALL
SELECT id, 'MA205', 'Probability and Statistics', 'Autumn-2026', 'B+', 3 FROM student_profile
ON CONFLICT DO NOTHING;

WITH student_profile AS (
    SELECT id FROM student_profiles WHERE roll_number = '23CS10001'
)
INSERT INTO student_timetable_entries (student_id, course_code, course_name, instructor_name, room, starts_at, ends_at)
SELECT id, 'CS201', 'Data Structures', 'Dr. A. Sen', 'CSE-201', NOW() + INTERVAL '1 day 9 hours', NOW() + INTERVAL '1 day 10 hours' FROM student_profile
UNION ALL
SELECT id, 'CS251', 'Database Systems', 'Dr. R. Das', 'CSE-204', NOW() + INTERVAL '1 day 11 hours', NOW() + INTERVAL '1 day 12 hours' FROM student_profile
UNION ALL
SELECT id, 'MA205', 'Probability and Statistics', 'Prof. P. Roy', 'MA-102', NOW() + INTERVAL '2 day 10 hours', NOW() + INTERVAL '2 day 11 hours' FROM student_profile
ON CONFLICT DO NOTHING;

-- Institutional public data
INSERT INTO departments (code, name, office_location)
VALUES
    ('CSE', 'Computer Science and Engineering', 'Academic Block A, 2nd Floor'),
    ('ECE', 'Electronics and Communication Engineering', 'Academic Block B, 1st Floor'),
    ('HSS', 'Humanities and Social Sciences', 'Main Building, Room 114')
ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    office_location = EXCLUDED.office_location;

INSERT INTO notices (title, body, audience, is_published, published_at)
VALUES
    ('Orientation Week Schedule', 'Orientation week starts Monday at 10:00 AM in the central auditorium.', 'public', TRUE, NOW() - INTERVAL '2 days'),
    ('Mid-Sem Registration Deadline', 'Course registration closes this Friday at 11:59 PM.', 'student', TRUE, NOW() - INTERVAL '1 day')
ON CONFLICT DO NOTHING;

INSERT INTO events (title, description, starts_at, ends_at, venue, department_id, is_published)
SELECT
    'Tech Symposium 2026',
    'Student project showcase and invited talks.',
    NOW() + INTERVAL '7 days 4 hours',
    NOW() + INTERVAL '7 days 10 hours',
    'Innovation Hall',
    d.id,
    TRUE
FROM departments d
WHERE d.code = 'CSE'
ON CONFLICT DO NOTHING;
