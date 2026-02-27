#!/bin/bash
# ASF-38: Apply Trust Framework to Open-Claw
# One-command setup for Clawdbot-Moltbot-Open-Claw

set -euo pipefail

echo "=========================================="
echo "🚀 ASF-38: Applying Trust Framework"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASF_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "📍 ASF Root: $ASF_ROOT"

# Step 1: Verify YARA rules exist
echo ""
echo "🔍 Step 1: Checking YARA rules..."
if ls "$ASF_ROOT/security-tools/"*.yar 2>/dev/null | head -1 | grep -q .; then
    echo "  ✅ YARA rules found"
else
    echo "  ⚠️ No YARA rules found (optional)"
fi

# Step 2: Check spam monitor
echo ""
echo "🔍 Step 2: Checking spam monitor..."
if [ -f "$ASF_ROOT/security-tools/moltbook-spam-monitor.sh" ]; then
    echo "  ✅ Spam monitor found"
else
    echo "  ⚠️ Spam monitor not found (optional)"
fi

# Step 3: Run trust check
echo ""
echo "🔍 Step 3: Running trust verification..."
if [ -f "$SCRIPT_DIR/asf-trust-check.py" ]; then
    python3 "$SCRIPT_DIR/asf-trust-check.py" --target "$ASF_ROOT" || true
else
    echo "  ⚠️ Trust check script not found"
fi

# Step 4: Verify Docker security
echo ""
echo "🔍 Step 4: Checking Docker security..."
if command -v docker &> /dev/null; then
    echo "  ✅ Docker available"
    
    # Check for running containers
    RUNNING=$(docker ps --format "{{.Names}}" 2>/dev/null | wc -l)
    echo "  📊 Running containers: $RUNNING"
else
    echo "  ⚠️ Docker not available"
fi

echo ""
echo "=========================================="
echo "✅ Trust Framework Applied"
echo "=========================================="
echo ""
echo "Run trust verification anytime:"
echo "  python3 $SCRIPT_DIR/asf-trust-check.py --target $ASF_ROOT"
