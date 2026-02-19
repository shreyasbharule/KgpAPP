from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session

from app.api.deps import role_required
from app.db.session import get_db
from app.models.student import StudentGrade, StudentProfile, StudentTimetableEntry
from app.models.user import Role, User
from app.schemas.student import (
    StudentGradeItem,
    StudentGradesResponse,
    StudentSummaryResponse,
    StudentTimetableItem,
    StudentTimetableResponse,
)
from app.services.audit import log_event

router = APIRouter(prefix='/student', tags=['student'])


def _get_profile_or_404(db: Session, student_id: int) -> StudentProfile:
    profile = db.query(StudentProfile).filter(StudentProfile.id == student_id).first()
    if profile is None:
        raise HTTPException(status_code=404, detail='Student profile not found')
    return profile


def _get_profile_for_user_or_404(db: Session, user_id: int) -> StudentProfile:
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user_id).first()
    if profile is None:
        raise HTTPException(status_code=404, detail='Student profile not found')
    return profile


def _build_student_summary(profile: StudentProfile, user: User) -> StudentSummaryResponse:
    return StudentSummaryResponse(
        full_name=user.full_name,
        roll_number=profile.roll_number,
        department=profile.department,
        semester=profile.semester,
        attendance_percentage=float(profile.attendance_percentage),
    )


def _ensure_student_can_access_profile(profile: StudentProfile, current_user: User, resource: str) -> None:
    if current_user.role == Role.student and profile.user_id != current_user.id:
        raise HTTPException(status_code=403, detail=f'Students can only view their own {resource}')


@router.get('/me', response_model=StudentSummaryResponse)
def get_my_profile(user: User = Depends(role_required({Role.student})), db: Session = Depends(get_db)):
    profile = _get_profile_for_user_or_404(db, user.id)

    log_event(db, user.id, 'student.profile.read', 'student_profile', {'student_id': profile.id})
    return _build_student_summary(profile, user)


@router.get('/me/grades', response_model=StudentGradesResponse)
def get_my_grades(user: User = Depends(role_required({Role.student})), db: Session = Depends(get_db)):
    profile = _get_profile_for_user_or_404(db, user.id)
    return get_student_grades(profile.id, user, db)


@router.get('/me/timetable', response_model=StudentTimetableResponse)
def get_my_timetable(user: User = Depends(role_required({Role.student})), db: Session = Depends(get_db)):
    profile = _get_profile_for_user_or_404(db, user.id)
    return get_student_timetable(profile.id, user, db)


@router.get('/admin/{student_id}', response_model=StudentSummaryResponse)
def get_student_for_admin(
    student_id: int = Path(ge=1),
    current_user: User = Depends(role_required({Role.admin, Role.staff})),
    db: Session = Depends(get_db),
):
    profile = _get_profile_or_404(db, student_id)

    user = db.query(User).filter(User.id == profile.user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail='User not found')

    log_event(
        db,
        current_user.id,
        'student.record.access',
        'student_profile',
        {'student_id': profile.id, 'target_user_id': user.id},
    )
    return _build_student_summary(profile, user)


@router.get('/{student_id}/grades', response_model=StudentGradesResponse)
def get_student_grades(
    student_id: int = Path(ge=1),
    current_user: User = Depends(role_required({Role.admin, Role.staff, Role.student})),
    db: Session = Depends(get_db),
):
    profile = _get_profile_or_404(db, student_id)

    _ensure_student_can_access_profile(profile, current_user, 'grades')

    grades = db.query(StudentGrade).filter(StudentGrade.student_id == student_id).all()
    log_event(
        db,
        current_user.id,
        'student.grade.view',
        'student_grades',
        {'student_id': student_id, 'viewer_role': current_user.role.value},
    )
    return StudentGradesResponse(
        student_id=student_id,
        grades=[
            StudentGradeItem(
                course_code=g.course_code,
                course_name=g.course_name,
                term=g.term,
                grade=g.grade,
                credits=g.credits,
            )
            for g in grades
        ],
    )


@router.get('/{student_id}/timetable', response_model=StudentTimetableResponse)
def get_student_timetable(
    student_id: int = Path(ge=1),
    current_user: User = Depends(role_required({Role.admin, Role.staff, Role.student})),
    db: Session = Depends(get_db),
):
    profile = _get_profile_or_404(db, student_id)

    _ensure_student_can_access_profile(profile, current_user, 'timetable')

    entries = (
        db.query(StudentTimetableEntry)
        .filter(StudentTimetableEntry.student_id == student_id)
        .order_by(StudentTimetableEntry.starts_at.asc())
        .all()
    )
    log_event(
        db,
        current_user.id,
        'student.timetable.view',
        'student_timetable',
        {'student_id': student_id, 'viewer_role': current_user.role.value},
    )

    return StudentTimetableResponse(
        student_id=student_id,
        entries=[
            StudentTimetableItem(
                id=entry.id,
                course_code=entry.course_code,
                course_name=entry.course_name,
                instructor_name=entry.instructor_name,
                room=entry.room,
                starts_at=entry.starts_at,
                ends_at=entry.ends_at,
            )
            for entry in entries
        ],
    )
