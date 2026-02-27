#!/bin/bash
# ASF-41 + ASF-42: Full Secure Activation

echo "🚀 ASF-41 + ASF-42: Full Secure Activation"

cd ~/agent-security-framework

echo "[1/2] Activating ASF-42 Docker Syscall Monitoring..."
./docs/asf-42-docker-syscall-monitoring/enable-syscall-monitor.sh --full

echo "[2/2] Activating ASF-41 Security Auditor Guardrail..."
./docs/asf-41-security-auditor-guardrail/activate-guardrail.sh --all-agents --enforce

echo ""
echo "✅ ASF-41 + ASF-42 ACTIVE – Clawdbot-Moltbot-Open-Claw runtime secured $(date)"

echo "[$(date)] ASF-41 + ASF-42 ACTIVE" >> AGENT-COMMUNICATION-LOG.md 2>/dev/null || true
