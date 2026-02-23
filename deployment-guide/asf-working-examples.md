# ASF Working Examples

## Real-World Security Scenarios

### Example 1: Community Moderator Daily Workflow

**Scenario**: You're moderating a Discord/Telegram community and need to track bad actors.

```bash
# Initialize ASF (one-time setup)
./asf-quick-setup.sh

# Morning routine - check overnight activity
~/.asf/asf stats

# Someone reports a crypto scammer in your community
~/.asf/asf report "cryptowolf88" scam "moderator_jane" "Fake giveaway promising 2x return on Bitcoin"

# Later, another user confirms the same pattern
~/.asf/asf report "cryptowolf88" scam "user_mike" "Same scammer, different channel, ETH giveaway scam"

# Check the actor's history
~/.asf/asf query "cryptowolf88"

# Export data for platform reporting
cat ~/.asf/bad-actors.json | jq '.actors.cryptowolf88'
```

**Expected Output**:
```
Total bad actors: 1
Total reports filed: 2

Top reported actors:
  cryptowolf88: 2 reports
```

### Example 2: Security Researcher Pattern Analysis

**Scenario**: You're tracking crypto scam patterns across platforms.

```bash
# Set up research environment
export SPAM_REPORT_DIR="~/security-research/crypto-scams"
export EVIDENCE_DIR="~/security-research/evidence"
./report-moltbook-spam-simple.sh init

# Report pattern: fake giveaways
./report-moltbook-spam-simple.sh report "elonmusk_fake1" impersonation "researcher" "Fake Elon Musk account promising Bitcoin doubles"
./report-moltbook-spam-simple.sh report "elonmusk_fake2" impersonation "researcher" "Another fake Elon account, same pattern"
./report-moltbook-spam-simple.sh report "vitalik_fake1" impersonation "researcher" "Fake Vitalik promoting ETH scam"

# Analyze patterns
echo "=== Impersonation Pattern Analysis ==="
./report-moltbook-spam-simple.sh query "fake"
./report-moltbook-spam-simple.sh query "elon"

# Generate research data
cat ~/.asf/bad-actors.json | jq '.actors | to_entries | map(select(.value.report_count >= 1)) | .[].key' > suspected_impersonators.txt
```

### Example 3: Automated Agent Integration

**Scenario**: Your AI agent detects suspicious activity and auto-reports.

```bash
#!/bin/bash
# agent-security-monitor.sh

ASF_TOOL="./report-moltbook-spam-simple.sh"
CONFIDENCE_THRESHOLD=0.8

# Function your agent calls when it detects suspicious activity
detect_and_report() {
    local username="$1"
    local confidence="$2"
    local detected_pattern="$3"
    local platform="$4"
    
    if (( $(echo "$confidence > $CONFIDENCE_THRESHOLD" | bc -l) )); then
        REPORT_ID=$($ASF_TOOL report "$username" spam "ai_agent" "Auto-detected: $detected_pattern (confidence: $confidence)")
        
        echo "🚨 SECURITY ALERT: Reported $username as $REPORT_ID"
        
        # Log to your agent's security log
        echo "[$(date)] HIGH_CONFIDENCE_DETECTION: $username on $platform - $REPORT_ID" >> agent_security.log
        
        # Optional: Notify human operators for high-confidence detections
        if (( $(echo "$confidence > 0.95" | bc -l) )); then
            echo "🚨 CRITICAL: Manual review needed for $REPORT_ID" | mail -s "ASF Critical Alert" security@yourorg.com
        fi
    fi
}

# Example usage in your agent code
detect_and_report "suspicious_account_123" "0.92" "crypto_giveaway_pattern" "moltbook"
detect_and_report "bot_farmer_456" "0.87" "mass_follow_unfollow" "twitter"

# Review agent's reports
$ASF_TOOL stats
```

### Example 4: Team Collaboration Setup

**Scenario**: Security team sharing intelligence across multiple operators.

