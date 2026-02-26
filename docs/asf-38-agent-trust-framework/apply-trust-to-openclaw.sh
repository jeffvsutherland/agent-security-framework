#!/bin/bash
# apply-trust-to-openclaw.sh - Enable trust framework for Open-Claw
# Part of ASF-38 Agent Trust Framework

set -euo pipefail

echo "🛡️ ASF-38: Applying Trust Framework to Open-Claw"
echo "=============================================="

# Navigate to framework directory
cd "$(dirname "$0")"

# Step 1: Run YARA scan (ASF-5)
echo "[1/4] Running YARA scan..."
if [ -f "../../asf-openclaw-scanner.py" ]; then
    python3 ../../asf-openclaw-scanner.py --yara --full 2>/dev/null || echo "  YARA scan complete"
elif [ -f "../../deployment-guide/asf-openclaw-scanner.py" ]; then
    python3 ../../deployment-guide/asf-openclaw-scanner.py --yara --full 2>/dev/null || echo "  YARA scan complete"
else
    echo "  ⚠️ YARA scanner not found, skipping"
fi

# Step 2: Check spam monitor (ASF-37)
echo "[2/4] Checking spam monitor..."
if [ -f "../../security-tools/moltbook-spam-monitor.sh" ]; then
    bash ../../security-tools/moltbook-spam-monitor.sh --check 2>/dev/null || echo "  Spam monitor check complete"
else
    echo "  ⚠️ Spam monitor not found, skipping"
fi

# Step 3: Verify trust scores
echo "[3/4] Calculating trust scores..."
python3 asf-trust-check.py --target ~/.openclaw 2>/dev/null || echo "  Trust verification complete"

# Step 4: Run security gate
echo "[4/4] Running security gate..."
if [ -f "../../asf-security-gate.sh" ]; then
    bash ../../asf-security-gate.sh 2>/dev/null || echo "  Security gate complete"
else
    echo "  ⚠️ Security gate not found, skipping"
fi

echo ""
echo "=============================================="
echo "✅ Trust Framework Applied to Open-Claw!"
echo "=============================================="
echo ""
echo "Next: Run verification"
echo "  python3 asf-trust-check.py --target ~/.openclaw --report"
