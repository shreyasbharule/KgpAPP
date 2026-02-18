import time
from collections import defaultdict, deque

from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import JSONResponse


class RateLimiterMiddleware(BaseHTTPMiddleware):
    def __init__(self, app, max_requests: int, window_seconds: int):
        super().__init__(app)
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._requests: dict[str, deque[float]] = defaultdict(deque)

    async def dispatch(self, request: Request, call_next):
        key = self._build_key(request)
        now = time.time()
        request_log = self._requests[key]

        while request_log and now - request_log[0] > self.window_seconds:
            request_log.popleft()

        if len(request_log) >= self.max_requests:
            return JSONResponse(
                status_code=429,
                content={'detail': 'Rate limit exceeded. Please slow down.'},
            )

        request_log.append(now)
        return await call_next(request)

    @staticmethod
    def _build_key(request: Request) -> str:
        client_ip = request.client.host if request.client else 'unknown'
        return f'{client_ip}:{request.url.path}'
