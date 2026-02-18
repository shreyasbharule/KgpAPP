from pydantic import BaseModel


class StudentSummaryResponse(BaseModel):
    full_name: str
    roll_number: str
    department: str
    semester: int
    attendance_percentage: float
