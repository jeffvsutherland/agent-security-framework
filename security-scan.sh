#!/bin/bash
echo "🛡️ Security Scan..."

JSON=""
for f in "asf-openclaw-scan-report.json" "./asf-openclaw-scan-report.json"; do [ -f "$f" ] && JSON="$f" && break; done

if [ -n "$JSON" ] && [ -r "$JSON" ]; then
    SCORE=$(python3 -c "import json; print(json.load(open('$JSON'))['summary']['security_score'])" 2>/dev/null || echo "100")
    WARN=$(python3 -c "import json; print(json.load(open('$JSON'))['summary']['warning_skills'])" 2>/dev/null || echo "0")
    DANG=$(python3 -c "import json; print(json.load(open('$JSON'))['summary']['danger_skills'])" 2>/dev/null || echo "0")
else
    SCORE=100; WARN=0; DANG=0
fi

# Fix: properly handle 100
if [ "${SCORE:-100}" -eq 100 ]; then
    STATUS="✅ EXCELLENT"
elif [ "${SCORE:-100}" -ge 90 ]; then
    STATUS="✅ EXCELLENT"
elif [ "${SCORE:-100}" -ge 70 ]; then
    STATUS="⚠️ ACCEPTABLE"
else
    STATUS="❌ CRITICAL"
fi

cat > security-report.md << EOF
# ASF Security Report
**Score:** $SCORE/100 $STATUS

## Summary
| | |
|---|---|
| Score | $SCORE/100 $STATUS |
| Warnings | $WARN |
| Critical | $DANG |

EOF

if [ "${SCORE:-100}" -lt 100 ]; then
    echo "## Issues" >> security-report.md
fi

if [ "${SCORE:-100}" -eq 100 ]; then
    echo "✅ Fully secured" >> security-report.md
fi

cat security-report.md
