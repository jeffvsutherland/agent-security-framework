# Docker Log Integration

## Method 1: docker logs (Recommended)

```bash
# Tail logs from a specific container
docker logs -f moltbook-agent --since 60m 2>&1 | grep -E 'action=post|action=dm' | ./moltbook-spam-monitor.sh -
```

## Method 2: Volume Mount

```yaml
# docker-compose.yml
services:
  moltbook:
    image: moltbook:latest
    volumes:
      - ./logs:/var/log/openclaw
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  spam-monitor:
    image: alpine:latest
    volumes:
      - ./logs:/var/log/openclaw:ro
    command: tail -f /var/log/openclaw/*.log | grep -E 'action=post|action=dm'
```

## Method 3: Sidecar Pattern

```yaml
services:
  moltbook:
    image: moltbook:latest
  
  spam-monitor:
    image: alpine:latest
    depends_on:
      - moltbook
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: >
      sh -c "docker logs -f moltbook 2>&1 | grep 'action=' | ./moltbook-spam-monitor.sh stdin"
```

## Health Endpoint

```bash
# Add to spam-monitor.sh
curl -s http://localhost:8080/health
# Response: {"status":"healthy","scanned":1234,"blocked":5}
```

## Prometheus Metrics

```bash
# metrics.sh
#!/bin/bash
echo "# HELP spam_scanned_total Total messages scanned"
echo "# TYPE spam_scanned_total counter"
echo "spam_scanned_total $(cat /tmp/spam_scanned)"

echo "# HELP spam_blocked_total Total spam blocked"
echo "# TYPE spam_blocked_total counter"  
echo "spam_blocked_total $(cat /tmp/spam_blocked)"
```
