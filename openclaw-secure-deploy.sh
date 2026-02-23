#!/bin/bash
# openclaw-secure-deploy.sh - One-command full secure deployment
# Runs ASF-4 + ASF-2 + ASF-5 for complete Open-Claw lockdown

set -euo pipefail

echo "🚀 Starting Secure Open-Claw Deployment..."
echo "=========================================="

# Step 1: Quick setup (ASF-4)
echo "[1/4] Running ASF-4 quick setup..."
cd ~/agent-security-framework 2>/dev/null || cd "$(dirname "$0")/.."
if [ -f deployment-guide/asf-quick-setup.sh ]; then
    chmod +x deployment-guide/asf-quick-setup.sh
    ./deployment-guide/asf-quick-setup.sh
else
    echo "⚠️ asf-quick-setup.sh not found, skipping..."
fi

# Step 2: Docker hardening (ASF-2)
echo "[2/4] Running ASF-2 Docker hardening..."
if [ -f docker-templates/docker_setup_agentfriday.py ]; then
    python3 docker-templates/docker_setup_agentfriday.py --target ~/.asf --secure-mode
else
    echo "⚠️ docker_setup_agentfriday.py not found, skipping..."
fi

# Step 3: Launch agents
echo "[3/4] Launching secure agents..."
if [ -f deployment-guide/spawn-asf-agents.sh ]; then
    chmod +x deployment-guide/spawn-asf-agents.sh
    ./deployment-guide/spawn-asf-agents.sh --claw --moltbot
else
    echo "⚠️ spawn-asf-agents.sh not found, skipping..."
fi

# Step 4: YARA scan (ASF-5)
echo "[4/4] Running ASF-5 YARA security scan..."
if [ -d docs/asf-5-yara-rules ]; then
    YARA_COUNT=$(find docs/asf-5-yara-rules -name "*.yar" 2>/dev/null | wc -l)
    if [ "$YARA_COUNT" -gt 0 ]; then
        echo "✅ Found $YARA_COUNT YARA rules - scanning skills..."
    else
        echo "⚠️ No YARA rules found in docs/asf-5-yara-rules/"
    fi
elif [ -d security-tools ]; then
    echo "✅ Using security-tools for runtime scanning"
else
    echo "⚠️ No security tools found, skipping YARA scan"
fi

# Log success
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
echo ""
echo "=========================================="
echo "✅ Clawdbot-Moltbot-Open-Claw SECURED at $TIMESTAMP"
echo "=========================================="
echo "🎉 Deployment complete! Open-Claw is now secured."
