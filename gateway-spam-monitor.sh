#!/bin/bash
# ASF Gateway Spam Monitor - Auto-report suspicious activity from Gateway logs
# Integrates with Mission Control and spam reporting system
# Usage: Run as sidecar or cron job alongside openclaw-gateway

set -euo pipefail

# Configuration
LOG_FILE="${LOG_FILE:-/var/log/openclaw.log}"
SPAM_REPORT="${SPAM_REPORT:-$HOME/.asf/tools/report-moltbook-spam-simple.sh}"
WEBHOOK_URL="${WEBHOOK_URL:-}"
POLL_INTERVAL="${POLL_INTERVAL:-10}"
AUTO_REPORT="${AUTO_REPORT:-true}"

# Suspicious patterns to detect
SUSPICIOUS_PATTERNS=(
    "skill install.*malicious"
    "skill install.*phishing" 
    "skill install.*suspicious"
    "untrusted skill"
    "blocked.*skill"
    "exfiltrat"
    "credential.*theft"
    "key.*exfil"
    "api.*token.*access"
)

# Initialize
init() {
    mkdir -p "$HOME/.asf/logs"
    echo "[$(date)] Gateway spam monitor started" >> "$HOME/.asf/logs/gateway-monitor.log"
    
    if [[ ! -x "$SPAM_REPORT" ]]; then
        echo "Error: Spam reporter not found at $SPAM_REPORT"
        exit 1
    fi
}

# Report suspicious activity
report_suspicious() {
    local pattern="$1"
    local timestamp="$2"
    local details="$3"
    
    local report_id=$($SPAM_REPORT report "gateway-auto-$RANDOM" spam "gateway_monitor" "Auto-detected: $pattern. Details: $details" 2>/dev/null || echo "REPORT_FAILED")
    
    echo "[$(date)] AUTO-REPORT: $pattern -> $report_id" >> "$HOME/.asf/logs/gateway-monitor.log"
    
    # Send webhook notification
    if [[ -n "$WEBHOOK_URL" ]]; then
        curl -s -X POST "$WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{\"text\": \"🚨 Gateway Alert: $pattern detected\nReport: $report_id\nDetails: $details\"}" \
            >/dev/null 2>&1 || true
    fi
    
    echo "✅ Auto-reported: $pattern"
}

# Monitor logs
monitor() {
    local last_pos=0
    local log_file="$HOME/.asf/logs/gateway-monitor Position"
    
    # Get last position if exists
    if [[ -f "$log_file" ]]; then
        last_pos=$(cat "$log_file")
    fi
    
    echo "[$(date)] Starting log monitoring from position $last_pos"
    
    while true; do
        if [[ -f "$LOG_FILE" ]]; then
            local file_size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
            
            # Log rotated or shrunk - reset
            if [[ $file_size -lt $last_pos ]]; then
                last_pos=0
            fi
            
            # Read new lines
            if [[ $file_size -gt $last_pos ]]; then
                local new_lines=$(tail -c +$((last_pos + 1)) "$LOG_FILE" 2>/dev/null | head -c $((file_size - last_pos)))
                
                for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
                    if echo "$new_lines" | grep -qi "$pattern"; then
                        local matching_line=$(echo "$new_lines" | grep -i "$pattern" | tail -1)
                        report_suspicious "$pattern" "$(date)" "$matching_line"
                    fi
                done
                
                last_pos=$file_size
                echo "$last_pos" > "$log_file"
            fi
        fi
        
        sleep "$POLL_INTERVAL"
    done
}

# One-time scan (for cron)
scan_once() {
    echo "Running one-time scan of $LOG_FILE..."
    
    if [[ ! -f "$LOG_FILE" ]]; then
        echo "Log file not found: $LOG_FILE"
        exit 1
    fi
    
    for pattern in "${SUSPICIOUS_PATTERNS[@]}"; do
        local matches=$(grep -i "$pattern" "$LOG_FILE" 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            echo "Found: $pattern"
            echo "$matches" | while read line; do
                report_suspicious "$pattern" "$(date)" "$line"
            done
        fi
    done
}

# Show usage
usage() {
    cat <<EOF
ASF Gateway Spam Monitor

Usage: $0 <command>

Commands:
    init        Initialize monitoring directory
    monitor     Start continuous log monitoring
    scan        Run one-time scan of logs
    test        Test pattern detection with sample log

Environment Variables:
    LOG_FILE         Path to openclaw gateway log (default: /var/log/openclaw.log)
    SPAM_REPORT      Path to spam reporter script
    WEBHOOK_URL      Slack/Discord webhook for alerts
    POLL_INTERVAL    Seconds between log checks (default: 10)
    AUTO_REPORT     Auto-report detections (default: true)

Examples:
    # Start continuous monitoring
    AUTO_REPORT=true LOG_FILE=/var/log/openclaw.log $0 monitor
    
    # Run one-time scan from cron
    0 3 * * * /path/to/gateway-spam-monitor.sh scan
    
    # With Slack webhook
    WEBHOOK_URL=https://hooks.slack.com/xxx $0 monitor
EOF
}

# Main
case "${1:-usage}" in
    init) init ;;
    monitor) monitor ;;
    scan) scan_once ;;
    test) 
        echo "test" | grep -qi "skill install.*malicious" && echo "Pattern detection works" 
        ;;
    *) usage ;;
esac
