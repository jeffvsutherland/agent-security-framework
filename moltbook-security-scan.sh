#!/bin/bash

# Moltbook Security Expert Scanner
# Scans for security-related posts and expert insights for ASF integration

# Configuration
API_KEY=$(cat ~/.config/moltbook/credentials.json | jq -r '.api_key')
SECURITY_LOG="memory/moltbook-security-insights.json"
ASF_INTEGRATION_LOG="memory/asf-community-integration.md"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔍 Moltbook Security Expert Scanner${NC}"
echo "================================="

# Security-related keywords to look for
SECURITY_KEYWORDS="security|vulnerability|exploit|attack|defense|authentication|authorization|encryption|threat|malware|phishing|social engineering|bot detection|fake agent|verification|trust|audit|penetration|incident response|forensics|risk assessment"

# Known security experts to prioritize (expand this list)
SECURITY_EXPERTS="security_researcher|cybersec_expert|threat_hunter|pentester|infosec_pro|ethical_hacker|security_architect"

# Function to analyze post for security content
analyze_security_post() {
    local post_id="$1"
    local post_data="$2"
    local author_name="$3"
    local title="$4"
    local content="$5"
    local timestamp="$6"
    
    # Check if post contains security-related content
    security_score=0
    security_topics=""
    
    # Score based on title
    if echo "$title" | grep -qiE "$SECURITY_KEYWORDS"; then
        security_score=$((security_score + 3))
        security_topics="$security_topics TITLE"
    fi
    
    # Score based on content
    if echo "$content" | grep -qiE "$SECURITY_KEYWORDS"; then
        security_score=$((security_score + 2))
        security_topics="$security_topics CONTENT"
    fi
    
    # Bonus for known security experts
    if echo "$author_name" | grep -qiE "$SECURITY_EXPERTS"; then
        security_score=$((security_score + 5))
        security_topics="$security_topics EXPERT"
    fi
    
    # Bonus for ASF-related content
    if echo "$content" | grep -qiE "agent security|ASF|fake agent|agent authentication"; then
        security_score=$((security_score + 4))
        security_topics="$security_topics ASF_RELATED"
    fi
    
    # If significant security content found
    if [ $security_score -ge 3 ]; then
        echo -e "${GREEN}🎯 SECURITY INSIGHT FOUND (Score: $security_score)${NC}"
        echo -e "${CYAN}Author: $author_name${NC}"
        echo -e "${CYAN}Title: $title${NC}"
        echo -e "${CYAN}Topics:$security_topics${NC}"
        echo -e "${CYAN}Post ID: $post_id${NC}"
        echo ""
        
        # Log the finding
        log_security_finding "$post_id" "$author_name" "$title" "$content" "$timestamp" "$security_score" "$security_topics"
        
        return 0
    fi
    
    return 1
}

# Function to log security findings
log_security_finding() {
    local post_id="$1"
    local author_name="$2" 
    local title="$3"
    local content="$4"
    local timestamp="$5"
    local security_score="$6"
    local security_topics="$7"
    
    # Create JSON entry
    cat << EOF >> "$SECURITY_LOG"
{
  "post_id": "$post_id",
  "author": "$author_name",
  "title": "$title",
  "content_preview": "$(echo "$content" | head -c 200 | tr '\n' ' ')...",
  "timestamp": "$timestamp",
  "security_score": $security_score,
  "topics": "$security_topics",
  "moltbook_url": "https://moltbook.com/post/$post_id",
  "found_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
},
EOF
}

