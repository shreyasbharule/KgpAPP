from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session

from app.api.deps import role_required
from app.db.session import get_db
from app.models.student import StudentGrade, StudentProfile
from app.models.user import Role, User
from app.schemas.student import StudentGradeItem, StudentGradesResponse, StudentSummaryResponse
from app.services.audit import log_event

router = APIRouter(prefix='/student', tags=['student'])


@router.get('/me', response_model=StudentSummaryResponse)
def get_my_profile(user: User = Depends(role_required({Role.student})), db: Session = Depends(get_db)):
    profile = db.query(StudentProfile).filter(StudentProfile.user_id == user.id).first()
    if profile is None:
        raise HTTPException(status_code=404, detail='Student profile not found')

    log_event(db, user.id, 'student.profile.read', 'student_profile', {'student_id': profile.id})
    return StudentSummaryResponse(
        full_name=user.full_name,
        roll_number=profile.roll_number,
        department=profile.department,
        semester=profile.semester,
        attendance_percentage=float(profile.attendance_percentage),
    )


@router.get('/admin/{student_id}', response_model=StudentSummaryResponse)
def get_student_for_admin(
    student_id: int = Path(ge=1),
    current_user: User = Depends(role_required({Role.admin, Role.staff})),
    db: Session = Depends(get_db),
):
    profile = db.query(StudentProfile).filter(StudentProfile.id == student_id).first()
    if profile is None:
        raise HTTPException(status_code=404, detail='Student profile not found')

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
    return StudentSummaryResponse(
        full_name=user.full_name,
        roll_number=profile.roll_number,
        department=profile.department,
        semester=profile.semester,
        attendance_percentage=float(profile.attendance_percentage),
    )


@router.get('/{student_id}/grades', response_model=StudentGradesResponse)
def get_student_grades(
    student_id: int = Path(ge=1),
    current_user: User = Depends(role_required({Role.admin, Role.staff, Role.student})),
    db: Session = Depends(get_db),
):
    profile = db.query(StudentProfile).filter(StudentProfile.id == student_id).first()
    if profile is None:
        raise HTTPException(status_code=404, detail='Student profile not found')

    if current_user.role == Role.student and profile.user_id != current_user.id:
        raise HTTPException(status_code=403, detail='Students can only view their own grades')

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
        grades=[StudentGradeItem(course_code=g.course_code, term=g.term, grade=g.grade) for g in grades],
    )
