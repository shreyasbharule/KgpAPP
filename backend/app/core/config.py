from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file='.env', env_file_encoding='utf-8', extra='ignore')

    app_env: str = 'development'
    app_name: str = 'University Student API'
    app_version: str = '1.0.0'

    database_url: str

    jwt_secret_key: str = Field(min_length=32)
    jwt_algorithm: str = 'HS256'
    access_token_expire_minutes: int = Field(default=30, ge=5, le=1440)

    cors_origins: str = 'http://localhost:3000,http://localhost:8080'

    rate_limit_requests: int = Field(default=120, ge=10)
    rate_limit_window_seconds: int = Field(default=60, ge=10)

    login_max_attempts: int = Field(default=5, ge=3)
    login_block_seconds: int = Field(default=300, ge=30)


@lru_cache
def get_settings() -> Settings:
    return Settings()
