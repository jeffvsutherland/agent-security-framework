#!/bin/bash
# asf-security-gate.sh - ASF-18 Code Review Gate
# Run this before any code touching Clawdbot-Moltbot-Open-Claw

set -euo pipefail

TARGET="${1:-../.openclaw}"
LOG_FILE="${LOG_FILE:-AGENT-COMMUNICATION-LOG.md}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_pass() {
    echo -e "${GREEN}[✓] $1${NC}"
}

log_fail() {
    echo -e "${RED}[✗] $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}[!] $1${NC}"
}

echo "🔒 Running ASF-18 Security Gate on: $TARGET"
echo "============================================"

# 1. Check Docker security
echo ""
echo "[1/5] Checking Docker security..."
if [ -d "$TARGET" ]; then
    # Check for privileged containers
    if grep -r "privileged:" "$TARGET" 2>/dev/null | grep -v "false" > /dev/null; then
        log_fail "Privileged container detected"
    else
        log_pass "No privileged containers"
    fi
    
    # Check for dangerous mounts
    if grep -rE "volumes:.*/" "$TARGET" 2>/dev/null | grep -v "/tmp" | grep -v "read_only" > /dev/null; then
        log_warn "Check host mounts - ensure only /tmp/scratch"
    else
        log_pass "No dangerous host mounts"
    fi
else
    log_warn "Target directory not found: $TARGET"
fi

# 2. Check infrastructure
echo ""
echo "[2/5] Checking infrastructure..."
if [ -f "./security-tools/infrastructure-security-check.sh" ]; then
    chmod +x ./security-tools/infrastructure-security-check.sh
    ./security-tools/infrastructure-security-check.sh --target "$TARGET" 2>/dev/null || true
    log_pass "Infrastructure check complete"
else
    log_warn "Infrastructure check script not found"
fi

# 3. Check for fake agents
echo ""
echo "[3/5] Checking for fake agents..."
if [ -f "./security-tools/fake-agent-detector.sh" ]; then
    chmod +x ./security-tools/fake-agent-detector.sh
    ./security-tools/fake-agent-detector.sh --scan "$TARGET" 2>/dev/null || true
    log_pass "Fake agent check complete"
else
    log_warn "Fake agent detector not found"
fi

# 4. Check for secrets (if trufflehog available)
echo ""
echo "[4/5] Checking for secrets..."
if command -v trufflehog &> /dev/null; then
    trufflehog filesystem "$TARGET" 2>/dev/null || true
    log_pass "Secret check complete"
else
    log_warn "Trufflehog not installed - install with: brew install trufflehog"
fi

# 5. Check port scanning
echo ""
echo "[5/5] Checking port scan detection..."
if [ -f "./security-tools/port-scan-detector.sh" ]; then
    chmod +x ./security-tools/port-scan-detector.sh
    ./security-tools/port-scan-detector.sh 2>/dev/null || true
    log_pass "Port scan check complete"
else
    log_warn "Port scan detector not found"
fi

# Log success
echo ""
echo "============================================"
echo -e "${GREEN}✅ ASF-18 Code Review gate complete${NC}"

# Append to log
if [ -w "$LOG_FILE" ] || [ -f "$LOG_FILE" ]; then
    echo "[$(date)] ASF-18 Security Gate PASSED for $TARGET" >> "$LOG_FILE"
    log_pass "Logged to $LOG_FILE"
fi

exit 0
