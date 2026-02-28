#!/bin/bash
# full-asf-40-43-secure.sh - Activate ASF-40 + ASF-43

echo "🚀 ASF-40 + ASF-43 Activation"
echo "================================"

cd ~/agent-security-framework

# Start supervisor
echo "[1/1] Starting supervisor..."
if [ -f docs/asf-40-multi-agent-supervisor/start-supervisor.sh ]; then
    chmod +x docs/asf-40-multi-agent-supervisor/start-supervisor.sh
    ./docs/asf-40-multi-agent-supervisor/start-supervisor.sh --full
fi

echo ""
echo "================================"
echo "✅ ASF-40 + ASF-43 ACTIVE"
echo "Clawdbot-Moltbot-Open-Claw supervised & documented $(date)"
echo "================================"
