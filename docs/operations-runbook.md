# Operations Runbook

This runbook provides baseline operations guidance for logging, monitoring, audit log retention, and incident response.

## 1) Logging

## 1.1 Application logs

Capture and centralize:

- API startup/shutdown events
- Request metadata (method, path, status, latency)
- Authentication events (success/failure/block)
- Authorization denials (`403`), rate limiting (`429`), and server errors (`5xx`)

### Logging controls

- Use structured logs (JSON preferred).
- Include correlation/request IDs where possible.
- Avoid logging secrets, passwords, tokens, or PII-heavy payloads.
- Apply log redaction at source or collector.

## 1.2 Infrastructure logs

Collect from:

- Reverse proxy/ingress
- Container runtime or VM host
- Database engine
- Secret manager access logs

Retain sufficient data for forensic investigation.

## 2) Monitoring and alerting

## 2.1 Golden signals

Track these service metrics:

- **Latency**: p50/p95/p99 request latency
- **Traffic**: request rate by endpoint/status
- **Errors**: 4xx/5xx trends and error budget burn
- **Saturation**: CPU/memory, DB connection pool usage

## 2.2 Security-relevant monitoring

- Login failure spikes by IP/account
- Increased `429` rate-limiter events
- Sudden token refresh anomalies
- Unexpected admin role-change activity

## 2.3 Recommended alerts

- `5xx` rate above threshold for 5+ minutes
- Health check failures across multiple instances
- DB availability/connectivity issues
- Elevated auth failure rate
- Backup job failure or stale backup age

## 3) Audit log retention

The backend persists security-sensitive events in `audit_logs` via `app.services.audit.log_event`.

### Minimum retention baseline

- **Hot searchable retention**: 90 days
- **Archive retention**: 1 year (or institution policy/legal requirement)

### Retention controls

- Keep audit logs immutable/tamper-evident where possible.
- Restrict read access to security/authorized operations personnel.
- Encrypt logs at rest and in transit.
- Run periodic retention and deletion jobs aligned to policy.

## 4) Incident response basics

## 4.1 Severity model (suggested)

- **SEV-1**: Production outage or confirmed data/security breach
- **SEV-2**: Major degraded service, no confirmed breach
- **SEV-3**: Minor impact or isolated failure

## 4.2 First 30 minutes checklist

1. Acknowledge incident and assign incident commander.
2. Capture timeline start, affected services, and blast radius.
3. Stabilize service (rollback, scale, traffic shift, block abuse source).
4. Preserve evidence (logs, metrics, traces, DB snapshots where needed).
5. Communicate stakeholder update with next ETA.

## 4.3 Security incident additions

- Rotate potentially exposed secrets immediately.
- Revoke/expire suspicious sessions/tokens.
- Force password reset for impacted cohorts if needed.
- Document indicators of compromise (IoCs).

## 4.4 Recovery and closure

- Validate functionality with smoke tests (`/health`, auth, key endpoints).
- Confirm monitoring returns to baseline.
- Conduct post-incident review (RCA, action items, owners, due dates).

## 5) Routine operations checklist

- Daily: verify health checks, alert queues, and backup job success.
- Weekly: review error trends and auth abuse patterns.
- Monthly: restore test from backup and review access logs.
- Quarterly: tabletop incident drill and secret rotation verification.
