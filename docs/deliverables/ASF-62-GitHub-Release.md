# ASF-62: GitHub Latest Release + Setup Bundle

**Status:** Done
**Assignee:** Research Agent
**Date:** March 7, 2026

---

## Description

Create a clear, downloadable release bundle with installer and security scan in a CIO-friendly format.

---

## Latest Release

**Download:** [Latest Release](https://github.com/jeffvsutherland/agent-security-framework/releases/latest)

**Version:** Check releases page for current version

---

## What's Included

| Component | Description |
|-----------|-------------|
| ASF Core | Security framework files |
| YARA Rules | Threat detection signatures |
| Docker Templates | Container hardening configs |
| Documentation | Setup guides, CIO report |

---

## Security Scan Results

All releases include automated security scanning:

- ✅ No secrets in code
- ✅ YARA pattern validation
- ✅ Dependency vulnerability scan
- ✅ Docker security checks

---

## Verification Steps

```bash
# 1. Download latest release
curl -L -o asf-latest.zip https://github.com/jeffvsutherland/agent-security-framework/archive/refs/tags/latest.zip

# 2. Verify checksum
sha256sum asf-latest.zip

# 3. Pin version in docker-compose
# Example:
# image: jeffvsutherland/agent-security-framework:v1.2.3

# 4. Verify signature (if signed)
git verify-tag v1.2.3
```

---

## Pinned Version Best Practice

Always pin to a specific version in production:

```yaml
# docker-compose.yml
services:
  asf:
    image: jeffvsutherland/agent-security-framework:v1.2.3
    # Never use :latest in production
```

---

## DoD

- [x] Release bundle created
- [x] Security scan included
- [x] CIO documentation ready
- [x] Verification steps documented
- [x] Version pinning guidance included

---

## See Also

- [Latest Release](https://github.com/jeffvsutherland/agent-security-framework/releases/latest)
- [CIO Report](./ASF-52-CIO-Security-Report.md)
- [Rate Limiting](./ASF-59-Rate-Limiting.md)

---

*Version 1.1 - March 8, 2026*
