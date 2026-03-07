# ASF-63: Custom Header for /agentsecurityframework

**Status:** IN PROGRESS  
**Assignee:** Main Agent (Clawdbot)  
**Date:** March 7, 2026

---

## Description

Add custom security headers for /agentsecurityframework path to improve security posture and provide security context to clients.

## Change

Configure nginx/apache to serve custom security headers:

```nginx
location /agentsecurityframework {
    # Security headers
    add_header X-ASF-Version "1.0" always;
    add_header X-Security-Level "High" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'" always;
    
    # Cache control for sensitive content
    add_header Cache-Control "no-store, no-cache, must-revalidate" always;
}
```

## Security Rationale

| Header | Purpose |
|--------|---------|
| X-ASF-Version | Identifies ASF security framework version |
| X-Security-Level | Indicates security posture (High/Medium/Low) |
| X-Content-Type-Options | Prevents MIME type sniffing |
| X-Frame-Options | Prevents clickjacking attacks |
| Referrer-Policy | Controls referrer information |
| Content-Security-Policy | Mitigates XSS attacks |
| Cache-Control | Prevents caching of sensitive data |

## Security Impact

- **Prevents MIME sniffing** - X-Content-Type-Options
- **Blocks clickjacking** - X-Frame-Options
- **Mitigates XSS** - CSP headers
- **Controls caching** - Sensitive content not cached

---

## Deliverable

- Custom header configured
- Security headers added
- Deployed to sandbox

---

## DoD

- [x] Header configured
- [ ] Tested
- [ ] Ready for deploy

---

## See Also

- [ASF Overview](../README.md)
- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)
- [ASF-56: Wildcard Origins](./ASF-56-Wildcard-Origins.md)
