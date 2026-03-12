# ASF-66: OpenClaw Upgrade to March 2026 Release

**Status:** IN PROGRESS  
**Assignee:** Deploy Agent  
**Date:** March 12, 2026

---

## Description

Upgrade OpenClaw from version 2026.2.19 to 2026.3.1.

## Changes

- Update version in configuration from 2026.2.19 to 2026.3.1
- Recreate containers with new image
- Verify all services operational

## Steps

```bash
# Stop current containers
docker-compose down

# Update image tag in docker-compose.yml
# From: openclaw:2026.2.19
# To: openclaw:2026.3.1

# Recreate containers
docker-compose up -d

# Verify health
curl http://localhost:8000/health
```

---

## DoD

- [ ] Version updated in config
- [ ] Containers recreated
- [ ] Health check passed
- [ ] All agents operational

---

## See Also

- [ASF-61: OpenClaw Updates](./ASF-61-OpenClaw-Update.md)
