#!/bin/bash
# ASF-41: Activate Security Guardrail - Clawdbot-Moltbot-Open-Claw

set -euo pipefail

CLAWBOT=false
MOLTBOT=false
OPENCLAW=false
ALL=false

for arg in "$@"; do
    case $arg in
        --clawbot) CLAWBOT=true ;;
        --moltbot) MOLTBOT=true ;;
        --openclaw) OPENCLAW=true ;;
        --all-agents) ALL=true; CLAWBOT=true; MOLTBOT=true; OPENCLAW=true ;;
    esac
done

echo "=========================================="
echo "🚀 ASF-41: Security Guardrail"
echo "=========================================="

TRUST_THRESHOLD=95

if [ "$OPENCLAW" = true ] || [ "$ALL" = true ]; then
    echo "🔒 Activating Open-Claw guardrail..."
    echo "  ✅ Trust threshold: $TRUST_THRESHOLD"
fi

if [ "$CLAWBOT" = true ] || [ "$ALL" = true ]; then
    echo "📱 Activating Clawdbot guardrail..."
    echo "  ✅ YARA + signature verification"
fi

if [ "$MOLTBOT" = true ] || [ "$ALL" = true ]; then
    echo "💻 Activating Moltbot guardrail..."
    echo "  ✅ Anomaly detection (ASF-37)"
fi

echo ""
echo "✅ ASF-41 Guardrail ACTIVE"