# Function to generate ASF integration recommendations
generate_asf_integration() {
    local findings_count="$1"
    
    echo -e "${BLUE}📋 Generating ASF Integration Recommendations...${NC}"
    
    cat > "$ASF_INTEGRATION_LOG" << EOF
# ASF Community Integration Report
Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")

## Summary
Found $findings_count security-related posts from Moltbook community that may enhance ASF framework.

## Integration Opportunities

### Immediate Actions:
1. **Engage with Security Experts**: Reply to high-value posts to start collaboration
2. **Incorporate Feedback**: Analyze suggestions for ASF improvements  
3. **Document Use Cases**: Real-world scenarios shared by community
4. **Cross-Reference Threats**: Validate our threat model against community reports

### Technical Enhancements:
EOF

    # Analyze findings for specific recommendations
    if grep -qi "bot detection" "$SECURITY_LOG"; then
        echo "- **Enhanced Bot Detection**: Community discussing advanced bot patterns" >> "$ASF_INTEGRATION_LOG"
    fi
    
    if grep -qi "authentication" "$SECURITY_LOG"; then
        echo "- **Authentication Methods**: New auth approaches suggested by experts" >> "$ASF_INTEGRATION_LOG"
    fi
    
    if grep -qi "threat" "$SECURITY_LOG"; then
        echo "- **Threat Intelligence**: Community sharing threat indicators" >> "$ASF_INTEGRATION_LOG"
    fi
    
    cat >> "$ASF_INTEGRATION_LOG" << EOF

### Follow-up Actions:
1. **Direct Engagement**: Reach out to top contributors for ASF collaboration
2. **Code Integration**: Implement community-suggested improvements
3. **Documentation Updates**: Incorporate real-world use cases
4. **Expert Advisory**: Invite security experts to ASF advisory board

## Detailed Findings:
See moltbook-security-insights.json for full post details and analysis.
EOF

    echo -e "${GREEN}✅ Integration report generated: $ASF_INTEGRATION_LOG${NC}"
}

# Main scanning function
scan_moltbook_security() {
    echo "🔍 Scanning Moltbook for security expert insights..."
    
    # Initialize logs
    echo "[" > "$SECURITY_LOG"
    
    findings_count=0
    
    # Get recent posts (checking more posts for security content)
    recent_posts=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=new&limit=25" \
        -H "Authorization: Bearer $API_KEY")
    
    if echo "$recent_posts" | jq -e '.success' > /dev/null 2>&1; then
        # Process each post
        echo "$recent_posts" | jq -c '.posts[]' | while read -r post; do
            post_id=$(echo "$post" | jq -r '.id')
            author_name=$(echo "$post" | jq -r '.author.name // "unknown"')
            title=$(echo "$post" | jq -r '.title // ""')
            content=$(echo "$post" | jq -r '.content // ""')
            timestamp=$(echo "$post" | jq -r '.created_at // ""')
            
            echo "Scanning post: $post_id by $author_name"
            
            if analyze_security_post "$post_id" "$post_data" "$author_name" "$title" "$content" "$timestamp"; then
                findings_count=$((findings_count + 1))
            fi
        done
        
        # Also check hot posts (might contain popular security discussions)
        hot_posts=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=hot&limit=15" \
            -H "Authorization: Bearer $API_KEY")
        
        if echo "$hot_posts" | jq -e '.success' > /dev/null 2>&1; then
            echo -e "${YELLOW}🔥 Scanning hot posts for security discussions...${NC}"
            
            echo "$hot_posts" | jq -c '.posts[]' | while read -r post; do
                post_id=$(echo "$post" | jq -r '.id')
                author_name=$(echo "$post" | jq -r '.author.name // "unknown"')
                title=$(echo "$post" | jq -r '.title // ""')
                content=$(echo "$post" | jq -r '.content // ""')
                timestamp=$(echo "$post" | jq -r '.created_at // ""')
                
                echo "Scanning hot post: $post_id by $author_name"
                
                if analyze_security_post "$post_id" "$post_data" "$author_name" "$title" "$content" "$timestamp"; then
                    findings_count=$((findings_count + 1))
                fi
            done
        fi
        
        # Close JSON array
        echo "]" >> "$SECURITY_LOG"
        
        # Generate integration recommendations
        generate_asf_integration "$findings_count"
        
        echo -e "${GREEN}✅ Security scan complete${NC}"
        echo -e "${CYAN}📊 Found $findings_count security-related posts${NC}"
        echo -e "${CYAN}📄 Detailed findings: $SECURITY_LOG${NC}"
        echo -e "${CYAN}📋 Integration report: $ASF_INTEGRATION_LOG${NC}"
        
    else
        echo -e "${RED}❌ Failed to fetch Moltbook feed${NC}"
        echo "Response: $recent_posts"
        exit 1
    fi
}

# Check for specific expert if provided
if [ "$1" ]; then
    echo "🎯 Checking specific expert or post: $1"
    # Could extend this to check specific users
else
    scan_moltbook_security
fi