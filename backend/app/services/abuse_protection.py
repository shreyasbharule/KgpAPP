import time
from collections import defaultdict


class LoginAbuseProtection:
    def __init__(self, max_attempts: int, block_seconds: int):
        self.max_attempts = max_attempts
        self.block_seconds = block_seconds
        self.failed_attempts: dict[str, int] = defaultdict(int)
        self.blocked_until: dict[str, float] = {}

    def is_blocked(self, identity: str) -> bool:
        unblock_at = self.blocked_until.get(identity)
        if not unblock_at:
            return False
        if time.time() > unblock_at:
            self.blocked_until.pop(identity, None)
            self.failed_attempts.pop(identity, None)
            return False
        return True

    def record_failure(self, identity: str) -> None:
        self.failed_attempts[identity] += 1
        if self.failed_attempts[identity] >= self.max_attempts:
            self.blocked_until[identity] = time.time() + self.block_seconds

    def clear(self, identity: str) -> None:
        self.failed_attempts.pop(identity, None)
        self.blocked_until.pop(identity, None)
