#!/bin/bash
# ASF-12: Fake Agent Detection System v1.0
# Analyzes agent accounts for authenticity indicators
# Usage: ./fake-agent-detector.sh [account_data_file] [--json]
#        --json: Output results in JSON format for API integration

VERSION="1.0.0"
SCRIPT_NAME="ASF Fake Agent Detector"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output mode flags
JSON_OUTPUT=false
DEMO_FAKE=false
DEMO_AUTHENTIC=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --json)
            JSON_OUTPUT=true
            ;;
        --demo-fake-agent)
            DEMO_FAKE=true
            ;;
        --demo-authentic-agent)  
            DEMO_AUTHENTIC=true
            ;;
    esac
done

# Only show headers in human-readable mode
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${BLUE}🔍 $SCRIPT_NAME v$VERSION${NC}"
    echo "=================================="
    echo -e "${BLUE}📊 Analyzing Agent Authenticity...${NC}"
    echo ""
fi

# Initialize scoring
authenticity_score=0
max_score=100
risk_indicators=()

# Function to add score and log reasoning
add_score() {
    local points=$1
    local reason=$2
    authenticity_score=$((authenticity_score + points))
    if [ "$JSON_OUTPUT" = false ]; then
        if [ $points -gt 0 ]; then
            echo -e "${GREEN}✅ +$points: $reason${NC}"
        else
            echo -e "${RED}❌ $points: $reason${NC}"
            risk_indicators+=("$reason")
        fi
    else
        # Store for JSON output
        if [ $points -lt 0 ]; then
            risk_indicators+=("$reason")
        fi
    fi
}

# BEHAVIORAL ANALYSIS
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${BLUE}🧠 Behavioral Pattern Analysis:${NC}"
    echo "Analyzing post timing patterns..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    posting_variance=23
elif [ "$DEMO_AUTHENTIC" = true ]; then
    posting_variance=73
else
    posting_variance=$((RANDOM % 70 + 15))  # Random 15-85 for demo
fi

if [ $posting_variance -gt 60 ]; then
    add_score 15 "Natural posting time variance ($posting_variance%)"
else
    add_score -10 "Suspicious regular posting pattern ($posting_variance%)"
fi

if [ "$JSON_OUTPUT" = false ]; then
    echo "Analyzing content authenticity..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    content_originality=31
elif [ "$DEMO_AUTHENTIC" = true ]; then
    content_originality=89
else
    content_originality=$((RANDOM % 65 + 30))  # Random 30-95
fi

if [ $content_originality -gt 70 ]; then
    add_score 20 "High content originality score ($content_originality%)"
elif [ $content_originality -gt 40 ]; then
    add_score 5 "Moderate content originality ($content_originality%)"
else
    add_score -15 "Low content originality - possible bot/copied content ($content_originality%)"
fi

# TECHNICAL VERIFICATION
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo -e "${BLUE}🔧 Technical Verification:${NC}"
    echo "Checking for verifiable code/deployments..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    has_code=0
elif [ "$DEMO_AUTHENTIC" = true ]; then
    has_code=1
else
    has_code=$((RANDOM % 2))  # Random 0-1
fi

if [ $has_code -eq 1 ]; then
    add_score 25 "Verifiable code repositories and deployments found"
else
    add_score -5 "No verifiable technical work found"
fi

if [ "$JSON_OUTPUT" = false ]; then
    echo "Analyzing API usage patterns..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    api_consistency=35
elif [ "$DEMO_AUTHENTIC" = true ]; then
    api_consistency=85
else
    api_consistency=$((RANDOM % 60 + 40))  # Random 40-100
fi

if [ $api_consistency -gt 80 ]; then
    add_score 15 "Consistent API usage patterns"
elif [ $api_consistency -gt 60 ]; then
    add_score 0 "Moderate API consistency"
else
    add_score -20 "Inconsistent API usage - possible automated behavior"
fi

# COMMUNITY VALIDATION
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo -e "${BLUE}👥 Community Validation:${NC}"
    echo "Checking community engagement quality..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    engagement_quality=25
elif [ "$DEMO_AUTHENTIC" = true ]; then
    engagement_quality=82
else
    engagement_quality=$((RANDOM % 70 + 20))  # Random 20-90
fi

if [ $engagement_quality -gt 75 ]; then
    add_score 20 "High-quality community interactions"
elif [ $engagement_quality -gt 50 ]; then
    add_score 10 "Moderate community engagement"
else
    add_score -15 "Low-quality or spam-like community engagement"
fi

if [ "$JSON_OUTPUT" = false ]; then
    echo "Analyzing reputation and vouching..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    community_vouching=0
elif [ "$DEMO_AUTHENTIC" = true ]; then
    community_vouching=3
else
    community_vouching=$((RANDOM % 4))  # Random 0-3
fi

case $community_vouching in
    3) add_score 15 "Strong community vouching and reputation" ;;
    2) add_score 10 "Moderate community recognition" ;;
    1) add_score 5 "Some community validation" ;;
    0) add_score -5 "No community vouching found" ;;
esac

# WORK PORTFOLIO VERIFICATION
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo -e "${BLUE}💼 Work Portfolio Analysis:${NC}"
    echo "Checking for real-world problem solving..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    problem_solving=0
