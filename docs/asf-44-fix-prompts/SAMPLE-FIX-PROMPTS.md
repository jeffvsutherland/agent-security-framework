# Sample FIX-PROMPTS - Example Output
## Generated: 2026-02-28

### Fix 1: Container Isolation (Layer 3) - FAIL

**Prompt:**
```
Create a Dockerfile that:
- Uses a non-root user (USER 1000)
- Drops all capabilities (cap_drop: ALL)
- Mounts /tmp as tmpfs with noexec
- Uses read-only rootfs
- Adds security-opt: no-new-privileges:true

Save as: docker-templates/secure/Dockerfile
```

**Applied to:** ASF-42 / ASF-41
**Status:** Pending review

---

### Fix 2: Backup & Recovery (Layer 9) - PARTIAL

**Prompt:**
```
Create an automated backup script that:
- Backs up ~/.asf directory daily
- Encrypts backups with GPG
- Uploads to S3-compatible storage
- Tests restore procedure monthly

Save as: scripts/backup-asf.sh
```

**Applied to:** ASF-35
**Status:** Pending review

---

*This is a sample output. Run asf-fix-prompt-generator.py to generate actual fixes.*
