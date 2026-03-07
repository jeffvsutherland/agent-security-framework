# ASF-63: Custom Header for /agentsecurityframework

**Status:** Done (Provisional - v2 update ready)
**Assignee:** Deploy Agent
**Date:** March 7, 2026

---

## Description

Add custom security headers for /agentsecurityframework path to enable trust verification and surface hardening.

## Change

Expanded nginx security headers:

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
}
```

## Rationale

This supports the agent trust ecosystem:
- **X-ASF-Version** - Version attestation for remote Clawdbot+ installs (per ASF-49)
- **X-ASF-Trust-Level** - Trust score verification for partners
- **Security headers** - Hardens browser surface, prevents common attacks

## Use Cases

1. **Verification** - Partners can curl & check headers → "ASF-protected" attestation
2. **Debugging** - Confirm traffic routing
3. **Future extensibility** - Dynamic X-ASF-Trust-Level based on runtime score
4. **WAF integration** - Header presence/absence for traffic scoring

## Testing

```bash
# Verify headers
curl -I https://sandbox.jvsmanagement.com/agentsecurityframework/

# Expected headers:
# X-ASF-Version: 1.0
# X-ASF-Trust-Level: audited-v1
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# Strict-Transport-Security: max-age=31536000...
```

## DoD

- [x] Expanded security headers defined
- [x] Rationale documented
- [x] Testing steps included
- [x] Aligns with ASF-38 trust runtime
- [x] Aligns with ASF-45 automated remediation

## See Also

- [ASF Overview](../README.md)
- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)
- ASF-38: Trust Framework
- ASF-45: Automated Fix Prompts

---

*Version 1.1 - March 7, 2026*
