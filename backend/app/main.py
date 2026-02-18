from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import admin, auth, public, student
from app.core.config import get_settings
from app.middleware.rate_limiter import RateLimiterMiddleware

settings = get_settings()

app = FastAPI(title=settings.app_name, version=settings.app_version)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[origin.strip() for origin in settings.cors_origins.split(',') if origin.strip()],
    allow_credentials=True,
    allow_methods=['GET', 'POST', 'PATCH'],
    allow_headers=['Authorization', 'Content-Type'],
)
app.add_middleware(
    RateLimiterMiddleware,
    max_requests=settings.rate_limit_requests,
    window_seconds=settings.rate_limit_window_seconds,
)


@app.get('/health')
def health_check():
    return {'status': 'ok'}


app.include_router(auth.router, prefix='/api/v1')
app.include_router(student.router, prefix='/api/v1')
app.include_router(public.router, prefix='/api/v1')
app.include_router(admin.router, prefix='/api/v1')
