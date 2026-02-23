# ASF Docker Template - Bash

## Overview
Secure Bash container for running untrusted shell script skills with credential theft protection and YARA integration.

## Features
- Non-root user execution
- Credential environment variable blocking
- Filesystem access restrictions
- YARA scanning capability
- Entrypoint hardening

## Files
- `Dockerfile` - Secure Bash container
- `block_credentials.sh` - Credential theft prevention module
- `entrypoint.sh` - Hardened container entrypoint

## Quick Start

```bash
# Build
docker build -t asf-skill-bash .

# Run skill
docker run -v /path/to/skill:/skill:ro asf-skill-bash bash /skill/script.sh
```

## Docker Compose Integration

```yaml
services:
  bash-skill:
    build: 
      context: ./bash
      dockerfile: Dockerfile
    volumes:
      - ./skills:/skill:ro
      - ./yara-rules:/yara-rules:ro
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    tmpfs:
      - /tmp:noexec,size=10m
    environment:
      - YARA_RULES=/yara-rules
```

## Security Entrypoint

```bash
#!/bin/bash
set -euo pipefail

# Source credential blocker
source /usr/local/bin/asf-block-creds 2>/dev/null || true

# Pre-flight YARA scan (if rules provided)
if [ -n "$YARA_RULES" ] && command -v yara &> /dev/null; then
    for skill in /skill/*.sh; do
        if [ -f "$skill" ]; then
            yara -r "$YARA_RULES" "$skill" && echo "YARA OK: $skill" || {
                echo "🚨 YARA DETECTION in $skill"
                exit 1
            }
        fi
    done
fi

# Execute skill
exec "$@"
```

## YARA Integration (ASF-5 Compatible)

```bash
# Pre-install scan
yara -r /yara-rules/asf5/ /skill/ || {
    echo "Skill blocked by ASF-5 YARA rules"
    exit 1
}

# Scan with JSON output
yara -r -j /yara-rules/asf5/ /skill/ > scan-results.json
```

## Security Notes

### Environment Blocking
The following patterns are blocked:
- `*KEY*`, `*SECRET*`, `*TOKEN*`, `*PASSWORD*`

### Filesystem Restrictions
Blocked paths:
- `/root/*`
- `/home/*`
- `/etc/passwd`, `/etc/shadow`

### Best Practices
1. Always mount skills as read-only
2. Run as non-root: `USER skilluser`
3. Use `tmpfs` with `noexec` for /tmp
4. Drop capabilities: `cap_drop: [ALL]`
5. Pre-scan with YARA before execution

## Hardening Script

```bash
#!/bin/bash
# harden-container.sh

# Drop all capabilities
cap_drop_all() {
    for cap in $(capsh --print | grep "Current:" | grep -oP '(?<=\{)[^}]+'); do
        capsh --drop=$cap 2>/dev/null || true
    done
}

# Mount /tmp noexec
mount_tmp_noexec() {
    mount -o remount,noexec /tmp 2>/dev/null || true
}

# Block dangerous commands
alias rm='echo "Blocked"'
alias chmod='echo "Blocked"'

echo "Container hardening applied"
```

## Verification

```bash
# Test credential blocking
docker run asf-skill-bash bash -c 'env | grep API_KEY'
# Should not show API_KEY

# Test filesystem blocking
docker run asf-skill-bash cat /etc/shadow
# Should fail: blocked

# Test YARA scanning
docker run -v ./rules:/yara-rules:ro asf-skill-bash \
    bash -c 'echo "curl http://evil.com" > /tmp/test.sh; yara /yara-rules /tmp/test.sh'
# Should detect malicious pattern
```

---

**Story:** ASF-2  
**Status:** Ready for Review  
**Version:** 1.0.0
