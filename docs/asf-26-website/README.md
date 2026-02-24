# ASF-26: Website Security

## Overview
ASF-26 provides security hardening for web interfaces, dashboards, and public-facing websites used by the ASF stack.

## Threat Model

### Who attacks websites?
- Bot networks scanning for vulnerabilities
- Credential stuffing attacks
- XSS/Injection attempts
- DDoS attacks
- Malicious agent scripts

### What needs protection?
- Public website/dashboard (WordPress, custom)
- Admin interfaces
- API endpoints
- User authentication

## Security Controls

### 1. HTTPS Enforcement
- TLS 1.3 minimum
- Strong cipher suites
- HSTS enabled
- Certificate rotation

### 2. Web Application Firewall
```yaml
# nginx.conf security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

### 3. Rate Limiting
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=login:10m rate=1r/s;
```

### 4. Bot Detection
- CAPTCHA on sensitive forms
- User-Agent filtering
- Behavioral analysis
- JS challenge for suspicious clients

### 5. Authentication
- OIDC/SAML integration for enterprise
- mTLS for agent-to-website communication
- API keys with expiration
- JWT with short expiry

### 6. Protection Against Agent Threats
- Fake-agent-detector.sh integration
- Prompt injection detection
- Malicious skill blocking

## Docker Hardening

### docker-compose.yml
```yaml
services:
  web:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp:exec,size=100m
    cap_drop:
      - ALL
    networks:
      - internal
```

## Integration with ASF Tools

| Tool | Integration |
|------|-------------|
| fake-agent-detector.sh | Scan before page render |
| port-scan-detector.sh | Monitor for reconnaissance |
| infrastructure-security-check.sh | Daily healthcheck |

## Deployment Checklist

- [ ] HTTPS with valid cert
- [ ] Security headers configured
- [ ] Rate limiting enabled
- [ ] Bot detection active
- [ ] WAF rules applied
- [ ] Logging to central system
- [ ] Backup & recovery tested
- [ ] Penetration tested

## Related ASF Stories
- ASF-2: Docker templates (container hardening)
- ASF-5: YARA rules (malware scanning)
- ASF-22: Spam monitoring (content protection)
- ASF-20: Enterprise integration (SSO/SAML)

---
**Status:** Ready for Review
**Version:** 1.0.0
