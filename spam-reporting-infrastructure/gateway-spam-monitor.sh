#!/bin/bash
# ASF-24 Gateway Spam Monitor - Real-time detection for OpenClaw Gateway
# Monitors Gateway logs for suspicious activity and auto-reports to spam system
# Enhanced with MC scope detection patterns

set -euo pipefail

# Configuration
LOG_FILE="${1:-/var/log/openclaw/gateway.log}"
SPAM_SCRIPT="${ASF_SPAM_SCRIPT:-$HOME/.asf/spam-reporting-infrastructure/report-moltbook-spam-simple.sh}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"
DISCORD_WEBHOOK="${DISCORD_WEBHOOK:-}"
EVIDENCE_DIR="${EVIDENCE_DIR:-$HOME/.asf/evidence}"

# Detection patterns - UPDATED with MC scope detection
PATTERNS=(
    # Malicious activity
    "malicious.*skill"
    "credential.*theft"
    "suspicious.*install"
    "untrusted.*skill"
    "exfiltrat"
    "phishing"
    
    # Security issues
    "unauthorized"
    "permission.*denied"
    "auth.*fail"
    "invalid.*token"
    
    # MC Scope Issues - NEW
    "missing scope"
    "connect.challenge"
    "operator.read"
    "scope.*denied"
    "handshake.*fail"
    "device.*not.*authorized"
)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ASF-Gateway-Monitor: $1"
}

send_webhook() {
    local message="$1"
    local severity="${2:-info}"
    
    # Slack
    if [ -n "$SLACK_WEBHOOK" ]; then
        curl -s -X POST "$SLACK_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"text\":\"$message\",\"icon_emoji\":\":warning:\"}" 2>/dev/null || true
    fi
    
    # Discord
    if [ -n "$DISCORD_WEBHOOK" ]; then
        curl -s -X POST "$DISCORD_WEBHOOK" \
            -H 'Content-Type: application/json' \
            -d "{\"content\":\"$message\"}" 2>/dev/null || true
    fi
}

auto_report() {
    local actor="$1"
    local type="$2"
    local source="$3"
    local details="$4"
    
    log "🚨 AUTO-REPORTING: $actor - $type"
    
    if [ -x "$SPAM_SCRIPT" ]; then
        $SPAM_SCRIPT report "$actor" "$type" "$source" "$details" 2>/dev/null || log "Failed to run spam script"
    fi
    
    # Send webhook
    send_webhook "🚨 ASF Alert: $type detected - $actor - $details" "warning"
}

# Ensure evidence directory exists
mkdir -p "$EVIDENCE_DIR"

log "Starting ASF Gateway Spam Monitor..."
log "Monitoring: $LOG_FILE"
log "Spam script: $SPAM_SCRIPT"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    log "WARNING: Log file not found: $LOG_FILE"
    log "Attempting to find Gateway logs..."
    
    # Try common locations
    for alt_log in /var/log/openclaw.log /var/log/openclaw/gateway.log $HOME/.openclaw/logs/gateway.log; do
        if [ -f "$alt_log" ]; then
            LOG_FILE="$alt_log"
            log "Found log at: $LOG_FILE"
            break
        fi
    done
fi

# Build grep pattern
PATTERN=$(printf "%s|" "${PATTERNS[@]}")
PATTERN="${PATTERN%|}"  # Remove trailing |

log "Monitoring for patterns: $PATTERN"

# Monitor log file
tail -n 0 -F "$LOG_FILE" 2>/dev/null | while read -r line; do
    for pattern in "${PATTERNS[@]}"; do
        if echo "$line" | grep -iqE "$pattern"; then
            TIMESTAMP=$(date +%Y%m%d%H%M%S)
            
            # Extract relevant info
            ACTOR=$(echo "$line" | grep -oE '[a-zA-Z0-9_-]+@[a-zA-Z0-9_-]+' | head -1 || echo "unknown")
            TYPE="spam"
            
            # Determine type based on pattern
            if echo "$pattern" | grep -iqE "missing scope|connect.challenge|operator.read|scope.*denied|handshake"; then
                TYPE="scope-issue"
            elif echo "$pattern" | grep -iqE "credential|token|auth"; then
                TYPE="security"
            fi
            
            log "DETECTED: $pattern - $line"
            
            # Auto-report
            auto_report "$ACTOR" "$TYPE" "gateway" "Detected via log: $pattern"
            
            # Save to evidence
            EVIDENCE_FILE="$EVIDENCE_DIR/gateway-$TIMESTAMP.json"
            echo "{\"timestamp\":\"$(date -Iseconds)\",\"pattern\":\"$pattern\",\"line\":\"$line\"}" > "$EVIDENCE_FILE"
            log "Evidence saved: $EVIDENCE_FILE"
            
            break  # Only report once per line
        fi
    done
done
