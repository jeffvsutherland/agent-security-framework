#!/bin/bash
# ASF-40 + ASF-43: Full Activation

echo "🚀 ASF-40 + ASF-43: Full Activation"

cd ~/agent-security-framework

echo "[1/1] Starting Multi-Agent Supervisor..."
./docs/asf-40-multi-agent-supervisor/start-supervisor.sh --full

echo ""
echo "✅ ASF-40 + ASF-43 ACTIVE – Clawdbot-Moltbot-Open-Claw supervised & documented $(date)"

echo "[$(date)] ASF-40 + ASF-43 ACTIVE" >> AGENT-COMMUNICATION-LOG.md 2>/dev/null || true
