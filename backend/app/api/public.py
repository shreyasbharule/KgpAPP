from sqlalchemy import or_
from sqlalchemy.orm import Session
from fastapi import APIRouter, Depends

from app.db.session import get_db
from app.models.institution import Department, Event, Notice
from app.schemas.public import DepartmentItem, EventItem, NoticeItem

router = APIRouter(prefix='/public', tags=['public'])


@router.get('/departments', response_model=list[DepartmentItem])
def get_departments(db: Session = Depends(get_db)):
    rows = db.query(Department).order_by(Department.name.asc()).all()
    return [
        DepartmentItem(id=row.id, code=row.code, name=row.name, office_location=row.office_location)
        for row in rows
    ]


@router.get('/notices', response_model=list[NoticeItem])
def get_notices(db: Session = Depends(get_db)):
    rows = (
        db.query(Notice)
        .filter(Notice.is_published.is_(True), or_(Notice.audience == 'public', Notice.audience == 'student'))
        .order_by(Notice.published_at.desc(), Notice.id.desc())
        .limit(50)
        .all()
    )
    return [
        NoticeItem(
            id=row.id,
            title=row.title,
            body=row.body,
            audience=row.audience,
            published_at=row.published_at,
        )
        for row in rows
    ]


@router.get('/events', response_model=list[EventItem])
def get_events(db: Session = Depends(get_db)):
    rows = (
        db.query(Event, Department)
        .outerjoin(Department, Department.id == Event.department_id)
        .filter(Event.is_published.is_(True))
        .order_by(Event.starts_at.asc(), Event.id.desc())
        .limit(50)
        .all()
    )
    return [
        EventItem(
            id=event.id,
            title=event.title,
            description=event.description,
            starts_at=event.starts_at,
            ends_at=event.ends_at,
            venue=event.venue,
            department=department.name if department else None,
        )
        for event, department in rows
    ]
