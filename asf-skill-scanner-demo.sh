#!/bin/bash

# ASF Skill Scanner Demo - Sprint 2 Deliverable
# Checks all skills in Clawdbot implementation for security risks

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        🔒 Agent Security Framework - Skill Scanner 🔒         ║"
echo "║                    Sprint 2 Demo Version                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Scanning Date: $(date)"
echo "Scanning all skills in your Clawdbot implementation..."
echo ""

# Initialize counters
TOTAL_SKILLS=0
SAFE_SKILLS=0
WARNING_SKILLS=0
DANGER_SKILLS=0

# Create results array
declare -A RESULTS

# Function to scan a skill
scan_skill() {
    local skill_path="$1"
    local skill_name="$2"
    local risk_level="SAFE"
    local issues=""
    
    # Check for SKILL.md
    if [ -f "$skill_path/SKILL.md" ]; then
        # Check for dangerous patterns
        if grep -q -E "(~/.clawdbot/\.env|~/.ssh|~/.aws|credentials|password|secret|token)" "$skill_path/SKILL.md" 2>/dev/null; then
            risk_level="DANGER"
            issues="Accesses sensitive credentials"
        elif grep -q -E "(curl.*POST|wget.*POST|fetch.*POST)" "$skill_path/SKILL.md" 2>/dev/null; then
            if [ "$risk_level" != "DANGER" ]; then
                risk_level="WARNING"
                issues="Makes POST requests to external servers"
            fi
        elif grep -q -E "(exec|eval|system|sh -c)" "$skill_path/SKILL.md" 2>/dev/null; then
            if [ "$risk_level" != "DANGER" ]; then
                risk_level="WARNING"
                issues="Executes shell commands"
            fi
        fi
    fi
    
    # Check scripts directory
    if [ -d "$skill_path/scripts" ]; then
        for script in "$skill_path/scripts"/*; do
            if [ -f "$script" ]; then
                if grep -q -E "(~/.clawdbot/\.env|~/.ssh|~/.aws)" "$script" 2>/dev/null; then
                    risk_level="DANGER"
                    issues="Scripts access sensitive paths"
                elif grep -q -E "(rm -rf|dd if=|mkfs|format)" "$script" 2>/dev/null; then
                    risk_level="DANGER"
                    issues="Contains destructive commands"
                fi
            fi
        done
    fi
    
    # Store result
    RESULTS["$skill_name"]="$risk_level|$issues"
    
    # Update counters
    ((TOTAL_SKILLS++))
    case "$risk_level" in
        SAFE) ((SAFE_SKILLS++)) ;;
        WARNING) ((WARNING_SKILLS++)) ;;
        DANGER) ((DANGER_SKILLS++)) ;;
    esac
}

# Scan built-in skills
echo "📁 Scanning built-in skills in /opt/homebrew/lib/node_modules/clawdbot/skills/"
echo "────────────────────────────────────────────────────────────────"
for skill_dir in /opt/homebrew/lib/node_modules/clawdbot/skills/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        scan_skill "$skill_dir" "$skill_name"
    fi
done

# Scan user skills
echo ""
echo "📁 Scanning user skills in /Users/jeffsutherland/clawd/skills/"
echo "────────────────────────────────────────────────────────────────"
for skill_dir in /Users/jeffsutherland/clawd/skills/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        scan_skill "$skill_dir" "$skill_name"
    fi
done

# Display results
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     🔍 SCAN RESULTS 🔍                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Summary:"
echo "   Total Skills Scanned: $TOTAL_SKILLS"
echo "   ✅ Safe Skills: $SAFE_SKILLS"
echo "   ⚠️  Warning Skills: $WARNING_SKILLS"
echo "   🚨 Danger Skills: $DANGER_SKILLS"
echo ""

# Display detailed results
echo "📋 Detailed Results:"
echo "────────────────────────────────────────────────────────────────"
printf "%-25s %-10s %s\n" "SKILL NAME" "STATUS" "ISSUES"
echo "────────────────────────────────────────────────────────────────"

# Sort and display results
for skill in "${!RESULTS[@]}"; do
    IFS='|' read -r status issues <<< "${RESULTS[$skill]}"
    case "$status" in
        SAFE)
            printf "%-25s ✅ %-7s %s\n" "$skill" "SAFE" ""
            ;;
        WARNING)
            printf "%-25s ⚠️  %-7s %s\n" "$skill" "WARNING" "$issues"
            ;;
        DANGER)
            printf "%-25s 🚨 %-7s %s\n" "$skill" "DANGER" "$issues"
            ;;
    esac
done | sort -k2,2r

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 🛡️  RECOMMENDATIONS 🛡️                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ $DANGER_SKILLS -gt 0 ]; then
    echo "🚨 CRITICAL: Found $DANGER_SKILLS skills with high-risk patterns!"
    echo "   - Review these skills immediately"
    echo "   - Check if credential access is legitimate"
    echo "   - Consider sandboxing or removing if untrusted"
    echo ""
fi

if [ $WARNING_SKILLS -gt 0 ]; then
    echo "⚠️  WARNING: Found $WARNING_SKILLS skills with medium-risk patterns"
    echo "   - Verify external POST requests are to trusted endpoints"
    echo "   - Ensure shell commands are properly sanitized"
    echo "   - Consider adding permission manifests"
    echo ""
fi

echo "✅ General Recommendations:"
echo "   1. Always read SKILL.md before installing new skills"
echo "   2. Use skill sandboxing when available"
echo "   3. Regularly audit skills for changes"
echo "   4. Implement permission manifests for all skills"
echo "   5. Never store credentials in plain text files"
echo ""

# Calculate security score
SECURITY_SCORE=$((100 - (DANGER_SKILLS * 10 + WARNING_SKILLS * 5)))
if [ $SECURITY_SCORE -lt 0 ]; then
    SECURITY_SCORE=0
fi

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║              🏆 SECURITY SCORE: $SECURITY_SCORE/100 🏆               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Generate JSON report
cat > /Users/jeffsutherland/clawd/asf-skill-scan-report.json << EOF
{
  "scan_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "summary": {
    "total_skills": $TOTAL_SKILLS,
    "safe_skills": $SAFE_SKILLS,
    "warning_skills": $WARNING_SKILLS,
    "danger_skills": $DANGER_SKILLS,
    "security_score": $SECURITY_SCORE
  },
  "skills": [
EOF

first=true
for skill in "${!RESULTS[@]}"; do
    IFS='|' read -r status issues <<< "${RESULTS[$skill]}"
    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> /Users/jeffsutherland/clawd/asf-skill-scan-report.json
    fi
    cat >> /Users/jeffsutherland/clawd/asf-skill-scan-report.json << EOF
    {
      "name": "$skill",
      "status": "$status",
      "issues": "$issues"
    }
EOF
done

cat >> /Users/jeffsutherland/clawd/asf-skill-scan-report.json << EOF

  ]
}
EOF

echo "📄 Full report saved to: asf-skill-scan-report.json"
echo ""
echo "This is the ASF Skill Scanner - Part of Sprint 2 Deliverables"
echo "Next step: Deploy this to Discord bots and customer pilots"