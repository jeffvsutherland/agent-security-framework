# ASF Audit Logging System

## Overview
Centralized audit logging for all security events in Clawdbot-Moltbot-Open-Claw

## Log Locations

| Component | Log File | Retention |
|-----------|----------|-----------|
| OpenClaw | /var/log/asf/openclaw.log | 90 days |
| Clawdbot | /var/log/asf/clawdbot.log | 90 days |
| Moltbot | /var/log/asf/moltbot.log | 90 days |
| Security | /var/log/asf/security.log | 1 year |

## Event Types Logged

### Authentication Events
- Login success/failure
- Token refresh
- MFA challenges

### Data Access Events
- File read/write/delete
- Database queries
- API calls

### Security Events
- Trust score changes
- Guardrail triggers
- Syscall violations
- Malicious skill detection

## Log Format

```
[TIMESTAMP] [LEVEL] [COMPONENT] [EVENT_TYPE] Message
2026-03-01T10:30:00Z INFO CLAWDBOT AUTH User login successful: user@example6-03-.com
20201T10:30:15Z WARN MOLTBOT TRUST Trust score dropped below 80: agent-42
```

## Compliance

### SOC 2 Requirements
- Immutable logs
- 90-day retention minimum
- Annual log reviews

### HIPAA Requirements
- 6-year PHI access logs
- Audit trail for all PHI access

---
*ASF-28 Audit Logging*
