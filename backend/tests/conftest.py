import os
from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient

os.environ.setdefault('DATABASE_URL', 'sqlite:///./test_backend.db')
os.environ.setdefault('JWT_SECRET_KEY', 'test-secret-key-with-at-least-thirty-two-chars')

from app.core.security import get_password_hash
from app.db.session import Base, SessionLocal, engine
from app.main import app
from datetime import datetime, timedelta

from app.models.student import StudentGrade, StudentProfile, StudentTimetableEntry
from app.models.user import Role, User


@pytest.fixture(autouse=True)
def setup_database() -> Generator[None, None, None]:
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        admin = User(
            email='admin@test.edu',
            full_name='Admin User',
            hashed_password=get_password_hash('AdminPass123!'),
            role=Role.admin,
        )
        student_user = User(
            email='student@test.edu',
            full_name='Student User',
            hashed_password=get_password_hash('StudentPass123!'),
            role=Role.student,
        )
        outsider = User(
            email='outsider@test.edu',
            full_name='Outsider Student',
            hashed_password=get_password_hash('OutsiderPass123!'),
            role=Role.student,
        )
        db.add_all([admin, student_user, outsider])
        db.commit()
        db.refresh(student_user)

        student_profile = StudentProfile(
            user_id=student_user.id,
            roll_number='20CS10001',
            department='Computer Science',
            semester=6,
            attendance_percentage=92.5,
        )
        db.add(student_profile)
        db.commit()
        db.refresh(student_profile)

        db.add(
            StudentGrade(
                student_id=student_profile.id,
                course_code='CS60001',
                course_name='Distributed Systems',
                term='Spring-2026',
                grade='A',
                credits=4,
            )
        )
        db.add(
            StudentTimetableEntry(
                student_id=student_profile.id,
                course_code='CS60001',
                course_name='Distributed Systems',
                instructor_name='Dr. Test',
                room='CS-501',
                starts_at=datetime.utcnow() + timedelta(days=1),
                ends_at=datetime.utcnow() + timedelta(days=1, hours=1),
            )
        )
        db.commit()
    finally:
        db.close()

    yield


@pytest.fixture
def client() -> Generator[TestClient, None, None]:
    with TestClient(app) as test_client:
        yield test_client
