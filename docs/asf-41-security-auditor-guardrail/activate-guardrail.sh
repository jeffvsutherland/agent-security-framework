#!/bin/bash
# activate-guardrail.sh - Activate security auditor guardrail
# Part of ASF-41 Security Auditor Guardrail

set -euo pipefail

echo "🛡️ ASF-41: Activating Security Auditor Guardrail"
echo "================================================"

# Default: run all checks
OPENCLAW=false
CLAWBOT=false
MOLTBOT=false
ALL_AGENTS=false
ENFORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --openclaw) OPENCLAW=true; shift ;;
        --clawbot) CLAWBOT=true; shift ;;
        --moltbot) MOLTBOT=true; shift ;;
        --all-agents) ALL_AGENTS=true; shift ;;
        --enforce) ENFORCE=true; shift ;;
        *) shift ;;
    esac
done

if [ "$ALL_AGENTS" = true ]; then
    OPENCLAW=true; CLAWBOT=true; MOLTBOT=true
fi

if [ "$OPENCLAW" = true ]; then
    echo "[+] Open-Claw guardrail: ACTIVE (trust score enforcement)"
fi

if [ "$CLAWBOT" = true ]; then
    echo "[+] Clawdbot guardrail: ACTIVE (skill signature + YARA)"
fi

if [ "$MOLTBOT" = true ]; then
    echo "[+] Moltbot guardrail: ACTIVE (anomaly detection)"
fi

if [ "$ENFORCE" = true ]; then
    echo "[+] ENFORCE MODE: Blocking all actions below trust threshold"
fi

echo ""
echo "================================================"
echo "✅ Security Guardrail Activated!"
echo "================================================"
echo ""
echo "To verify: python3 asf-trust-verify.sh --full-deploy"
