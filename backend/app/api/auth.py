from fastapi import APIRouter, Depends, HTTPException, Request, status
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import get_settings
from app.core.security import create_access_token, create_refresh_token, verify_password
from app.db.session import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, RefreshRequest, TokenResponse, UserInfo
from app.services.abuse_protection import LoginAbuseProtection
from app.services.audit import log_event

router = APIRouter(prefix='/auth', tags=['auth'])

settings = get_settings()
login_protection = LoginAbuseProtection(
    max_attempts=settings.login_max_attempts,
    block_seconds=settings.login_block_seconds,
)


def _build_token_response(user: User) -> TokenResponse:
    return TokenResponse(
        access_token=create_access_token(user.email, user.role),
        refresh_token=create_refresh_token(user.email, user.role),
        expires_in=settings.access_token_expire_minutes * 60,
        user=UserInfo(id=user.id, name=user.full_name, email=user.email, role=user.role.value),
    )


@router.post('/login', response_model=TokenResponse)
def login(payload: LoginRequest, request: Request, db: Session = Depends(get_db)):
    client_ip = request.client.host if request.client else 'unknown'
    abuse_key = f'{client_ip}:{payload.email}'

    if login_protection.is_blocked(abuse_key):
        log_event(db, None, 'auth.login.blocked', 'user', {'email': payload.email, 'ip': client_ip})
        raise HTTPException(status_code=status.HTTP_429_TOO_MANY_REQUESTS, detail='Too many login attempts')

    user = db.query(User).filter(User.email == payload.email).first()
    if user is None or not verify_password(payload.password, user.hashed_password):
        login_protection.record_failure(abuse_key)
        log_event(db, None, 'auth.login.failed', 'user', {'email': payload.email, 'ip': client_ip})
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Invalid credentials')

    login_protection.clear(abuse_key)
    log_event(db, user.id, 'auth.login.success', 'user', {'role': user.role.value, 'ip': client_ip})
    return _build_token_response(user)


@router.post('/refresh', response_model=TokenResponse)
def refresh_tokens(payload: RefreshRequest, request: Request, db: Session = Depends(get_db)):
    credential_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail='Invalid refresh token',
    )

    try:
        decoded = jwt.decode(payload.refresh_token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])
        if decoded.get('type') != 'refresh':
            raise credential_exception
        subject = decoded.get('sub')
        if not subject:
            raise credential_exception
    except JWTError as exc:
        raise credential_exception from exc

    user = db.query(User).filter(User.email == subject).first()
    if user is None:
        raise credential_exception

    client_ip = request.client.host if request.client else 'unknown'
    log_event(db, user.id, 'auth.token.refresh', 'user', {'ip': client_ip})
    return _build_token_response(user)
