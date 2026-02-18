from fastapi import APIRouter, Depends, HTTPException, Path
from sqlalchemy.orm import Session

from app.api.deps import role_required
from app.db.session import get_db
from app.models.user import Role, User
from app.schemas.admin import RoleChangeRequest, RoleChangeResponse
from app.services.audit import log_event

router = APIRouter(prefix='/admin', tags=['admin'])


@router.patch('/users/{user_id}/role', response_model=RoleChangeResponse)
def change_user_role(
    payload: RoleChangeRequest,
    user_id: int = Path(ge=1),
    actor: User = Depends(role_required({Role.admin})),
    db: Session = Depends(get_db),
):
    target_user = db.query(User).filter(User.id == user_id).first()
    if target_user is None:
        raise HTTPException(status_code=404, detail='User not found')

    previous_role = target_user.role
    target_user.role = payload.role
    db.add(target_user)
    db.commit()
    db.refresh(target_user)

    log_event(
        db,
        actor.id,
        'admin.user.role.change',
        'user',
        {
            'target_user_id': target_user.id,
            'previous_role': previous_role.value,
            'new_role': target_user.role.value,
        },
    )

    return RoleChangeResponse(user_id=target_user.id, role=target_user.role)
