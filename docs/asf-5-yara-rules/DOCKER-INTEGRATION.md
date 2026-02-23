# Docker Integration - ASF YARA Rules

## Mount YARA Rules into Containers

### docker-compose.yml Integration

```yaml
services:
  openclaw-gateway:
    volumes:
      - ./docs/asf-5-yara-rules:/home/node/.openclaw/yara/asf5:ro

  openclaw-mission-control-backend:
    volumes:
      - ./docs/asf-5-yara-rules:/app/yara/asf5:ro
```

## Runtime Scanning

### Skill Install Hook

Create `/usr/local/bin/asf-scan-skill.sh`:

```bash
#!/bin/bash
# ASF YARA Scanner - Skill Install Hook
# Run before: clawdbot skill install <skill>

SKILL_PATH="$1"
RULES_DIR="/home/node/.openclaw/yara/asf5"
LOG_FILE="/var/log/asf-yara-scan.log"

if [ -z "$SKILL_PATH" ]; then
    echo "Usage: $0 <skill-path-or-name>"
    exit 1
fi

# Resolve skill path
if [ -d "/opt/homebrew/lib/node_modules/clawdbot/skills/$SKILL_PATH" ]; then
    SCAN_PATH="/opt/homebrew/lib/node_modules/clawdbot/skills/$SKILL_PATH"
elif [ -d "$SKILL_PATH" ]; then
    SCAN_PATH="$SKILL_PATH"
else
    echo "Skill not found: $SKILL_PATH"
    exit 1
fi

echo "[$(date)] Scanning skill: $SCAN_PATH" >> "$LOG_FILE"

# Run YARA scan
if command -v yara &> /dev/null; then
    matches=$(yara -r "$RULES_DIR" "$SCAN_PATH" 2>/dev/null)
    if [ -n "$matches" ]; then
        echo "[$(date)] 🚨 MALICIOUS PATTERNS DETECTED in $SKILL_PATH:" >> "$LOG_FILE"
        echo "$matches" >> "$LOG_FILE"
        echo "🚨 SECURITY ALERT: Malicious patterns detected in skill '$SKILL_PATH'"
        echo "Scan results:"
        echo "$matches"
        exit 1  # Block installation
    else
        echo "[$(date)] ✅ Scan passed: $SKILL_PATH" >> "$LOG_FILE"
        echo "✅ YARA scan passed for $SKILL_PATH"
    fi
else
    echo "⚠️ YARA not installed - skipping scan"
fi
```

### Make executable

```bash
chmod +x /usr/local/bin/asf-scan-skill.sh
```

### Wrapper for clawdbot

Add to `/opt/homebrew/bin/clawdbot` before skill install:

```bash
# ASF YARA Scan Hook
if [ "$1" = "skill" ] && [ "$2" = "install" ]; then
    /usr/local/bin/asf-scan-skill.sh "$3"
fi
```

## Cron Job - Daily Host Scan

### macOS LaunchAgent

Create `~/Library/LaunchAgents/com.asf.yara-scanner.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.asf.yara-scanner</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/asf-daily-scan.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>RunAtLoad</key>
    <false/>
</dict>
</plist>
```

### Scan Script - ~/clawd/asf-daily-scan.sh

```bash
#!/bin/bash
# ASF Daily YARA Scanner
# Scans OpenClaw state directory for threats

RULES_DIR="$HOME/clawd/agent-security-framework/docs/asf-5-yara-rules"
STATE_DIR="$HOME/.clawdbot"
LOG_DIR="$HOME/.clawdbot/logs"
DATE=$(date +%Y-%m-%d)

mkdir -p "$LOG_DIR"

echo "[$(date)] Starting daily ASF YARA scan..."

# Find all scripts and scan
find "$STATE_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" \) -print0 | \
    xargs -0 -n1 yara -r "$RULES_DIR" 2>/dev/null | \
    while read -r line; do
        echo "[$DATE] 🚨 THREAT DETECTED: $line" >> "$LOG_DIR/asf-scan-$DATE.log"
        # Send alert
        echo "🚨 ASF Alert: Threat detected - $line"
    done

echo "[$(date)] Daily scan complete"
```

```bash
# Setup
chmod +x ~/clawd/asf-daily-scan.sh
launchctl load ~/Library/LaunchAgents/com.asf.yara-scanner.plist
```

## Ubuntu/Linux Cron

```bash
# Add to crontab (crontab -e)
0 3 * * * /home/node/clawd/asf-daily-scan.sh >> /var/log/asf-yara.log 2>&1
```

## Sigma Rules Integration (Optional)

### sigma_rules/asf-suspicious-skill-log.yaml

```yaml
title: Suspicious Skill Activity
id: asf-001
status: experimental
description: Detects suspicious skill behavior
logsource:
  category: process_creation
  product: openclaw
detection:
  selection:
    Image|contains:
      - 'clawdbot'
      - 'openclaw'
    CommandLine|contains:
      - 'curl '
      - 'wget '
      - 'os.environ'
      - '.env'
  condition: selection
level: high
tags:
  - attack.exfiltration
  - attack.t1041
```

---

**Security Hardening Complete!** 🦞🔒
