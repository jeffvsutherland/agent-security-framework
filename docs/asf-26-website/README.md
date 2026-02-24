# ASF-26: Agent Security Framework Website

## Overview
The ASF website at scrumai.org/agentsecurityframework serves as the public-facing portal for the Agent Security Framework.

## Threat Model

### Who might attack?
- Malicious actors trying to probe for vulnerabilities
- Fake agents attempting to impersonate legitimate services
- Spammers/abusers targeting the registration or contact forms
- Competitors scraping content

### What attacks?
- DDoS/Brute force attempts
- XSS/CSRF in user-generated content
- SQL injection in search/query functions
- Credential stuffing on admin login
- API abuse from agent integrations

## Security Controls

### 1. HTTPS & TLS
```nginx
# Force HTTPS
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
```

### 2. Web Application Firewall
- Rate limiting on forms (10 req/min)
- Bot detection / CAPTCHA on contact forms
- Block known malicious IPs

### 3. Hardened Docker Stack
```yaml
services:
  wordpress:
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
```

### 4. Integration with ASF Tools
- Run `fake-agent-detector.sh` on any agent registration
- Log to `port-scan-detector.sh` for anomaly detection
- Use YARA rules for uploaded file scanning

## Existing Resources
- ASF-26-URGENT-WEBSITE-UPDATE.md

---
*Last Updated: 2026-02-23*
