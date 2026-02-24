# ASF-22: Automated Spam Monitoring

## Overview
Real-time detection and mitigation of spam generated or propagated by AI agents.

## Existing Implementation

The repo already includes the core monitoring tool:

### Main Tool: `moltbook-spam-monitor.sh`
- Location: `security-tools/moltbook-spam-monitor.sh`
- Runs automated daily scans
- Checks for suspicious patterns

### Gateway Integration: `gateway-spam-monitor.sh`
- Location: `spam-reporting-infrastructure/gateway-spam-monitor.sh`
- Real-time log tailing from OpenClaw Gateway
- Auto-detects: malicious skills, phishing, exfil, credential theft

## Features

### Detection Methods
1. **Keyword/Pattern Matching** - Spam, scam, harassment keywords
2. **Entropy Checks** - High-entropy content detection
3. **Rate-based Detection** - Messages per minute/hour
4. **Behavioral Signals** - Repetitive content, unusual destinations

### Integration
- Container logging → alerting
- Slack/Discord webhook support
- Reporting to ASF-24 bad actor database

### Response Actions
- Quarantine/kill-switch for spamming agents
- Auto-report to bad actor DB
- Admin notification via webhook

## Docker Integration

### Sidecar Pattern
```yaml
services:
  spam-monitor:
    image: asf/spam-monitor:latest
    volumes:
      - ./logs:/var/log/openclaw
    environment:
      - SLACK_WEBHOOK=${SLACK_WEBHOOK}
```

### Cron Job
```bash
# Daily scan
0 3 * * * /path/to/moltbook-spam-monitor.sh
```

## False Positive Handling

1. Review quarantine queue daily
2. Whitelist known safe agents
3. Adjust detection thresholds as needed

## Related Documents
- [ASF-24 Spam Reporting](../spam-reporting-infrastructure/)
- [Security Tools](../security-tools/)

---
*Last Updated: 2026-02-23*
