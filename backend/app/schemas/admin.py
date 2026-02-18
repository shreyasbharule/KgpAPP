from pydantic import BaseModel

from app.models.user import Role


class RoleChangeRequest(BaseModel):
    role: Role


class RoleChangeResponse(BaseModel):
    user_id: int
    role: Role
