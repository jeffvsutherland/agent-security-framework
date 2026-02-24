# ASF-22: Automated Spam Monitoring Tool

## Overview
ASF-22 provides real-time spam detection and mitigation for AI agent platforms (Moltbook, Discord, Telegram, etc.).

## Core Implementation

### Primary Tool: moltbook-spam-monitor.sh
**Location:** `security-tools/moltbook-spam-monitor.sh`

**Features:**
- Real-time pattern detection for spam content
- Keyword/entropy-based analysis
- Rate-based detection (messages per minute/hour)
- Behavioral signal analysis
- Integration with container logging
- Alerting via Slack/Discord webhooks

### Additional Tools
- `spam-reporting-infrastructure/report-moltbook-spam.sh` - Full spam reporting system
- `spam-reporting-infrastructure/report-moltbook-spam-simple.sh` - Lightweight version
- `spam-reporting-infrastructure/gateway-spam-monitor.sh` - Gateway-based monitoring

## Usage

### Basic Run
```bash
./security-tools/moltbook-spam-monitor.sh
```

### Configuration
Edit the script to configure:
- API_KEY for Moltbook
- BAD_ACTORS_DB location
- SPAM_LOG location
- Alert webhook URLs

### Threshold Tuning
Adjust these variables for your environment:
```bash
MAX_POSTS_PER_MINUTE=10
MAX_SIMILAR_CONTENT=3
ENTROPY_THRESHOLD=4.5
```

## Integration

### Docker Healthcheck
Add to your docker-compose.yml:
```yaml
spam-monitor:
  image: asf/spam-monitor
  volumes:
    - ./logs:/var/log
  healthcheck:
    test: ["CMD", "./healthcheck.sh"]
    interval: 30s
```

### Alert Webhook
Configure Slack/Discord webhook in environment:
```bash
export SLACK_WEBHOOK="https://hooks.slack.com/services/xxx"
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/xxx"
```

## False Positive Handling

1. Review `/var/log/asf/spam-false-positives.log`
2. Add exceptions to `whitelist.json`
3. Adjust threshold variables

## Automated Response Playbook

When spam detected:
1. ✅ Log alert to database
2. ✅ Notify via configured webhooks
3. ✅ Add bad actor to blocklist
4. ✅ Optionally pause offending agent
5. ✅ Generate incident report

## Acceptance Criteria

- ✅ Working shell script deployed
- ✅ Pattern detection for known spam types
- ✅ Heartbeat integration functional
- ✅ Alert system working (Slack/Discord webhooks)

## Related ASF Stories
- ASF-24: Spam Reporting Infrastructure (foundation)
- ASF-5: YARA rules for malware detection
- ASF-20: Enterprise integration for dashboard visibility

---
**Status:** Ready for Review
**Version:** 1.0.0
