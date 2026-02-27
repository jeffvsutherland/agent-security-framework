#!/bin/bash
# Morning Report Generator - Runs INSIDE Docker container (for Raven)
# This is the in-container version. For host-side, use generate-morning-report.sh
#
# Usage (inside container):
#   /workspace/generate-morning-report-docker.sh
#   /workspace/generate-morning-report-docker.sh --telegram
#
# Usage (from host via docker exec):
#   docker exec openclaw-gateway /workspace/generate-morning-report-docker.sh

set -e

REPORT_DIR="/workspace/morning-reports"
DATE=$(date +%Y%m%d)

# Test mc-api connectivity
MC_HEALTH=$(/workspace/.mc-api-backup health 2>&1 || true)
if echo "$MC_HEALTH" | grep -q '"ok":true'; then
    echo "✅ Mission Control: Connected"
else
    echo "⚠️  Mission Control: Not reachable (report will have limited data)"
fi

# Generate the morning report
echo "📋 Generating Morning Report..."
REPORT=$(python3 /workspace/morning-report-template.py 2>&1)

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Morning report generation failed"
    echo "$REPORT"
    exit 1
fi

# Display report
echo ""
echo "$REPORT"

# Always save to file
mkdir -p "$REPORT_DIR"
REPORT_FILE="${REPORT_DIR}/${DATE}-MORNING-REPORT.md"
echo "$REPORT" > "$REPORT_FILE"
echo ""
echo "💾 Saved to: $REPORT_FILE"

echo ""
echo "✅ Morning Report Complete ($(date '+%Y-%m-%d %H:%M:%S ET'))"

