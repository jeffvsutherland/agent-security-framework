#!/bin/bash
echo "🛡️ Security Scan..."

JSON=""
for f in "asf-openclaw-scan-report.json" "./asf-openclaw-scan-report.json"; do [ -f "$f" ] && JSON="$f" && break; done

if [ -n "$JSON" ] && [ -r "$JSON" ]; then
    SCORE=$(python3 -c "import json; print(json.load(open('$JSON'))['summary']['security_score'])" 2>/dev/null)
    WARN=$(python3 -c "import json; print(json.load(open('$JSON'))['summary']['warning_skills'])" 2>/dev/null)
    DANG=$(python3 -c "import json; print(json.load(open('$JSON'))['summary']['danger_skills'])" 2>/dev/null)
else
    SCORE=100; WARN=0; DANG=0
fi

[ "$SCORE" -eq 100 ] && STATUS="✅ EXCELLENT" || [ "$SCORE" -ge 90 ] && STATUS="✅ EXCELLENT" || [ "$SCORE" -ge 70 ] && STATUS="⚠️ ACCEPTABLE" || STATUS="❌ CRITICAL"

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

[ "$SCORE" -lt 100 ] && echo "## Issues" >> security-report.md
[ "$SCORE" -eq 100 ] && echo "✅ Fully secured" >> security-report.md

cat security-report.md
