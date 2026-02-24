# Port Scanner Integration

## Cron-based Scanning

```bash
# Add to crontab (crontab -e)
0 3 * * * /home/node/agent-security-framework/security-tools/port-scan-detector.sh >> /var/log/port-scan.log 2>&1
```

## Sidecar Pattern

```yaml
# docker-compose.yml
services:
  website:
    image: nginx:alpine
    ports:
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
  
  port-scanner:
    image: alpine:latest
    network_mode: "service:website"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    command: >
      sh -c "apk add --no-cache docker-cli && 
             while true; do 
               /home/node/agent-security-framework/security-tools/port-scan-detector.sh; 
               sleep 3600; 
             done"
```

## Alert Integration

```bash
# In port-scan-detector.sh, add webhook:
if [ "$BLOCKED" -gt 0 ]; then
  curl -X POST "$SLACK_WEBHOOK" -d "{\"text\":\"🚨 Port scan detected: $BLOCKED attempts blocked\"}"
fi
```
