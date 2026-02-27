#!/bin/bash
# ASF-41 + ASF-42: Full Security Activation for Clawdbot-Moltbot-Open-Claw

set -euo pipefail

echo "=========================================="
echo "🚀 ASF-41 + ASF-42 Full Activation"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ASF-41: Activate Guardrail
echo "📦 Step 1: Activating ASF-41 Guardrail..."
bash "$SCRIPT_DIR/docs/asf-41-security-auditor-guardrail/activate-guardrail.sh" --all-agents
echo ""

# ASF-42: Activate Syscall Monitor
echo "📦 Step 2: Activating ASF-42 Syscall Monitor..."
bash "$SCRIPT_DIR/docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh" --full
echo ""

echo "=========================================="
echo "✅ ASF-41 + ASF-42 ACTIVE"
echo "=========================================="
echo ""
echo "Clawdbot-Moltbot-Open-Claw runtime secured"
echo "Date: $(date)"

# Log to communication
echo "[$(date)] ASF-41 + ASF-42 ACTIVE - Clawdbot-Moltbot-Open-Claw runtime secured" >> AGENT-COMMUNICATION-LOG.md
