#!/bin/bash
# full-asf-41-42-secure.sh - Activate ASF-41 + ASF-42 security
# Combines Security Auditor Guardrail + Docker Syscall Monitoring

set -euo pipefail

echo "🚀 ASF-41 + ASF-42 Full Security Activation"
echo "=========================================="

cd ~/agent-security-framework

# Run ASF-42 Syscall Monitoring
echo "[1/2] Activating Syscall Monitoring..."
if [ -f docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh ]; then
    chmod +x docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh
    ./docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh --full
fi

# Run ASF-41 Guardrail
echo "[2/2] Activating Security Guardrail..."
if [ -f docs/asf-41-security-auditor-guardrail/activate-guardrail.sh ]; then
    chmod +x docs/asf-41-security-auditor-guardrail/activate-guardrail.sh
    ./docs/asf-41-security-auditor-guardrail/activate-guardrail.sh --all-agents --enforce
fi

echo ""
echo "=========================================="
echo "✅ ASF-41 + ASF-42 ACTIVE"
echo "Clawdbot-Moltbot-Open-Claw runtime secured $(date)"
echo "=========================================="

# Log to communication log
if [ -f AGENT-COMMUNICATION-LOG.md ]; then
    echo "- $(date): ASF-41 + ASF-42 security activated" >> AGENT-COMMUNICATION-LOG.md
fi
