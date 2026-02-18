import json

from sqlalchemy.orm import Session

from app.models.student import AuditLog


def log_event(db: Session, actor_user_id: int | None, action: str, resource: str, metadata: dict | None = None):
    record = AuditLog(
        actor_user_id=actor_user_id,
        action=action,
        resource=resource,
        metadata_json=json.dumps(metadata or {}),
    )
    db.add(record)
    db.commit()
