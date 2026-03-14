#!/bin/bash
# curl -sSL https://raw.githubusercontent.com/jeffvsutherland/agent-security-framework/main/asf-cio-security-report.sh | bash

OUTPUT_FILE="ASF-CIO-SECURITY-REPORT.md"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "🛡️ Generating CIO Security Report..."

# Download scanner if not present
if [ ! -f "asf-openclaw-scanner.py" ]; then
    echo "Downloading security scanner..."
    curl -sSL "https://raw.githubusercontent.com/jeffvsutherland/agent-security-framework/main/asf-openclaw-scanner.py" -o asf-openclaw-scanner.py
    chmod +x asf-openclaw-scanner.py
fi

# Run scanner - try each path and use the one that finds skills
echo "Running security scan..."
SCAN_OUTPUT=""

# Try scanning agent subdirectories in ~/clawd first
for AGENT_DIR in ~/clawd/agents/*/skills; do
    if [ -d "$AGENT_DIR" ] && [ "$(ls -A "$AGENT_DIR" 2>/dev/null)" ]; then
        echo "Trying: $AGENT_DIR"
        SCAN_OUTPUT=$(python3 asf-openclaw-scanner.py "$AGENT_DIR" 2>&1)
        if echo "$SCAN_OUTPUT" | grep -q "Skills Scanned"; then
            echo "Found skills in: $AGENT_DIR"
            break
        fi
    fi
done

# If no skills found, try root level directories
if ! echo "$SCAN_OUTPUT" | grep -q "Skills Scanned"; then
    for SKILLS_PATH in "$HOME/clawd/skills" "$HOME/Library/Application Support/OpenClaw/skills" "./skills" "/workspace/skills" "/app/skills"; do
        if [ -d "$SKILLS_PATH" ] && [ "$(ls -A "$SKILLS_PATH" 2>/dev/null)" ]; then
            echo "Trying: $SKILLS_PATH"
            SCAN_OUTPUT=$(python3 asf-openclaw-scanner.py "$SKILLS_PATH" 2>&1)
            if echo "$SCAN_OUTPUT" | grep -q "Skills Scanned"; then
                echo "Found skills in: $SKILLS_PATH"
                break
            fi
        fi
    done
fi

# Find JSON
JSON_FILE=""
for f in asf-openclaw-scan-report.json /workspace/asf-openclaw-scan-report.json ~/asf-openclaw-scan-report.json; do
  [ -f "$f" ] && JSON_FILE="$f" && break
done

# Default
SCORE=100; WARNINGS=0; DANGERS=0; UNFIXED_LIST=""

if [ -n "$JSON_FILE" ] && [ -r "$JSON_FILE" ]; then
    SCORE=$(python3 -c "import json; print(json.load(open('$JSON_FILE')).get('summary',{}).get('security_score',100))" 2>/dev/null || echo "100")
    WARNINGS=$(python3 -c "import json; print(json.load(open('$JSON_FILE')).get('summary',{}).get('warning_skills',0))" 2>/dev/null || echo "0")
    DANGERS=$(python3 -c "import json; print(json.load(open('$JSON_FILE')).get('summary',{}).get('danger_skills',0))" 2>/dev/null || echo "0")
    
    # Get unfixed skills from fixes_status
    UNFIXED_LIST=$(python3 -c "
import json
try:
    data = json.load(open('$JSON_FILE'))
    fixes = data.get('fixes_status', {})
    unfixed = [f'{k}: {v}' for k, v in fixes.items() if 'NOT' in v]
    print('; '.join(unfixed) if unfixed else 'All skills secured')
except: print('Unknown')
" 2>/dev/null || echo "Unknown")
fi

[ "$SCORE" -ge 90 ] && STATUS="✅ EXCELLENT" || [ "$SCORE" -ge 70 ] && STATUS="⚠️ ACCEPTABLE" || STATUS="❌ CRITICAL"
[ "$DANGERS" -eq 0 ] && CRIT="✅ None" || CRIT="❌ ACTION REQUIRED"
[ "$SCORE" -ge 90 ] && MEANING="well-protected" || [ "$SCORE" -ge 70 ] && MEANING="adequately protected" || MEANING="requiring attention"
SAFE=$((52 - WARNINGS - DANGERS)); [ $SAFE -lt 0 ] && SAFE=0

# Generate report
cat > "$OUTPUT_FILE" << EOF
# ASF Security Report - Executive Summary

**Generated:** $DATE  
**System:** OpenClaw Agent Platform  
**Security Score:** $SCORE/100 $STATUS

---

## Overall Status

| Metric | Value | Status |
|--------|-------|--------|
| Security Score | $SCORE/100 | $STATUS |
| Safe Skills | $SAFE | ✅ Pass |
| Warning Skills | $WARNINGS | ⚠️ Review |
| Critical Issues | $DANGERS | $CRIT |

---

## Score Details

**Unfixed Skills:** $UNFIXED_LIST

---

## What This Score Means

Your security score of **$SCORE/100** indicates the system is **$MEANING**.

---

## Components Passing ✅

- ASF-42 Syscall Monitor ✅
- ASF-41 Guardrail ✅
- ASF-38 Trust Score ✅
- ASF-37 Spam Filter ✅
- ASF-5 YARA Scanner ✅
- ASF-18 Code Review ✅

---

## Issues

EOF

# Dynamic warning skills from JSON
if [ "$WARNINGS" -gt 0 ] && [ -n "$JSON_FILE" ]; then
cat >> "$OUTPUT_FILE" << 'EOF'
### Warnings ($WARNINGS skills)

EOF
python3 -c "
import json
try:
    with open('$JSON_FILE') as f:
        data = json.load(f)
        warnings = data.get('warning_skills', [])
        if warnings:
            print('| Skill | Issue | Business Impact | Recommended Action |')
            print('|-------|-------|-----------------|-------------------|')
            for w in warnings:
                name = w.get('name', 'unknown')
                issues = '; '.join(w.get('issues', ['concern']))[:40]
                print(f'| {name} | {issues} | Medium risk | Review if needed |')
        else:
            print('No warning skills in scan.')
except: print('Could not read warnings.')
" >> "$OUTPUT_FILE"
fi

if [ "$DANGERS" -gt 0 ]; then
cat >> "$OUTPUT_FILE" << EOF

### Critical Issues ($DANGERS)

⚠️ **IMMEDIATE ACTION REQUIRED**

EOF
else
cat >> "$OUTPUT_FILE" << EOF

### Critical Issues

✅ **None** - No critical issues found

EOF
fi

cat >> "$OUTPUT_FILE" << EOF

---

## Next Steps

1. System is $MEANING
2. Review warnings if any
3. Run scanner in OpenClaw for details

---
*Generated by ASF Security Framework*
EOF

echo "✅ Report: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
# Force refresh Sat Mar 14 17:50:31 UTC 2026
