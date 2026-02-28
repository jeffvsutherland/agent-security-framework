# ASF-45: Automated Security Fix Prompt Generator

## Overview

ASF-45 integrates with ASF-44 bootup scan to automatically generate fix prompts for any security issues found.

## How It Works

1. Run bootup scan (ASF-44)
2. For each failing layer, generate a specific prompt
3. Output prompts to `FIX-PROMPTS-YYYY-MM-DD.md`
4. Agents execute prompts to fix issues

## Example Outputs

### Layer 3 (Container Isolation) - FAIL
**Generated Prompt:**
```
Create a Dockerfile that:
- Uses a non-root user (USER 1000)
- Drops all capabilities (cap_drop: ALL)
- Mounts /tmp as tmpfs with noexec
- Uses read-only rootfs
Save as: docker-templates/secure/Dockerfile
```

### Layer 9 (Backup & Recovery) - FAIL
**Generated Prompt:**
```
Create an automated backup script that:
- Backs up ~/.asf directory daily
- Encrypts backups with GPG
- Uploads to S3-compatible storage
- Tests restore procedure monthly
Save as: scripts/backup-asf.sh
```

## Usage

```bash
# Run with ASF-44
./asf-bootup-scan.sh --generate-fixes
# Outputs: FIX-PROMPTS-2026-02-28.md
```

## DoD

- [ ] Integrates with ASF-44 bootup scan
- [ ] Generates prompts for all 10 security layers
- [ ] Outputs human-readable fix prompts
- [ ] Tested with failing security layers
