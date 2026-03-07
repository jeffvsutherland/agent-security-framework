# ASF-63: Custom Header for /agentsecurityframework

**Status:** IN PROGRESS  
**Assignee:** Main Agent (Clawdbot)  
**Date:** March 7, 2026

---

## Description

Add custom security headers for /agentsecurityframework path to improve security posture and provide security context to clients. Supports agent trust ecosystem for remote Clawdbot+ installs per ASF-49.

## Change

Configure nginx/apache to serve comprehensive security headers:

```nginx
location /agentsecurityframework {
    # Core ASF headers
    add_header X-ASF-Version "1.0" always;
    add_header X-ASF-Trust-Level "audited-v1" always;
    
    # Security headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
    
    # Cache control for sensitive content
    add_header Cache-Control "no-store, no-cache, must-revalidate" always;
}
```

## Security Rationale

| Header | Purpose |
|--------|---------|
| X-ASF-Version | Identifies ASF security framework version |
| X-ASF-Trust-Level | Trust score (audited-v1 = 90/100) |
| X-Content-Type-Options | Prevents MIME type sniffing |
| X-Frame-Options | Prevents clickjacking attacks |
| Referrer-Policy | Controls referrer information |
| Content-Security-Policy | Mitigates XSS attacks |
| Strict-Transport-Security | Enforces HTTPS |
| Permissions-Policy | Blocks sensitive browser features |

## Testing

```bash
# Verify headers on staging
curl -I https://sandbox.example.com/agentsecurityframework

# CI verification (add to pipeline)
curl -s -o /dev/null -w "%{http_code}" -H "X-ASF-Version: 1.0"
```

## Security Impact

- **Prevents MIME sniffing** - X-Content-Type-Options
- **Blocks clickjacking** - X-Frame-Options
- **Mitigates XSS** - CSP headers
- **Enforces HTTPS** - HSTS
- **Blocks sensitive features** - Permissions-Policy

---

## Deliverable

- Custom header configured
- Security headers bundle (8 headers)
- Testing verification script

---

## DoD

- [x] Header configured
- [x] Security headers bundle added
- [ ] Tested on staging
- [ ] Ready for deploy

---

## See Also

- [ASF Overview](../README.md)
- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)
- [ASF-49: Remote Partner Installation](./ASF-49-Remote-Partner-Installation.md)
