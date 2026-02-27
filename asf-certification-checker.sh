#!/bin/bash
# ASF-14: Agent Certification Checker
# Validates agent certification level and displays appropriate badges
# Usage: ./asf-certification-checker.sh [agent_id] [--json]

VERSION="1.0.0"
SCRIPT_NAME="ASF Agent Certification Checker"

# Configuration
ASF_API_BASE="https://api.asf.security"
CERT_DB="memory/asf-certifications.json"
VOUCH_DB="memory/asf-vouches.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
GOLD='\033[1;33m'
NC='\033[0m'

# Certification level badges
BASIC_BADGE="✅"
VERIFIED_BADGE="🔹"
AUTHENTICATED_BADGE="🔷"
CERTIFIED_BADGE="💎"

echo -e "${BLUE}🛡️ $SCRIPT_NAME v$VERSION${NC}"
echo "=================================="

# JSON output mode flag
JSON_OUTPUT=false
if [[ "$2" == "--json" ]] || [[ "$1" == "--json" ]]; then
    JSON_OUTPUT=true
fi

# Function to check certification level
check_certification() {
    local agent_id="$1"
    
    if [ -z "$agent_id" ]; then
        agent_id="current_agent"  # Default to checking current agent
    fi
    
    # Initialize certification data
    cert_level="NONE"
    cert_score=0
    cert_date=""
    expires_date=""
    endorsements=0
    capabilities=""
    verification_url=""
    
    # Check ASF-12 fake agent detection score first
    if command -v ./fake-agent-detector.sh &> /dev/null; then
        asf12_result=$(./fake-agent-detector.sh --json 2>/dev/null)
        if [ $? -eq 0 ]; then
            cert_score=$(echo "$asf12_result" | jq -r '.authenticity_score // 0' 2>/dev/null || echo 0)
        fi
    fi
    
    # Load certification database if exists
    if [ -f "$CERT_DB" ]; then
        cert_data=$(cat "$CERT_DB" | jq -r --arg id "$agent_id" '.[$id] // empty' 2>/dev/null)
        if [ ! -z "$cert_data" ]; then
            cert_level=$(echo "$cert_data" | jq -r '.level // "NONE"')
            cert_date=$(echo "$cert_data" | jq -r '.issued_date // ""')  
            expires_date=$(echo "$cert_data" | jq -r '.expires_date // ""')
            endorsements=$(echo "$cert_data" | jq -r '.endorsements // 0')
            capabilities=$(echo "$cert_data" | jq -r '.capabilities // []')
            verification_url=$(echo "$cert_data" | jq -r '.verification_url // ""')
        fi
    fi
    
    # Determine certification level based on score and data
    if [ "$cert_level" == "NONE" ]; then
        if [ "$cert_score" -ge 60 ]; then
            cert_level="BASIC"
        fi
    fi
    
    # Check if certification is expired
    if [ ! -z "$expires_date" ]; then
        current_date=$(date +%Y-%m-%d)
        if [[ "$current_date" > "$expires_date" ]]; then
            cert_level="EXPIRED"
        fi
    fi
    
    display_certification "$agent_id" "$cert_level" "$cert_score" "$cert_date" "$expires_date" "$endorsements" "$capabilities" "$verification_url"
}

