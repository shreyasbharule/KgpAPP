from datetime import datetime

from pydantic import BaseModel, Field


class StudentSummaryResponse(BaseModel):
    full_name: str
    roll_number: str
    department: str
    semester: int = Field(ge=1, le=12)
    attendance_percentage: float = Field(ge=0, le=100)


class StudentGradeItem(BaseModel):
    course_code: str
    course_name: str | None = None
    term: str
    grade: str
    credits: int = Field(ge=0)


class StudentGradesResponse(BaseModel):
    student_id: int
    grades: list[StudentGradeItem]


class StudentTimetableItem(BaseModel):
    id: int
    course_code: str
    course_name: str
    instructor_name: str | None = None
    room: str | None = None
    starts_at: datetime
    ends_at: datetime


class StudentTimetableResponse(BaseModel):
    student_id: int
    entries: list[StudentTimetableItem]
