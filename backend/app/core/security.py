from datetime import datetime, timedelta, timezone

from jose import jwt
from passlib.context import CryptContext

from app.core.config import get_settings
from app.models.user import Role

pwd_context = CryptContext(schemes=['bcrypt'], deprecated='auto')

settings = get_settings()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def _encode_token(subject: str, role: Role, expires_in_minutes: int, token_type: str) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=expires_in_minutes)
    payload = {'sub': subject, 'role': role.value, 'type': token_type, 'exp': expire}
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_access_token(subject: str, role: Role) -> str:
    return _encode_token(subject, role, settings.access_token_expire_minutes, 'access')


def create_refresh_token(subject: str, role: Role) -> str:
    refresh_minutes = settings.access_token_expire_minutes * 24
    return _encode_token(subject, role, refresh_minutes, 'refresh')
