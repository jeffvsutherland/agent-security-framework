# Gateway Spam Monitor - Docker Compose Integration

## Sidecar Service (Recommended)

Add this to your `docker-compose.yml` to auto-detect and report suspicious activity:

```yaml
services:
  openclaw-gateway:
    image: openclaw/gateway:latest
    # ... existing config
    
  gateway-spam-monitor:
    build: ./gateway-spam-monitor
    container_name: openclaw-spam-monitor
    volumes:
      - ./logs:/var/log:ro
      - ~/.asf:/home/node/.asf
    environment:
      - LOG_FILE=/var/log/openclaw.log
      - SPAM_REPORT=/home/node/.asf/tools/report-moltbook-spam-simple.sh
      - WEBHOOK_URL=${SLACK_WEBHOOK_URL}
      - AUTO_REPORT=true
      - POLL_INTERVAL=10
    restart: unless-stopped
    networks:
      - openclaw-network
    depends_on:
      - openclaw-gateway

# Or use existing gateway log directory
volumes:
  openclaw-logs:
```

## Cron-Based Alternative

If you can't run a sidecar, use cron:

```yaml
# In your gateway service
services:
  openclaw-gateway:
    image: openclaw/gateway:latest
    volumes:
      - ./logs:/var/log
      - ~/.asf:/home/node/.asf
    command: >
      sh -c "
        # Start gateway
        /usr/local/bin/openclaw-gateway &
        
        # Start cron-based spam monitor
        while true; do
          /home/node/.asf/tools/gateway-spam-monitor.sh scan
          sleep 300  # Check every 5 minutes
        done
      "
```

## Direct Log Tail (Simplest)

For quick testing without building:

```yaml
services:
  gateway-log-shipper:
    image: busybox
    command: >
      tail -f /var/log/openclaw.log | 
      grep -iE 'skill install.*malicious|skill install.*phishing|untrusted skill' |
      while read line; do
        echo "Alert: $line"
        # Add webhook call here
      done
    volumes:
      - ./logs:/var/log:ro
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_FILE` | Path to gateway log | `/var/log/openclaw.log` |
| `SPAM_REPORT` | Path to spam reporter | `~/.asf/tools/report-moltbook-spam-simple.sh` |
| `WEBHOOK_URL` | Slack/Discord webhook | (none) |
| `POLL_INTERVAL` | Seconds between checks | `10` |
| `AUTO_REPORT` | Auto-report or just alert | `true` |

## Detected Patterns

The monitor watches for:
- `skill install.*malicious`
- `skill install.*phishing`
- `skill install.*suspicious`
- `untrusted skill`
- `blocked.*skill`
- `exfiltrat*`
- `credential.*theft`
- `key.*exfil`
- `api.*token.*access`

## Testing

```bash
# Test pattern detection
./gateway-spam-monitor.sh test

# Run one-time scan
./gateway-spam-monitor.sh scan

# Start continuous monitoring
./gateway-spam-monitor.sh monitor
```
