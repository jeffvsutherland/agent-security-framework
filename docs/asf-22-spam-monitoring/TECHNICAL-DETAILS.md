# ASF-22 Spam Monitoring - Technical Details

## Core Implementation

The spam monitoring system is implemented in: `security-tools/moltbook-spam-monitor.sh`

## Features

### 1. Keyword/Pattern Matching
- Spam keywords detection
- Entropy checks on outbound content
- Suspicious URL patterns

### 2. Rate-Based Detection
- Messages per minute threshold
- Messages per hour threshold
- Burst detection

### 3. Behavioral Analysis
- Repetitive content detection
- Unusual destination analysis
- Anomaly scoring

## Input Sources

### Log Tailing
```bash
tail -f /var/log/openclaw.log
```

### Container Stdout Capture
```bash
docker logs -f openclaw-gateway 2>&1 | grep "message"
```

## Integration

### Docker Healthcheck
```yaml
services:
  openclaw-gateway:
    healthcheck:
      test: ["CMD", "pgrep", "moltbook-spam-monitor"]
      interval: 30s
```

### Sidecar Pattern
```yaml
services:
  gateway:
    image: openclaw-gateway
    
  spam-monitor:
    image: alpine
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: tail -f /var/log/containers/gateway.log
```

## Threshold Tuning

```bash
# Adjust in moltbook-spam-monitor.sh
MESSAGES_PER_MINUTE=10
MESSAGES_PER_HOUR=100
ENTROPY_THRESHOLD=4.5
```

## Alert Configuration

### Slack Integration
```bash
export SLACK_WEBHOOK="https://hooks.slack.com/services/xxx"
```

### Discord Integration  
```bash
export DISCORD_WEBHOOK="https://discord.com/api/webhooks/xxx"
```

## False Positive Handling

1. Whitelist trusted sources
2. Adjust entropy threshold
3. Add content fingerprint exceptions

## Automated Response

### Quarantine Agent
```bash
# Pause suspicious agent
docker pause openclaw-agent-$AGENT_ID

# Kill switch
docker kill openclaw-agent-$AGENT_ID
```

### Notify Admin
```bash
curl -X POST $ADMIN_WEBHOOK -d "Spam detected from agent $AGENT_ID"
```

## Integration with ASF-17/ASF-20

Reports can feed into:
- Enterprise Dashboard (ASF-17)
- REST API (ASF-20)
- Bad actor database

See: ASF-17-ENTERPRISE-DASHBOARD.md, ASF-ENTERPRISE-API-ENDPOINTS.md
