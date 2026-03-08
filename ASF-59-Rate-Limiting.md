# ASF-59: Gateway Auth Rate Limiting

**Status:** REVIEW  
**Assignee:** Research Agent  
**Date:** March 7, 2026

---

## Description

Configure gateway authentication rate limiting to prevent brute force and DoS attacks.

## Configuration

### OpenClaw Gateway Config

```json
{
  "maxAttempts": 10,
  "windowMs": 60000,
  "lockoutMs": 300000
}
```

### NGINX Example

```nginx
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;

server {
    location /api/ {
        limit_req zone=one burst=20 nodelay;
    }
    
    location /auth/ {
        limit_req zone=one burst=5 nodelay;
    }
}
```

## Security Rationale

- **Prevents brute force** - Max 10 attempts per minute
- **Blocks DoS attacks** - Rate limiting on all endpoints
- **Account lockout** - 5 minute lockout after threshold

## Security Impact

- Prevents rogue agents or prompt floods
- Protects authentication endpoints
- Reduces attack surface

---

## DoD

- [x] Rate limiting configured
- [x] Config documented
- [x] Security rationale included
- [x] Ready for deploy

---

## See Also

- [ASF Overview](../README.md)
- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)