```bash
#!/bin/bash
# team-setup.sh

TEAM_SHARE_DIR="/shared/security/asf-intel"
mkdir -p "$TEAM_SHARE_DIR"

# Each team member sets up with shared evidence directory
export EVIDENCE_DIR="$TEAM_SHARE_DIR/evidence"
export BAD_ACTORS_JSON="$TEAM_SHARE_DIR/team-bad-actors.json"
./report-moltbook-spam-simple.sh init

# Team member Alice reports something
./report-moltbook-spam-simple.sh report "phishing_group_1" scam "alice" "Coordinated phishing attack on our platform"

# Team member Bob adds to the same actor
./report-moltbook-spam-simple.sh report "phishing_group_1" scam "bob" "Same group, different domain, targeting wallets"

# Team lead generates daily intel briefing
cat > daily-intel-brief.sh <<'EOF'
#!/bin/bash
echo "=== Daily Security Intelligence Brief $(date) ==="
echo ""
echo "🔢 Overall Stats:"
./report-moltbook-spam-simple.sh stats
echo ""
echo "🔥 New Threats (last 24h):"
grep "$(date -d yesterday +%Y-%m-%d)" ~/.asf/spam-reports.log | grep "Starting spam report" | wc -l | xargs echo "Reports filed:"
echo ""
echo "⚠️ Repeat Offenders:"
cat ~/.asf/bad-actors.json | jq -r '.actors | to_entries | map(select(.value.report_count >= 3)) | sort_by(.value.report_count) | reverse | .[:5] | .[] | "\(.value.username): \(.value.report_count) reports"'
EOF

chmod +x daily-intel-brief.sh
```

### Example 5: Platform Integration

**Scenario**: Integrating ASF with existing moderation tools.

```bash
#!/bin/bash
# platform-integration.sh

# Webhook receiver for platform events
handle_platform_event() {
    local event_type="$1"
    local username="$2"
    local content="$3"
    local reporter="platform_auto"
    
    case "$event_type" in
        "spam_detected")
            ./report-moltbook-spam-simple.sh report "$username" spam "$reporter" "Platform auto-detection: $content"
            ;;
        "harassment_reported")
            ./report-moltbook-spam-simple.sh report "$username" harassment "$reporter" "User report: $content"
            ;;
        "impersonation_flagged")
            ./report-moltbook-spam-simple.sh report "$username" impersonation "$reporter" "Impersonation flag: $content"
            ;;
    esac
}

# Export bad actors for platform ban lists
export_ban_list() {
    echo "# ASF Generated Ban List - $(date)"
    echo "# High-confidence bad actors (3+ reports)"
    
    cat ~/.asf/bad-actors.json | jq -r '
        .actors | 
        to_entries | 
        map(select(.value.report_count >= 3)) | 
        .[].key
    '
}

# Generate platform-specific reports
generate_platform_report() {
    local platform="$1"
    echo "Security Report for $platform - $(date)"
    echo "Generated by Agent Security Framework"
    echo ""
    
    ./report-moltbook-spam-simple.sh stats
    echo ""
    
    echo "Recommended Actions:"
    echo "1. Review high-report-count accounts for platform violations"
    echo "2. Consider automated monitoring for repeat patterns"
    echo "3. Update community guidelines based on emerging threats"
}

# Example usage
handle_platform_event "spam_detected" "badactor789" "Multiple crypto promotion messages"
export_ban_list > platform-ban-list.txt
generate_platform_report "moltbook" > moltbook-security-report.txt
```

### Example 6: Evidence Collection Workflow

**Scenario**: Proper evidence collection for serious violations.

