# ASF Spam Reporting - Docker Integration Guide

## Overview
This guide covers integrating ASF-24 Spam Reporting with Docker containers (Mission Control, Gateway).

## 1. Mount ~/.asf/ as Read-Only Volume

Add to your docker-compose.yml:

```yaml
services:
  openclaw-mission-control-backend:
    volumes:
      # Mount spam reporting as read-only
      - ~/.asf:/home/node/.asf:ro
      
      # Evidence directory (read-only for security)
      - ~/.asf/evidence:/home/node/.asf/evidence:ro
```

**Security:** The `:ro` flag ensures the container cannot modify evidence - protecting chain-of-custody.

## 2. Add Spam Monitor to Cron

Create a cron entry inside the container:

```bash
# Inside container or in crontab
0 3 * * * /home/node/.asf/scripts/moltbook-spam-monitor.sh >> /var/log/spam-monitor.log 2>&1
```

Or via docker-compose:

```yaml
services:
  openclaw-mission-control-backend:
    command: >
      sh -c "
        # Start cron
        cron &&
        # Start main application
        docker-entrypoint.sh
      "
```

## 3. Auto-Report from Gateway Logs

Add to docker-compose under openclaw-gateway:

```yaml
services:
  openclaw-gateway:
    command: >
      sh -c "
        # Monitor logs for suspicious activity
        tail -f /var/log/openclaw.log | grep -E 'skill install|malicious|suspicious' | \
        while read line; do
          echo \"Detected: $line\" >> /var/log/spam-auto.log
          # Report to ASF
          /home/node/.asf/scripts/report-moltbook-spam.sh report \
            \"auto-$(date +%s)\" \
            spam \
            gateway \
            \"Detected via log monitoring: $line\"
        done &
        # Start gateway
        /usr/local/bin/docker-entrypoint.sh
      "
```

## 4. Evidence Directory Permissions

Always lock evidence after finalizing:

```bash
# Lock entire evidence directory
chmod -R 700 ~/.asf/evidence

# Or per-report (automatic with finalize command)
~/.asf/report-moltbook-spam-simple.sh finalize SPM-20260221-A1B2C3D4
# Output: Evidence directory locked (chmod 700)
```

## 5. Complete docker-compose.yml Example

```yaml
version: '3.8'

services:
  openclaw-gateway:
    image: openclaw/gateway:latest
    container_name: openclaw-gateway
    volumes:
      - ./state:/home/node/.openclaw
      - ~/.asf:/home/node/.asf:ro
    environment:
      - OPENCLAW_ASF_REPORTING=true
    command: >
      sh -c "
        tail -f /var/log/openclaw.log | grep -E 'skill install|malicious' | \
        while read line; do
          /home/node/.asf/scripts/report-moltbook-spam.sh report \
            \"auto\" spam gateway \"$line\"
        done &
        /usr/local/bin/docker-entrypoint.sh
      "

  openclaw-mission-control-backend:
    image: openclaw/mission-control:latest
    container_name: openclaw-mc-backend
    volumes:
      - ./data:/app/data
      - ~/.asf:/home/node/.asf:ro
    environment:
      - ASF_SPAM_REPORTING=true

networks:
  default:
    name: asf-network
```

## 6. Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| ASF_PATH | Path to ASF directory | ~/.asf |
| ASF_EVIDENCE_PATH | Path to evidence | ~/.asf/evidence |
| OPENCLAW_ASF_REPORTING | Enable auto-reporting | false |
| SLACK_WEBHOOK | Slack webhook for alerts | - |

## 7. Verify Integration

```bash
# Test evidence mount
docker exec openclaw-mc-backend ls -la /home/node/.asf/

# Test spam report from container
docker exec openclaw-gateway /home/node/.asf/scripts/report-moltbook-spam.sh \
  report test-user spam test "Integration test"

# Check logs
docker logs openclaw-gateway | grep -i spam
```

---

**Related Documents:**
- [ASF-24 Spam Reporting README](./README.md)
- [ASF-5 YARA Rules](../docs/asf-5-yara-rules/)
- [Security Hardening](../docs/asf-5-yara-rules/SECURITY-HARDENING.md)

---
*Last Updated: 2026-02-21*
