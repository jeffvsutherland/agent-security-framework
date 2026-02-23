# Hourly Scrum Integration

## YARA Scan in Hourly Sprint Check

Add YARA scanning to your hourly sprint check for continuous security monitoring:

```bash
# Add to ASF-Hourly-Sprint-Check script
# YARA security scan for all skills

echo "=== YARA Security Scan ==="
yara -r $HOME/agent-security-framework/docs/asf-5-yara-rules/asf_credential_theft.yara \
    $HOME/.openclaw/skills/ 2>/dev/null && echo "✅ YARA clean" || echo "⚠️ YARA threats detected"
```

## Automated Hourly Check

Create `ASF-Hourly-YARA-Check.sh`:

```bash
#!/bin/bash
# ASF-18 Hourly YARA Security Check
# Run this in your hourly sprint check

RULES_DIR="$HOME/agent-security-framework/docs/asf-5-yara-rules"
SKILLS_DIR="$HOME/.openclaw/skills"
LOG_FILE="$HOME/.asf/logs/yara-hourly.log"

echo "[$(date)] Running YARA scan..."

if command -v yara &> /dev/null; then
    # Scan skills directory
    SCAN_RESULTS=$(yara -r "$RULES_DIR/asf_credential_theft.yara" "$SKILLS_DIR" 2>&1) || true
    
    if [ -n "$SCAN_RESULTS" ]; then
        echo "[$(date)] 🚨 THREATS DETECTED!" | tee -a "$LOG_FILE"
        echo "$SCAN_RESULTS" | tee -a "$LOG_FILE"
        
        # Send alert
        if [ -n "${SLACK_WEBHOOK:-}" ]; then
            curl -s -X POST "$SLACK_WEBHOOK" \
                -d "{\"text\":\"🚨 ASF YARA Alert: Threats detected in skills\"}" 2>/dev/null
        fi
        
        exit 1
    else
        echo "[$(date)] ✅ YARA scan clean - no threats detected" >> "$LOG_FILE"
    fi
else
    echo "[$(date)] ⚠️ YARA not installed - skipping scan" >> "$LOG_FILE"
fi
```

## Integration with Existing Scripts

Add to your existing hourly check:

```bash
# In ASF-Hourly-Sprint-Check.sh, after agent status checks:

# YARA Security Gate
echo ""
echo "🛡️ Running YARA Security Gate..."
if [ -f "$ASF_ROOT/docs/asf-18-code-review-process/ASF-Hourly-YARA-Check.sh" ]; then
    bash "$ASF_ROOT/docs/asf-18-code-review-process/ASF-Hourly-YARA-Check.sh"
    YARA_RESULT=$?
    if [ $YARA_RESULT -eq 0 ]; then
        echo "✅ YARA gate passed"
    else
        echo "❌ YARA gate FAILED - review threats above"
    fi
fi
```

## Cron Setup

```bash
# Run YARA check every hour
0 * * * * $HOME/agent-security-framework/docs/asf-18-code-review-process/ASF-Hourly-YARA-Check.sh
```

## Benefits

- Continuous monitoring of all skills
- Immediate detection of new threats
- Audit trail in log file
- Slack/Discord alerts
- Integrates with existing Scrum process
