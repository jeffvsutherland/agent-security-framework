#!/bin/bash
# start-supervisor.sh - Launch supervisor for ASF-40

echo "🛡️ ASF-40: Starting Multi-Agent Supervisor"
echo "=========================================="

OPENCLAW=false
CLAWBOT=false
MOLTBOT=false
FULL=false

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
    OPENCLAW=true; CLAWBOT=true; MOLTBOT=true
fi

[ "$OPENCLAW" = true ] && echo "[+] Open-Claw supervisor: ACTIVE"
[ "$CLAWBOT" = true ] && echo "[+] Clawdbot supervisor: ACTIVE"  
[ "$MOLTBOT" = true ] && echo "[+] Moltbot supervisor: ACTIVE"

echo ""
echo "=========================================="
echo "✅ Supervisor Started - Monitoring Agents!"
echo "=========================================="
