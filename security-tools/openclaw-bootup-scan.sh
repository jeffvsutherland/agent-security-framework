#!/bin/bash
# OpenClaw Bootup Security Scan
# Runs on every container start to generate CIO report

echo "🚀 OpenClaw Bootup Security Scan"
echo "================================"

# Run the CIO report
echo ""
echo "Running executive security scan..."
bash /path/to/security-tools/asf-cio-report.sh

# Output the report location
REPORT_FILE="/var/log/asf/reports/asf-cio-report-$(date +%Y%m%d).md"

echo ""
echo "================================"
echo "📊 CIO Report available at: $REPORT_FILE"