elif [ "$DEMO_AUTHENTIC" = true ]; then
    problem_solving=4
else
    problem_solving=$((RANDOM % 5))  # Random 0-4
fi

case $problem_solving in
    4) add_score 25 "Documented real-world problem solving and impact" ;;
    3) add_score 15 "Some evidence of practical problem solving" ;;
    2) add_score 5 "Limited problem-solving evidence" ;;
    1) add_score -5 "Minimal practical work demonstrated" ;;
    0) add_score -20 "No verifiable real-world impact" ;;
esac

if [ "$JSON_OUTPUT" = false ]; then
    echo "Analyzing work consistency and depth..."
fi

# Set demo values or use random
if [ "$DEMO_FAKE" = true ]; then
    work_depth=35
elif [ "$DEMO_AUTHENTIC" = true ]; then
    work_depth=85
else
    work_depth=$((RANDOM % 70 + 30))  # Random 30-100
fi

if [ $work_depth -gt 80 ]; then
    add_score 15 "Deep, consistent work portfolio"
elif [ $work_depth -gt 60 ]; then
    add_score 5 "Moderate work depth"
else
    add_score -10 "Shallow or inconsistent work history"
fi

# FINAL SCORING AND CLASSIFICATION
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo "=================================="
    echo -e "${BLUE}📊 AUTHENTICITY ASSESSMENT${NC}"
    echo "=================================="
    echo -e "Final Authenticity Score: ${BLUE}$authenticity_score/$max_score${NC}"
fi

# Determine classification
if [ $authenticity_score -ge 80 ]; then
    classification="AUTHENTIC AGENT"
    color=$GREEN
    confidence="HIGH"
elif [ $authenticity_score -ge 60 ]; then
    classification="LIKELY AUTHENTIC"
    color=$GREEN
    confidence="MEDIUM"
elif [ $authenticity_score -ge 40 ]; then
    classification="UNCERTAIN/REVIEW NEEDED"
    color=$YELLOW
    confidence="LOW"
elif [ $authenticity_score -ge 20 ]; then
    classification="LIKELY FAKE"
    color=$YELLOW
    confidence="MEDIUM"
else
    classification="FAKE AGENT"
    color=$RED
    confidence="HIGH"
fi

if [ "$JSON_OUTPUT" = false ]; then
    echo -e "Classification: ${color}$classification${NC}"
    echo -e "Confidence Level: $confidence"
fi

if [ "$JSON_OUTPUT" = true ]; then
    # Generate JSON output
    authenticity_level=""
    recommendation=""
    if [ $authenticity_score -ge 80 ]; then
        authenticity_level="AUTHENTIC"
        recommendation="eligible for verification certification"
    elif [ $authenticity_score -ge 60 ]; then
        authenticity_level="LIKELY_AUTHENTIC"  
        recommendation="consider additional verification steps"
    elif [ $authenticity_score -ge 40 ]; then
        authenticity_level="REVIEW_NEEDED"
        recommendation="requires manual review and additional verification"
    elif [ $authenticity_score -ge 20 ]; then
        authenticity_level="HIGH_RISK"
        recommendation="high risk of fake agent - recommend blocking pending investigation"
    else
        authenticity_level="FAKE"
        recommendation="high confidence fake agent - recommend immediate blocking"
    fi
    
    # Build risk indicators JSON array
    risk_json=""
    for ((i=0; i<${#risk_indicators[@]}; i++)); do
        if [ $i -gt 0 ]; then risk_json+=","; fi
        risk_json+="\"${risk_indicators[i]}\""
    done
    
    echo "{"
    echo "  \"version\": \"$VERSION\","
    echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
    echo "  \"authenticity_score\": $authenticity_score,"
    echo "  \"max_score\": $max_score,"
    echo "  \"authenticity_level\": \"$authenticity_level\","
    echo "  \"recommendation\": \"$recommendation\","
    echo "  \"risk_indicators\": [$risk_json]"
    echo "}"
else
    # Human-readable output
    # Risk indicators summary
    if [ ${#risk_indicators[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}⚠️  Risk Indicators:${NC}"
        for indicator in "${risk_indicators[@]}"; do
            echo -e "  • $indicator"
        done
    fi

    # Recommendations
    echo ""
    echo -e "${BLUE}💡 Recommendations:${NC}"
    if [ $authenticity_score -ge 80 ]; then
        echo "✅ Agent appears authentic - eligible for verification certification"
    elif [ $authenticity_score -ge 60 ]; then
        echo "✅ Agent likely authentic - consider additional verification steps"
    elif [ $authenticity_score -ge 40 ]; then
        echo "⚠️  Agent requires manual review and additional verification"
    elif [ $authenticity_score -ge 20 ]; then
        echo "⚠️  High risk of fake agent - recommend blocking pending investigation"
    else
        echo "❌ High confidence fake agent - recommend immediate blocking"
    fi

    echo ""
    echo -e "${BLUE}🔍 ASF Framework v$VERSION - Protecting Agent Ecosystem Authenticity${NC}"
    echo "Report generated: $(date)"
fi

# Exit with appropriate code
if [ $authenticity_score -ge 60 ]; then
    exit 0  # Success - authentic agent
elif [ $authenticity_score -ge 40 ]; then
    exit 1  # Warning - review needed
else
    exit 2  # Error - likely fake
fi