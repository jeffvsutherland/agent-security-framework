# ASF-59: Gateway Rate Limiting Configuration

**Status:** IN REVIEW  
**Date:** March 2026  
**Purpose:** Prevent DoS/abuse from rogue agents or prompt floods

---

## Executive Summary

This document provides rate limiting configuration for the OpenClaw Gateway to protect against abuse, DoS attacks, and resource exhaustion from excessive agent requests.

---

## NGINX Rate Limiting Configuration

```nginx
# /etc/nginx/conf.d/rate-limit.conf

# Define rate limit zone
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=general_limit:10m rate=30r/s;

# Apply to server blocks
server {
    location /api/ {
        limit_req zone=api_limit burst=20 nodelay;
        limit_req_status 429;
        proxy_pass http://openclaw_backend;
    }

    location /auth/ {
        limit_req zone=auth_limit burst=10 nodelay;
        limit_req_status 429;
        proxy_pass http://openclaw_backend;
    }

    location / {
        limit_req zone=general_limit burst=50 nodelay;
        proxy_pass http://openclaw_backend;
    }
}
```

---

## OpenClaw Gateway Configuration (YAML)

```yaml
# openclaw-config.yaml
gateway:
  rate_limiting:
    enabled: true
    defaults:
      requests_per_minute: 60
      burst: 10
    
    endpoints:
      - path: /api/agent/*
        requests_per_minute: 30
        burst: 5
        
      - path: /api/message/*
        requests_per_minute: 100
        burst: 20
        
      - path: /auth/*
        requests_per_minute: 10
        burst: 3

  # Response when rate limited
  rate_limit_response:
    status_code: 429
    message: "Rate limit exceeded. Please retry after cooling period."
    retry_after_seconds: 60
```

---

## Rationale

| Endpoint | Rate Limit | Rationale |
|----------|------------|-----------|
| `/api/agent/*` | 30/min | Prevents agent spawn abuse |
| `/api/message/*` | 100/min | Allows high-volume messaging |
| `/auth/*` | 10/min | Prevents brute force attacks |
| General | 60/min | Default protection |

---

## Security Impact

- **Prevents DoS**: Stops single-source request floods
- **Rogue Agent Protection**: Limits excessive agent spawning
- **Resource Conservation**: Protects backend API costs

---

## Testing

```bash
# Test rate limiting with curl
for i in {1..35}; do
  curl -s -o /dev/null -w "%{http_code}\n" https://gateway.openclaw.ai/api/agent/spawn
done
# Should see 200 for first 30, then 429
```

---

## DoD Checklist

- [x] NGINX config documented
- [x] OpenClaw YAML config provided
- [x] Rationale for each limit documented
- [x] Security impact assessed
- [x] Testing procedure included

---

*Last Updated: 2026-03-08*
