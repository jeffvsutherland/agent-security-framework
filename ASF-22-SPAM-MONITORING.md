# ASF-22: Spam Monitoring

## Overview
Real-time detection and mitigation of spam generated or propagated by AI agents.

## Core Implementation

The ASF spam monitoring system is built on:
- `security-tools/moltbook-spam-monitor.sh` - Primary detection script
- `spam-reporting-infrastructure/` - Reporting and tracking

## Features

### Detection Methods
- Keyword/pattern matching
- Entropy checks on outbound content
- Rate-based detection (messages per minute/hour)
- Behavioral signals (repetitive content, unusual destinations)
- ML-based anomaly detection (optional)

### Detection Patterns
```bash
# Suspicious patterns to monitor
SUSPICIOUS_PATTERNS=(
    "crypto.*giveaway"
    "free.*bitcoin"
    "double.*your.*money"
    "investment.*opportunity"
    "act.*now.*limited"
    "urgent.*action.*required"
)
```

### Integration

#### Container Logging
```yaml
# docker-compose.yml
services:
  spam-monitor:
    image: alpine:latest
    volumes:
      - /var/log:/var/log:ro
    command: ./moltbook-spam-monitor.sh
```

#### Alerting
```bash
# Webhook notifications
curl -X POST "$WEBHOOK_URL" \
  -d "{\"text\": \"🚨 Spam detected: $MESSAGE\"}"
```

## Configuration

### Thresholds
| Metric | Default | Configurable |
|--------|---------|--------------|
| Messages/minute | 10 | `MAX_MSG_PER_MIN` |
| Repetition threshold | 3 | `REPEAT_THRESHOLD` |
| Entropy score | 4.5 | `ENTROPY_THRESHOLD` |

### Environment Variables
```bash
SPAM_WEBHOOK_URL="https://hooks.slack.com/xxx"
SPAM_QUARANTINE_DIR="/home/node/.asf/quarantine"
SPAM_LOG_FILE="/home/node/.asf/spam-monitor.log"
```

## Automated Response

### Kill Switch
```bash
# Pause spamming agent
docker pause $(docker ps -q --filter "name=spamming-agent")

# Notify
curl -X POST "$WEBHOOK_URL" \
  -d "{\"text\": \"⛔ Agent paused due to spam\"}"
```

### Quarantine
```bash
mv /tmp/suspicious /home/node/.asf/quarantine/
```

## Docker Healthcheck
```yaml
healthcheck:
  test: ["CMD", "./moltbook-spam-monitor.sh", "--health"]
  interval: 30s
  timeout: 10s
  retries: 3
```

## False Positive Handling

1. Whitelist patterns
2. Allow-list trusted users
3. Manual review queue
4. Feedback loop for tuning

## References
- `spam-reporting-infrastructure/` - Full reporting system
- `gateway-spam-monitor.sh` - Gateway log integration

---

**Story:** ASF-22  
**Status:** Ready for Review  
**Version:** 1.0.0
