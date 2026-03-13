# ASF-63: Custom Security Headers for /agentsecurityframework

**Status:** DONE  

## Overview
Add custom security headers to the /agentsecurityframework path for verification, debugging, and trust attestation.

## Implementation

### Nginx Configuration

```nginx
location /agentsecurityframework {
    # Version & Trust Headers
    add_header X-ASF-Version "1.0" always;
    add_header X-ASF-Trust-Level "audited-v1" always;
    
    # Security Headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
}
```

## Rationale

### Why This Path?
- Provides verifiable surface for remote Clawdbot+ installs (per ASF-49)
- Partners/clients can curl & check header presence → loose "ASF-protected" attestation
- Debugging: Confirm traffic routing to ASF-protected endpoints
- Future extensibility: Dynamic X-ASF-Trust-Level based on runtime score

### Security Benefits
- **X-Content-Type-Options**: Prevents MIME-sniffing attacks
- **X-Frame-Options**: Prevents clickjacking
- **Referrer-Policy**: Controls referrer information leakage
- **Content-Security-Policy**: Mitigates XSS attacks
- **Strict-Transport-Security**: Enforces HTTPS
- **Permissions-Policy**: Blocks access to sensitive browser features

## Testing

### CI Verification
Add to CI pipeline:
```bash
curl -I https://scrumai.org/agentsecurityframework | grep -E "X-ASF|X-Content-Type|X-Frame|Content-Security"
```

Expected output:
- X-ASF-Version: 1.0
- X-ASF-Trust-Level: audited-v1
- X-Content-Type-Options: nosniff
- X-Frame-Options: DENY

## WAF Integration
Optional: Use header presence/absence in WAF rules to tag/score suspicious traffic.

## Status
- [x] Basic deployment (branding phase)
- [ ] Full security headers bundle
- [ ] CI verification added
- [ ] Documentation complete

## Related Stories
- ASF-38: Trust Framework
- ASF-45: Automated Fix Prompts
- ASF-49: Remote Partner Installation

*Version: 1.1 | Updated: March 7, 2026*
