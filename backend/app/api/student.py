from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, role_required
from app.db.session import get_db
from app.models.student import StudentProfile
from app.models.user import Role, User
from app.schemas.student import StudentSummaryResponse
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
    student_id: int,
    _: User = Depends(role_required({Role.admin, Role.staff})),
    db: Session = Depends(get_db),
):
    profile = db.query(StudentProfile).filter(StudentProfile.id == student_id).first()
    if profile is None:
        raise HTTPException(status_code=404, detail='Student profile not found')

    user = db.query(User).filter(User.id == profile.user_id).first()
    if user is None:
        raise HTTPException(status_code=404, detail='User not found')

    return StudentSummaryResponse(
        full_name=user.full_name,
        roll_number=profile.roll_number,
        department=profile.department,
        semester=profile.semester,
        attendance_percentage=float(profile.attendance_percentage),
    )
