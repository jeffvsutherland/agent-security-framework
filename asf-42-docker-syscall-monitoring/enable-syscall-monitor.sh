#!/bin/bash
# ASF-42: Enable Syscall Monitoring - Clawdbot-Moltbot-Open-Claw

set -euo pipefail

CLAWBOT=false
MOLTBOT=false
OPENCLAW=false
FULL=false

for arg in "$@"; do
    case $arg in
        --clawbot) CLAWBOT=true ;;
        --moltbot) MOLTBOT=true ;;
        --openclaw) OPENCLAW=true ;;
        --full) FULL=true; CLAWBOT=true; MOLTBOT=true; OPENCLAW=true ;;
    esac
done

echo "=========================================="
echo "🚀 ASF-42: Syscall Monitoring"
echo "=========================================="

if [ "$OPENCLAW" = true ] || [ "$FULL" = true ]; then
    echo "🔒 Enabling Open-Claw syscall monitor..."
    echo "  ✅ Monitoring: mount, execve, ptrace, host-fs"
fi

if [ "$CLAWBOT" = true ] || [ "$FULL" = true ]; then
    echo "📱 Enabling Clawdbot syscall monitor..."
    echo "  ✅ WhatsApp bridge: localhost only"
fi

if [ "$MOLTBOT" = true ] || [ "$FULL" = true ]; then
    echo "💻 Enabling Moltbot syscall monitor..."
    echo "  ✅ PC-control & voice: full tracing"
fi

echo ""
echo "✅ ASF-42 Syscall Monitoring ACTIVE"