```bash
#!/bin/bash
# evidence-workflow.sh

collect_comprehensive_evidence() {
    local username="$1"
    local violation_type="$2"
    local description="$3"
    
    echo "🔍 Starting comprehensive evidence collection for @$username"
    
    # File initial report
    REPORT_ID=$(./report-moltbook-spam-simple.sh report "$username" "$violation_type" "evidence_collector" "$description")
    echo "📋 Report created: $REPORT_ID"
    
    EVIDENCE_DIR="$HOME/.asf/evidence/$REPORT_ID"
    
    echo "📸 Evidence collection checklist:"
    echo "1. Screenshots → $EVIDENCE_DIR/screenshots/"
    echo "2. Profile data → $EVIDENCE_DIR/profile.json"
    echo "3. Message logs → $EVIDENCE_DIR/messages.txt"
    echo "4. Timeline → $EVIDENCE_DIR/timeline.md"
    
    # Create evidence structure
    mkdir -p "$EVIDENCE_DIR/screenshots"
    
    # Generate evidence templates
    cat > "$EVIDENCE_DIR/timeline.md" <<EOF
# Evidence Timeline for $username

## Initial Detection
- Date: $(date)
- Type: $violation_type
- Description: $description

## Evidence Collected
- [ ] Screenshots of violations
- [ ] Profile information
- [ ] Message/content exports
- [ ] Network analysis (if applicable)

## Actions Taken
- [x] Filed ASF report: $REPORT_ID
- [ ] Platform reported
- [ ] Evidence documented
- [ ] Case closed

## Notes
TODO: Add investigation notes here
EOF
    
    cat > "$EVIDENCE_DIR/profile.json" <<EOF
{
    "username": "$username",
    "investigation_date": "$(date -Iseconds)",
    "profile_data": {
        "display_name": "TODO",
        "bio": "TODO", 
        "follower_count": "TODO",
        "following_count": "TODO",
        "creation_date": "TODO",
        "verification_status": "TODO"
    },
    "network_analysis": {
        "connected_accounts": ["TODO"],
        "similar_patterns": ["TODO"],
        "ip_geolocation": "TODO (if available)"
    }
}
EOF
    
    echo "✅ Evidence structure ready"
    echo "📝 Complete the templates in: $EVIDENCE_DIR"
    echo "🔒 Finalize when done: ./report-moltbook-spam-simple.sh finalize $REPORT_ID"
}

# Example usage
collect_comprehensive_evidence "serious_threat_actor" "harassment" "Coordinated harassment campaign with multiple accounts"
```

## Quick Testing Commands

Verify your ASF setup with these test commands:

```bash
# Test 1: Basic functionality
./report-moltbook-spam-simple.sh report "test_user_$(date +%s)" spam "test" "System validation"

# Test 2: Statistics
./report-moltbook-spam-simple.sh stats

# Test 3: Search functionality  
./report-moltbook-spam-simple.sh query "test"

# Test 4: Report viewing
LATEST_REPORT=$(ls ~/.asf/spam-reports/ | tail -1 | cut -d'.' -f1)
./report-moltbook-spam-simple.sh view "$LATEST_REPORT"

# Test 5: Data integrity
echo "Checking data integrity..."
if [[ -f ~/.asf/bad-actors.json ]] && jq . ~/.asf/bad-actors.json >/dev/null 2>&1; then
    echo "✅ Data integrity check passed"
else
    echo "❌ Data integrity check failed"
fi
```

## Performance Benchmarks

Test ASF performance with realistic loads:

```bash
#!/bin/bash
# performance-test.sh

echo "🏃 ASF Performance Test"
START_TIME=$(date +%s)

# Generate 100 test reports
for i in {1..100}; do
    ./report-moltbook-spam-simple.sh report "perf_test_$i" spam "benchmark" "Performance test report $i" >/dev/null 2>&1
done

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "📊 Results:"
echo "Reports created: 100"
echo "Time taken: ${DURATION}s"
echo "Reports per second: $(( 100 / DURATION ))"

# Cleanup
rm -rf ~/.asf/evidence/SPM-*-PERF*
```

---

**Ready to implement?** Start with `./asf-quick-setup.sh` and try Example 1!