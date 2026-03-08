# ASF-59: Gateway Auth Rate Limiting

**Status:** Done
**Assignee:** Research Agent
**Date:** March 7, 2026

---

## Description

Configure gateway authentication rate limiting to prevent brute force attacks, prompt flooding, and DoS attempts from rogue agents.

---

## Sample Configuration

### OpenClaw Gateway (config.json)

```json
{
  "rateLimit": {
    "enabled": true,
    "maxAttempts": 10,
    "windowMs": 60000,
    "lockoutMs": 300000,
    "blockDuration": "5m"
  }
}
```

### NGINX Example

```nginx
http {
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;
    
    server {
        location /api/ {
            limit_req zone=api burst=20 nodelay;
        }
        
        location /auth/login {
            limit_req zone=auth burst=10 nodelay;
        }
    }
}
```

---

## Rationale

Rate limiting is critical for preventing:

- **Brute force attacks** on authentication endpoints
- **Prompt flooding** from compromised or malicious agents
- **DoS attacks** from external adversaries
- **Resource exhaustion** from excessive API calls

---

## Security Impact

| Threat | Mitigation |
|--------|------------|
| Brute force | Max 10 attempts/minute per IP |
| Prompt flooding | Rate limited to 10 req/s |
| Account takeover | 5-minute lockout after threshold |
| DoS | Connection throttling |

---

## DoD

- [x] Rate limiting configured with sample configs
- [x] Rationale documented
- [x] Security impact table included
- [x] Ready for deployment

---

## See Also

- [ASF Overview](../README.md)
- [Exposure Audit](./ASF-51-Exposure-Audit.md)
- [Trust Framework](./ASF-38-TRUST.md)

---

*Version 1.1 - March 8, 2026*
