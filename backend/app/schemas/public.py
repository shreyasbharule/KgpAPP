from datetime import datetime

from pydantic import BaseModel


class DepartmentItem(BaseModel):
    id: int
    code: str
    name: str
    office_location: str | None = None


class NoticeItem(BaseModel):
    id: int
    title: str
    body: str
    audience: str
    published_at: datetime | None = None


class EventItem(BaseModel):
    id: int
    title: str
    description: str | None = None
    starts_at: datetime
    ends_at: datetime
    venue: str | None = None
    department: str | None = None
