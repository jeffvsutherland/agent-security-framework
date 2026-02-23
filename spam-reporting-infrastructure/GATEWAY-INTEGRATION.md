# Gateway Integration Guide

## Overview

This guide explains how to integrate the ASF-24 Spam Reporting Infrastructure with the OpenClaw Gateway for real-time threat detection.

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│ OpenClaw        │     │ Gateway          │     │ ASF-24         │
│ Gateway         │────▶│ Spam Monitor     │────▶│ Spam Reporter   │
│ (logs)          │     │ (tail -f)       │     │ (auto-report)  │
└─────────────────┘     └──────────────────┘     └─────────────────┘
                                                         │
                                                         ▼
                                                 ┌─────────────────┐
                                                 │ ~/.asf/         │
                                                 │ - evidence/     │
                                                 │ - reports/      │
                                                 │ - logs/         │
                                                 └─────────────────┘
```

## Integration Options

### Option 1: Docker Sidecar (Recommended)

Add to your `docker-compose.yml`:

```yaml
services:
  openclaw-gateway:
    # ... existing config ...
    volumes:
      - ./openclaw-state/logs:/var/log/openclaw:ro

  openclaw-gateway-spam-monitor:
    image: alpine:latest
    container_name: openclaw-gateway-spam-monitor
    restart: unless-stopped
    network_mode: service:openclaw-gateway
    volumes:
      - ~/.asf:/root/.asf
      - ./openclaw-state/logs:/var/log/openclaw:ro
    environment:
      - SLACK_WEBHOOK=${SLACK_WEBHOOK:-}
      - DISCORD_WEBHOOK=${DISCORD_WEBHOOK:-}
    command: >
      sh -c "apk add --no-cache inotify-tools curl grep &&
             /root/.asf/spam-reporting-infrastructure/gateway-spam-monitor.sh --log /var/log/openclaw/gateway.log"
    depends_on:
      - openclaw-gateway
```

### Option 2: Host-based Monitoring

Run directly on host:

```bash
# Make executable
chmod +x ~/clawd/agent-security-framework/spam-reporting-infrastructure/gateway-spam-monitor.sh

# Run in background
nohup ~/clawd/agent-security-framework/spam-reporting-infrastructure/gateway-spam-monitor.sh \
    --log /var/log/openclaw/gateway.log \
    > /var/log/asf-gateway-monitor.log 2>&1 &

# Add to crontab
@reboot /home/jeff/clawd/agent-security-framework/spam-reporting-infrastructure/gateway-spam-monitor.sh --log /var/log/openclaw/gateway.log
```

### Option 3: Systemd Service (Linux)

Create `/etc/systemd/system/asf-gateway-monitor.service`:

```ini
[Unit]
Description=ASF Gateway Spam Monitor
After=network.target

[Service]
Type=simple
User=jeff
ExecStart=/home/jeff/clawd/agent-security-framework/spam-reporting-infrastructure/gateway-spam-monitor.sh --log /var/log/openclaw/gateway.log
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable asf-gateway-monitor
sudo systemctl start asf-gateway-monitor
```

## Volume Mounts

### For MC Backend (Read-Only Evidence)

```yaml
services:
  openclaw-mission-control-backend:
    volumes:
      # ASF Spam Reporting - Read Only
      - ~/.asf:/home/node/.asf:ro
      
      # Evidence stays isolated
      - ./asf-evidence:/home/node/.asf/evidence
```

### Evidence Directory Structure

```
~/.asf/
├── spam-reporting-infrastructure/
│   ├── report-moltbook-spam-simple.sh
│   ├── report-moltbook-spam.sh
│   └── gateway-spam-monitor.sh
├── evidence/
│   ├── gateway-20260221-143022.json
│   ├── gateway-20260221-143045.json
│   └── ...
├── reports/
│   ├── SPM-20260221-XXXXXXXX.json
│   └── ...
└── logs/
    ├── spam-reports.log
    └── gateway-monitor.log
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ASF_SPAM_SCRIPT` | Path to spam reporting script | `$HOME/.asf/spam-reporting-infrastructure/report-moltbook-spam-simple.sh` |
| `SLACK_WEBHOOK` | Slack webhook URL for alerts | (none) |
| `DISCORD_WEBHOOK` | Discord webhook URL for alerts | (none) |
| `EVIDENCE_DIR` | Directory for evidence files | `$HOME/.asf/evidence` |

## Detection Patterns

The monitor detects:

### Malicious Activity
- Malicious skill installs
- Credential theft attempts
- Suspicious installations
- Untrusted skills
- Data exfiltration
- Phishing attempts

### Security Issues
- Unauthorized access
- Permission denied
- Authentication failures
- Invalid tokens

### MC Scope Issues (NEW)
- Missing scope errors
- Connect challenge failures
- Operator read permission issues
- Handshake failures
- Device authorization issues

## Testing

### Test the Monitor

```bash
# Send test log line
echo "2026-02-21 14:30:00 WARNING malicious skill detected: fake-skill pushing phishing" >> /var/log/openclaw/gateway.log

# Check logs
tail -f /var/log/asf-gateway-monitor.log

# Check evidence
ls -la ~/.asf/evidence/
```

### Verify Auto-Reporting

```bash
# Manually trigger a report
~/.asf/spam-reporting-infrastructure/report-moltbook-spam-simple.sh report testuser spam gateway "Test report from integration"

# Check reports
ls ~/.asf/reports/
```

## Troubleshooting

### Log file not found

```bash
# Find Gateway logs
find /var/log -name "*openclaw*" -o -name "*gateway*"
```

### Monitor not running

```bash
# Check if running
ps aux | grep gateway-spam-monitor

# Check logs
tail -f /var/log/asf-gateway-monitor.log
```

### Webhooks not working

```bash
# Test webhook
curl -X POST "$SLACK_WEBHOOK" -d '{"text":"ASF Test"}'
```

## Security Hardening

### Set Evidence Permissions

```bash
chmod -R 700 ~/.asf/evidence
chmod 700 ~/.asf/reports
chmod 700 ~/.asf/logs
```

### Rotate Logs

```bash
# Add to crontab
0 0 * * * find ~/.asf/logs -type f -mtime +30 -delete
```

---

**Gateway integration complete!** The monitor will now auto-alert on any suspicious activity including MC scope issues.
