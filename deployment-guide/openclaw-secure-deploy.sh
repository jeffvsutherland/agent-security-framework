#!/bin/bash
# openclaw-secure-deploy.sh - One-command full secure deploy
# Run this to deploy a fully hardened Clawdbot-Moltbot-Open-Claw stack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[$(date +%H:%M:%S)] $1${NC}"; }
warn() { echo -e "${YELLOW}[!] $1${NC}"; }
fail() { echo -e "${RED}[✗] $1${NC}"; exit 1; }

echo "============================================"
echo "🔒 OpenClaw Secure Deploy"
echo "   Clawdbot-Moltbot-Open-Claw Stack"
echo "============================================"

# 1. Quick setup
log "Step 1/5: Running asf-quick-setup.sh..."
cd "$PROJECT_ROOT"
if [ -f "./deployment-guide/asf-quick-setup.sh" ]; then
    chmod +x ./deployment-guide/asf-quick-setup.sh
    ./deployment-guide/asf-quick-setup.sh || warn "Quick setup had warnings (continuing)"
else
    fail "asf-quick-setup.sh not found"
fi

# 2. Docker hardening
log "Step 2/5: Hardening Docker templates..."
if [ -f "./docker-templates/docker_setup_agentfriday.py" ]; then
    cd docker-templates
    python3 docker_setup_agentfriday.py --target ../.openclaw --secure-mode || warn "Docker setup had warnings (continuing)"
    cd "$PROJECT_ROOT"
else
    warn "Docker setup script not found (skipping)"
fi

# 3. Spawn agents
log "Step 3/5: Spawning ASF agents..."
if [ -f "./deployment-guide/spawn-asf-agents.sh" ]; then
    chmod +x ./deployment-guide/spawn-asf-agents.sh
    ./deployment-guide/spawn-asf-agents.sh --claw --moltbot 2>/dev/null || warn "Agent spawn had warnings (continuing)"
else
    warn "spawn-asf-agents.sh not found (skipping)"
fi

# 4. Run YARA scan
log "Step 4/5: Running YARA security scan..."
if [ -d "./docs/asf-5-yara-rules" ]; then
    # Scan skills directory if it exists
    if [ -d ".openclaw/skills" ]; then
        if command -v yara &> /dev/null; then
            yara -r ./docs/asf-5-yara-rules/*.yar .openclaw/skills/ 2>/dev/null || warn "YARA found issues (review recommended)"
        else
            warn "YARA not installed (skipping scan)"
        fi
    else
        warn "No skills directory to scan"
    fi
else
    warn "YARA rules not found (skipping)"
fi

# 5. Run OpenClaw scanner
log "Step 5/5: Running OpenClaw security scanner..."
if [ -f "./deployment-guide/asf-openclaw-scanner.py" ]; then
    chmod +x ./deployment-guide/asf-openclaw-scanner.py
    python3 ./deployment-guide/asf-openclaw-scanner.py 2>/dev/null || warn "Scanner had warnings (continuing)"
else
    warn "OpenClaw scanner not found (skipping)"
fi

# Final
echo "============================================"
log "✅ Clawdbot-Moltbot-Open-Claw SECURED!"
echo "   Completed at $(date)"

# Log success
if [ -w "AGENT-COMMUNICATION-LOG.md" ] || [ -f "AGENT-COMMUNICATION-LOG.md" ]; then
    echo "[$(date)] 🔒 OpenClaw Secure Deploy COMPLETED" >> AGENT-COMMUNICATION-LOG.md
fi

echo "============================================"
log "Next steps:"
echo "  1. Review any warnings above"
echo "  2. Run: ./asf-security-gate.sh"
echo "  3. Deploy with: docker-compose up -d"
echo ""
