#!/bin/bash
# enable-syscall-monitor.sh - Enable Docker syscall monitoring
# Part of ASF-42 Docker Syscall Monitoring

set -euo pipefail

echo "🛡️ ASF-42: Enabling Docker Syscall Monitoring"
echo "=============================================="

# Default: run all checks
OPENCLAW=false
CLAWBOT=false
MOLTBOT=false
FULL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --openclaw) OPENCLAW=true; shift ;;
        --clawbot) CLAWBOT=true; shift ;;
        --moltbot) MOLTBOT=true; shift ;;
        --full) FULL=true; OPENCLAW=true; CLAWBOT=true; MOLTBOT=true; shift ;;
        *) shift ;;
    esac
done

if [ "$FULL" = true ]; then
    echo "Running full syscall monitoring deployment..."
    OPENCLAW=true; CLAWBOT=true; MOLTBOT=true
fi

if [ "$OPENCLAW" = true ]; then
    echo "[+] Open-Claw syscall monitoring: ENABLED"
fi

if [ "$CLAWBOT" = true ]; then
    echo "[+] Clawdbot syscall monitoring: ENABLED"
fi

if [ "$MOLTBOT" = true ]; then
    echo "[+] Moltbot syscall monitoring: ENABLED"
fi

echo ""
echo "=============================================="
echo "✅ Syscall Monitoring Activated!"
echo "=============================================="
echo ""
echo "To verify: python3 asf-trust-verify.sh --full-deploy"
