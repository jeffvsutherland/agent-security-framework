# ASF-24 Final Hardening Steps

## 1. Mount ~/.asf/ as RO Volume into MC Backend

Add to `docker-compose.yml`:

```yaml
services:
  openclaw-mission-control-backend:
    volumes:
      # ASF Spam Reporting Infrastructure - Read Only
      - ~/.asf:/home/node/.asf:ro
      
      # Evidence stays isolated - never writable from container
```

## 2. Add moltbook-spam-monitor.sh to Cron (MC Container)

Create `mc-cron-entry`:

```bash
# Add to MC container Dockerfile or entrypoint
# Daily spam monitor sweep at 3 AM
0 3 * * * /home/node/.asf/spam-reporting-infrastructure/moltbook-spam-monitor.sh >> /var/log/asf-spam-monitor.log 2>&1
```

Or as Kubernetes cronjob:

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: asf-spam-monitor
spec:
  schedule: "0 3 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: monitor
            image: openclaw-mission-control-backend
            command: ["/home/node/.asf/spam-reporting-infrastructure/moltbook-spam-monitor.sh"]
          restartPolicy: OnFailure
```

## 3. Gateway → MC → Reporter Pipeline

When MC ↔ Gateway connects, use this to pipe operator-scope events:

```bash
# In Gateway or MC config
# Stream operator events to spam reporter

# Option A: WebSocket → Reporter
tail -f /var/log/openclaw-operator.log | jq -r '.operator + " " + .action' | \
  while read operator action; do
    if [ "$action" = "skill_install" ]; then
      ~/.asf/spam-reporting-infrastructure/report-moltbook-spam-simple.sh \
        report "$operator" spam gateway "Operator skill install: $operator"
    fi
  done

# Option B: MC API → Reporter
# Poll MC for new operator-scope events
while true; do
  curl -s http://localhost:8001/api/v1/events?type=operator \
    | jq -r '.[] | select(.action=="skill_install") | .operator' \
    | while read operator; do
      ~/.asf/spam-reporting-infrastructure/report-moltbook-spam-simple.sh \
        report "$operator" spam mc "MC operator event: $operator"
    done
  sleep 60
done
```

## 4. Evidence Directory Permissions

```bash
# Set evidence dir to owner-only access
chmod -R 700 ~/.asf/evidence

# Add to ~/.asf/spam-reporting-infrastructure/setup.sh:
setup_permissions() {
    echo "Setting evidence directory permissions..."
    mkdir -p ~/.asf/evidence ~/.asf/reports ~/.asf/logs
    chmod -R 700 ~/.asf/evidence
    chmod 750 ~/.asf/reports ~/.asf/logs
    echo "✅ Permissions locked: 700 (owner-only)"
}
```

## Quick Setup Script

```bash
#!/bin/bash
# ASF-24 Final Hardening - Run on host

echo "🔒 ASF-24 Final Hardening..."

# 1. Set permissions
echo "1. Locking evidence directory..."
chmod -R 700 ~/.asf/evidence 2>/dev/null || echo "   (evidence dir not created yet)"

# 2. Create directories
echo "2. Creating ASF directories..."
mkdir -p ~/.asf/evidence ~/.asf/reports ~/.asf/logs ~/.asf/spam-reporting-infrastructure

# 3. Copy scripts
echo "3. Copying spam reporting scripts..."
cp -r /path/to/agent-security-framework/spam-reporting-infrastructure/* ~/.asf/spam-reporting-infrastructure/
chmod +x ~/.asf/spam-reporting-infrastructure/*.sh

# 4. Verify
echo "4. Verification:"
ls -la ~/.asf/
ls -la ~/.asf/spam-reporting-infrastructure/

echo "✅ ASF-24 Hardening Complete!"
echo ""
echo "Next steps:"
echo "  1. Add to docker-compose: ~/.asf:/home/node/.asf:ro"
echo "  2. Setup cron: 0 3 * * * ~/.asf/spam-reporting-infrastructure/moltbook-spam-monitor.sh"
echo "  3. Connect MC ↔ Gateway for operator events"
```

---

**Full stack security locked!** 🦞🔒
