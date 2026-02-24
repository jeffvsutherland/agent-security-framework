# ASF-26: Website Security

## Overview
Security hardening for public-facing and internal websites/dashboards used by ASF agents.

## Threat Model

### Who/What Attacks?
- External attackers targeting web interfaces
- Malicious agents attempting XSS/CSRF
- Botnets for DDoS/brute force
- Phishing via agent-controlled content

### Attack Vectors
- SQL injection
- XSS (cross-site scripting)
- CSRF (cross-site request forgery)
- Credential stuffing
- API abuse
- DDoS

## Security Controls

### 1. HTTPS & TLS
```nginx
# nginx.conf - TLS hardening
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

### 2. Web Application Firewall
```yaml
# docker-compose.yml with WAF
services:
  waf:
    image: modsecurity:apache
    volumes:
      - ./rules:/etc/modsecurity.d/rules
```

### 3. Rate Limiting
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req zone=api burst=20 nodelay;
```

### 4. Bot Detection
- CAPTCHA on sensitive forms
- User-Agent filtering
- Behavioral analysis

### 5. Authentication
- OIDC/SAML federation
- API keys for agent-to-agent
- mTLS for internal services

### 6. Logging & Monitoring
- Access logs with request/response bodies
- Anomaly detection
- Alerting on suspicious patterns

## Docker Hardening

```yaml
services:
  website:
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    environment:
      - SECURE_HEADERS=enabled
```

## Integration with ASF Tools

| Tool | Purpose |
|------|---------|
| `port-scan-detector.sh` | Detect port scans against web endpoints |
| `fake-agent-detector.sh` | Identify fake agent traffic |
| `infrastructure-security-check.sh` | Verify security configuration |

## References
- security-v3-comprehensive.md
- moltbook-security-proposal-v2.md

---

**Story:** ASF-26  
**Status:** Ready for Review  
**Version:** 1.0.0
