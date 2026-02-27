#!/bin/bash
# Morning Report Generator for Raven (ASF Product Owner)
# Runs morning-report-template.py inside OpenClaw container and saves output
# Can be triggered manually or via cron
#
# Usage:
#   ./generate-morning-report.sh              # Generate and display
#   ./generate-morning-report.sh --save       # Generate and save to file
#   ./generate-morning-report.sh --telegram   # Generate and send via Telegram
#
# Dependencies:
#   - Docker Desktop running
#   - openclaw-gateway container running
#   - /workspace/morning-report-template.py (inside container)
#   - /workspace/.mc-api-backup (inside container)

set -e

CONTAINER="openclaw-gateway"
REPORT_DIR="/Users/jeffsutherland/clawd/morning-reports"
DATE=$(date +%Y%m%d)
TIME=$(date +%H%M)

# Check container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "❌ ERROR: ${CONTAINER} is not running"
    echo "Fix: cd ~/clawd/ASF-15-docker && docker compose up -d openclaw"
    exit 1
fi

# Test mc-api connectivity
MC_HEALTH=$(docker exec ${CONTAINER} /workspace/.mc-api-backup health 2>&1)
if echo "$MC_HEALTH" | grep -q '"ok":true'; then
    echo "✅ Mission Control: Connected"
else
    echo "⚠️  Mission Control: Not reachable (report will have limited data)"
fi

# Generate the morning report
echo "📋 Generating Morning Report..."
REPORT=$(docker exec ${CONTAINER} python3 /workspace/morning-report-template.py 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Morning report generation failed"
    echo "$REPORT"
    exit 1
fi

# Display report
echo ""
echo "$REPORT"

# Save report to file (always save by default)
mkdir -p "$REPORT_DIR"
REPORT_FILE="${REPORT_DIR}/${DATE}-MORNING-REPORT.md"
echo "$REPORT" > "$REPORT_FILE"
echo ""
echo "💾 Saved to: $REPORT_FILE"

# Send via Telegram if requested
if [ "$1" = "--telegram" ]; then
    # Use clawdbot to send the message
    if command -v clawdbot &> /dev/null; then
        echo "📬 Sending via Telegram..."
        clawdbot message send --channel telegram --target 1510884737 --message "$REPORT" 2>&1 || echo "⚠️  Telegram send failed (gateway may not be running)"
    else
        echo "⚠️  clawdbot not installed, cannot send via Telegram"
    fi
fi

echo ""
echo "✅ Morning Report Complete ($(date '+%Y-%m-%d %H:%M:%S ET'))"

