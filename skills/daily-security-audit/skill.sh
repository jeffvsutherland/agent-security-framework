#!/bin/bash
#===============================================================================
# Daily Security Audit — Executable wrapper for the daily-security-audit skill
# Called by clawdbot cron at 00:05 nightly (6 min after sprint rollover)
#
# This script can run standalone on the host or inside Docker via:
#   docker exec openclaw-gateway /workspace/skills/daily-security-audit/skill.sh
#===============================================================================

set -euo pipefail

WORKSPACE="${WORKSPACE:-/Users/jeffsutherland/clawd}"
REPORT_DIR="${WORKSPACE}/reports"
SECURITY_LOG="${REPORT_DIR}/DAILY_SECURITY_LOG.md"
PENDING_TASKS="${REPORT_DIR}/PENDING_SECURITY_TASKS.md"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S ET')

mkdir -p "$REPORT_DIR"

echo "🔒 Daily Security Audit — $TIMESTAMP"

# Determine scan target
SCAN_DIR="${WORKSPACE}/src"
if [ ! -d "$SCAN_DIR" ]; then
    SCAN_DIR="${WORKSPACE}/agent-security-framework"
    if [ ! -d "$SCAN_DIR" ]; then
        SCAN_DIR="$WORKSPACE"
    fi
fi
echo "  📂 Scan target: $SCAN_DIR"

# --- Step 1: Run Static Analysis ---
SCANNER="none"
TOTAL_FILES=0
CRITICAL=0
HIGH=0
MEDIUM=0
LOW=0
TOTAL_ISSUES=0
FINDINGS=""

TOTAL_FILES=$(find "$SCAN_DIR" -type f \( -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.ts" \) 2>/dev/null | wc -l | tr -d ' ')

# Try semgrep first
if command -v semgrep &>/dev/null; then
    SCANNER="semgrep"
    echo "  🔍 Running semgrep..."
    semgrep scan --config auto "$SCAN_DIR" > "${REPORT_DIR}/semgrep_out.txt" 2>&1 || true
    CRITICAL=$(grep -ci "CRITICAL" "${REPORT_DIR}/semgrep_out.txt" 2>/dev/null || echo 0)
    HIGH=$(grep -ci "HIGH" "${REPORT_DIR}/semgrep_out.txt" 2>/dev/null || echo 0)
    FINDINGS=$(cat "${REPORT_DIR}/semgrep_out.txt" 2>/dev/null)

# Try bandit for Python
elif command -v bandit &>/dev/null; then
    SCANNER="bandit"
    echo "  🔍 Running bandit..."
    bandit -r "$SCAN_DIR" -f json > "${REPORT_DIR}/bandit_out.json" 2>&1 || true
    CRITICAL=$(python3 -c "import json; d=json.load(open('${REPORT_DIR}/bandit_out.json')); print(sum(1 for r in d.get('results',[]) if r.get('issue_severity')=='HIGH' and r.get('issue_confidence')=='HIGH'))" 2>/dev/null || echo 0)
    HIGH=$(python3 -c "import json; d=json.load(open('${REPORT_DIR}/bandit_out.json')); print(sum(1 for r in d.get('results',[]) if r.get('issue_severity')=='HIGH'))" 2>/dev/null || echo 0)
    FINDINGS=$(cat "${REPORT_DIR}/bandit_out.json" 2>/dev/null)

# Grep-based fallback (always available)
else
    SCANNER="grep-fallback"
    echo "  🔍 Running grep-based security scan..."
    {
        grep -rn "eval(" --include="*.py" --include="*.js" "$SCAN_DIR" 2>/dev/null || true
        grep -rn "subprocess.call.*shell=True" --include="*.py" "$SCAN_DIR" 2>/dev/null || true
        grep -rn "os.system(" --include="*.py" "$SCAN_DIR" 2>/dev/null || true
        grep -rn "exec(" --include="*.js" "$SCAN_DIR" 2>/dev/null || true
        grep -rn "password.*=.*['\"]" --include="*.py" --include="*.js" --include="*.sh" "$SCAN_DIR" 2>/dev/null || true
        grep -rn "api_key.*=.*['\"]" --include="*.py" --include="*.js" "$SCAN_DIR" 2>/dev/null || true
    } > "${REPORT_DIR}/grep_audit.txt" 2>&1 || true
    HIGH=$(wc -l < "${REPORT_DIR}/grep_audit.txt" 2>/dev/null | tr -d ' ')
    FINDINGS=$(cat "${REPORT_DIR}/grep_audit.txt" 2>/dev/null)
fi

TOTAL_ISSUES=$((CRITICAL + HIGH + MEDIUM + LOW))

if [ "$TOTAL_ISSUES" -gt 0 ]; then
    STATUS="ACTION_REQUIRED"
else
    STATUS="CLEAN"
fi

echo "  📊 Scanner: $SCANNER | Files: $TOTAL_FILES | Issues: $TOTAL_ISSUES ($STATUS)"

# --- Step 3: Log the Baseline ---
{
    echo ""
    echo "## $DATE — Security Scan Results"
    echo ""
    echo "- **Scanner:** $SCANNER"
    echo "- **Time:** $TIMESTAMP"
    echo "- **Files Scanned:** $TOTAL_FILES"
    echo "- **Total Issues:** $TOTAL_ISSUES"
    echo "  - CRITICAL: $CRITICAL"
    echo "  - HIGH: $HIGH"
    echo "  - MEDIUM: $MEDIUM"
    echo "  - LOW: $LOW"
    echo "- **Status:** $STATUS"
    echo ""
    echo "---"
} >> "$SECURITY_LOG"

echo "  💾 Logged to $SECURITY_LOG"

# --- Step 4: Mission Control Injection ---
MC_API=""
if [ -x "/workspace/.mc-api-backup" ]; then
    MC_API="/workspace/.mc-api-backup"
fi

if [ "$CRITICAL" -gt 0 ] || [ "$HIGH" -gt 0 ]; then
    echo "  🚨 Critical/High findings detected — creating backlog task..."
    if [ -n "$MC_API" ]; then
        MC_HEALTH=$($MC_API health 2>&1 || true)
        if echo "$MC_HEALTH" | grep -q '"ok":true'; then
            $MC_API create-task \
                --title "[URGENT] Patch Nightly Scan: $HIGH high/$CRITICAL critical issues ($DATE)" \
                --column "Backlog" \
                --tags "Security,Sprint-Blocker" 2>/dev/null || echo "  ⚠️  mc-api create-task failed"
            echo "  ✅ Task injected into Mission Control backlog"
        else
            echo "  ⚠️  Mission Control offline — writing to pending tasks file"
            echo "- [$DATE] [URGENT] $HIGH high / $CRITICAL critical vulnerabilities found" >> "$PENDING_TASKS"
        fi
    else
        echo "  ⚠️  mc-api not available — writing to pending tasks file"
        echo "- [$DATE] [URGENT] $HIGH high / $CRITICAL critical vulnerabilities found" >> "$PENDING_TASKS"
    fi
else
    echo "  ✅ No critical/high vulnerabilities — board clean"
fi

# --- Step 5: Cleanup ---
rm -f "${REPORT_DIR}/semgrep_out.txt" "${REPORT_DIR}/bandit_out.json" "${REPORT_DIR}/grep_audit.txt"

echo ""
echo "✅ Security audit complete — $TIMESTAMP"
echo "   Log: $SECURITY_LOG"
echo "   Status: $STATUS"

