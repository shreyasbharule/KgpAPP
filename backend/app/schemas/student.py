from pydantic import BaseModel, Field


class StudentSummaryResponse(BaseModel):
    full_name: str
    roll_number: str
    department: str
    semester: int = Field(ge=1, le=12)
    attendance_percentage: float = Field(ge=0, le=100)


class StudentGradeItem(BaseModel):
    course_code: str
    term: str
    grade: str


class StudentGradesResponse(BaseModel):
    student_id: int
    grades: list[StudentGradeItem]
