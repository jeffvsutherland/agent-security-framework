# ASF-62: GitHub Latest Release + Setup Bundle

**Status:** REVIEW  
**Assignee:** Research Agent  
**Date:** March 7, 2026

---

## Description

Create clear download ZIP with installer and security scan. CIO-friendly format.

## Deliverables

- Downloadable setup bundle
- Security scan included
- CIO-friendly documentation

## Latest Release

[Latest Release](https://github.com/jeffvsutherland/agent-security-framework/releases/latest)

### Changes in Latest Release

- Security headers bundle (ASF-63)
- Rate limiting configuration (ASF-59)
- Exposure audit findings (ASF-51)

## Verification

```bash
# Verify pinned version in docker-compose
grep "image:" docker-compose.yml

# Verify requirements.txt
pip list | grep -f requirements.txt
```

## Security Impact

- Ensures latest security patches
- Provides verified installer
- Reduces vulnerability surface

---

## DoD

- [x] Bundle created
- [x] Security scan included
- [x] Release documented
- [x] Verification steps added

---

## See Also

- [GitHub Releases](https://github.com/jeffvsutherland/agent-security-framework/releases)
- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)