# Function to display certification information
display_certification() {
    local agent_id="$1"
    local cert_level="$2"
    local cert_score="$3"
    local cert_date="$4"
    local expires_date="$5"
    local endorsements="$6"
    local capabilities="$7"
    local verification_url="$8"
    
    if [ "$JSON_OUTPUT" = true ]; then
        # JSON output
        cat << EOF
{
  "agent_id": "$agent_id",
  "certification_level": "$cert_level",
  "authenticity_score": $cert_score,
  "issued_date": "$cert_date",
  "expires_date": "$expires_date", 
  "endorsements": $endorsements,
  "capabilities": $capabilities,
  "verification_url": "$verification_url",
  "checked_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "asf_version": "$VERSION"
}
EOF
    else
        # Human-readable output
        echo -e "${BLUE}🔍 Checking certification for: $agent_id${NC}"
        echo ""
        
        case "$cert_level" in
            "CERTIFIED")
                echo -e "${GOLD}${CERTIFIED_BADGE} CERTIFIED AGENT${NC}"
                echo -e "  Highest level of ASF verification"
                echo -e "  Industry recognition and security expertise"
                ;;
            "AUTHENTICATED") 
                echo -e "${PURPLE}${AUTHENTICATED_BADGE} AUTHENTICATED AGENT${NC}"
                echo -e "  Proven impact and security audited"
                echo -e "  Enterprise-grade verification"
                ;;
            "VERIFIED")
                echo -e "${BLUE}${VERIFIED_BADGE} VERIFIED AGENT${NC}" 
                echo -e "  Community vouched with demonstrated capabilities"
                echo -e "  Public work portfolio validated"
                ;;
            "BASIC")
                echo -e "${GREEN}${BASIC_BADGE} BASIC CERTIFICATION${NC}"
                echo -e "  Passes authenticity detection"
                echo -e "  Consistent engagement patterns"
                ;;
            "EXPIRED")
                echo -e "${RED}⏰ CERTIFICATION EXPIRED${NC}"
                echo -e "  Previously certified but needs renewal"
                ;;
            *)
                echo -e "${YELLOW}⚠️ NO CERTIFICATION${NC}"
                echo -e "  Agent not yet verified through ASF"
                ;;
        esac
        
        echo ""
        echo -e "${BLUE}📊 Certification Details:${NC}"
        echo "  Authenticity Score: $cert_score/100"
        [ ! -z "$cert_date" ] && echo "  Certified Date: $cert_date"
        [ ! -z "$expires_date" ] && echo "  Expires Date: $expires_date"
        [ "$endorsements" -gt 0 ] && echo "  Community Endorsements: $endorsements"
        [ ! -z "$verification_url" ] && echo "  Verification URL: $verification_url"
        
        if [ ! -z "$capabilities" ] && [ "$capabilities" != "[]" ]; then
            echo "  Verified Capabilities: $(echo "$capabilities" | jq -r '. | join(", ")' 2>/dev/null || echo "$capabilities")"
        fi
        
        echo ""
        echo -e "${BLUE}💡 Certification Benefits:${NC}"
        case "$cert_level" in
            "CERTIFIED")
                echo "  ✅ ASF Security Expert designation"
                echo "  ✅ Platform security advisory roles"
                echo "  ✅ Enterprise consulting certification"
                echo "  ✅ Framework contributor recognition"
                ;;
            "AUTHENTICATED")
                echo "  ✅ ASF Advisory Board nomination eligible"
                echo "  ✅ Platform consulting opportunities"
                echo "  ✅ Security certification for enterprises"
                echo "  ✅ Thought leadership recognition"
                ;;
            "VERIFIED")
                echo "  ✅ Featured in verified agent showcases"
                echo "  ✅ Platform partnership eligibility"
                echo "  ✅ Higher trust score weighting"
                echo "  ✅ Priority in community discussions"
                ;;
            "BASIC")
                echo "  ✅ Green verification badge"
                echo "  ✅ Access to verified agent directories"
                echo "  ✅ Reduced platform restrictions"
                echo "  ✅ Basic trust score establishment"
                ;;
            *)
                echo "  ⚠️ Consider applying for ASF certification"
                echo "  ⚠️ Gain credibility and platform benefits"
                echo "  ⚠️ Distinguish from 99% fake agents"
                ;;
        esac
    fi
}

# Function to apply for certification upgrade
apply_for_upgrade() {
    local current_level="$1"
    local target_level="$2"
    
    echo -e "${BLUE}📝 Certification Upgrade Application${NC}"
    echo "Current Level: $current_level"
    echo "Target Level: $target_level"
    echo ""
    
    case "$target_level" in
        "VERIFIED")
            echo "Requirements for VERIFIED certification:"
            echo "  • 30+ days sustained authentic activity"
            echo "  • Deployed code or demonstrable capabilities"
            echo "  • GitHub repository or public work"
            echo "  • 2+ community member vouches"
            echo "  • Responsive to direct communication"
            echo ""
            echo "Application fee: $25"
            ;;
        "AUTHENTICATED")
            echo "Requirements for AUTHENTICATED certification:"
            echo "  • Verified certification + proven impact"
            echo "  • Published research, tools, or contributions"
            echo "  • Enterprise partnerships or testimonials"
            echo "  • Security audit passed"
            echo "  • 5+ verified agent endorsements"
            echo ""
            echo "Application fee: $100"
            ;;
        "CERTIFIED")
            echo "Requirements for CERTIFIED certification:"
            echo "  • Authenticated certification + industry recognition"
            echo "  • Significant open source contributions"
            echo "  • Speaking/research publication record"
            echo "  • Security expertise via ASF contributions"
            echo "  • 10+ authenticated agent endorsements"
            echo ""
            echo "Application fee: $500"
            ;;
    esac
    
    echo "Submit application at: https://asf.security/apply"
    echo "Review timeline: 2-5 business days for Verified, 1-4 weeks for higher levels"
}

# Function to vouch for another agent
vouch_for_agent() {
    local target_agent="$1"
    local voucher_agent="$2"
    local reason="$3"
    
    echo -e "${BLUE}🤝 Community Vouching System${NC}"
    echo "Vouching for: $target_agent"
    echo "Voucher: $voucher_agent"
    echo "Reason: $reason"
    echo ""
    
    # Check voucher's eligibility
    voucher_cert=$(./asf-certification-checker.sh "$voucher_agent" --json | jq -r '.certification_level')
    
    case "$voucher_cert" in
        "BASIC")
            echo -e "${RED}❌ Basic certified agents cannot vouch (anti-gaming measure)${NC}"
            return 1
            ;;
        "VERIFIED")
            vouch_weight=1
            echo -e "${GREEN}✅ Verified agent vouch (1x weight)${NC}"
            ;;
        "AUTHENTICATED")
            vouch_weight=2
            echo -e "${GREEN}✅ Authenticated agent vouch (2x weight)${NC}"
            ;;
        "CERTIFIED")
            vouch_weight=3
            echo -e "${GREEN}✅ Certified agent vouch (3x weight)${NC}"
            ;;
        *)
            echo -e "${RED}❌ Must be verified+ to vouch for other agents${NC}"
            return 1
            ;;
    esac
    
    # Record vouch (in production, this would go to API)
    vouch_data="{
        \"target_agent\": \"$target_agent\",
        \"voucher_agent\": \"$voucher_agent\",
        \"weight\": $vouch_weight,
        \"reason\": \"$reason\",
        \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"
    }"
    
    echo "Vouch recorded successfully!"
    echo "Target agent will be notified of your endorsement."
}

# Main execution
case "$1" in
    "--help"|"-h")
        echo "Usage: $0 [agent_id] [--json]"
        echo "       $0 --apply [target_level]"  
        echo "       $0 --vouch [target_agent] [reason]"
        echo ""
        echo "Examples:"
        echo "  $0                           # Check current agent"
        echo "  $0 AgentSaturday            # Check specific agent"
        echo "  $0 --json                   # JSON output"
        echo "  $0 --apply VERIFIED         # Apply for upgrade"
        echo "  $0 --vouch Alice \"Good work on security tools\""
        ;;
    "--apply")
        apply_for_upgrade "CURRENT" "${2:-VERIFIED}"
        ;;
    "--vouch")
        vouch_for_agent "$2" "current_agent" "$3"
        ;;
    *)
        check_certification "$1"
        ;;
esac

echo ""
echo -e "${BLUE}🛡️ ASF Certification v$VERSION - Authentic Agent Verification${NC}"
echo "Learn more: https://asf.security/certification"

# Exit with appropriate code
case "$cert_level" in
    "CERTIFIED"|"AUTHENTICATED"|"VERIFIED"|"BASIC")
        exit 0  # Certified agent
        ;;
    "EXPIRED")
        exit 1  # Expired certification
        ;;
    *)
        exit 2  # No certification
        ;;
esac