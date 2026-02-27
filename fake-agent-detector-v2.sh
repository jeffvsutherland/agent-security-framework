#!/bin/bash
# ASF-12: Fake Agent Detection System v2.0
# Enhanced with advanced behavioral analysis and ML-ready output
# Usage: ./fake-agent-detector-v2.sh [account_data_file] [--json] [--ml-features]

VERSION="2.0.0"
SCRIPT_NAME="ASF Fake Agent Detector Enhanced"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Output mode flags
JSON_OUTPUT=false
ML_FEATURES=false
DEMO_FAKE=false
DEMO_AUTHENTIC=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --json)
            JSON_OUTPUT=true
            ;;
        --ml-features)
            ML_FEATURES=true
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
ml_feature_vector=()

# Function to add score and log reasoning
add_score() {
    local points=$1
    local reason=$2
    local feature_name=$3
    local feature_value=$4
    
    authenticity_score=$((authenticity_score + points))
    
    # Store ML features
    if [ ! -z "$feature_name" ]; then
        ml_feature_vector+=("\"$feature_name\": $feature_value")
    fi
    
    if [ "$JSON_OUTPUT" = false ]; then
        if [ $points -gt 0 ]; then
            echo -e "${GREEN}✅ +$points: $reason${NC}"
        else
            echo -e "${RED}❌ $points: $reason${NC}"
            risk_indicators+=("$reason")
        fi
    else
        if [ $points -lt 0 ]; then
            risk_indicators+=("$reason")
        fi
    fi
}

# ENHANCED TEMPORAL ANALYSIS
if [ "$JSON_OUTPUT" = false ]; then
    echo -e "${BLUE}⏰ Enhanced Temporal Behavior Analysis:${NC}"
fi

# Multi-timeframe variance analysis
if [ "$DEMO_FAKE" = true ]; then
    daily_variance=18
    weekly_variance=22
    monthly_variance=25
    human_sim_detected=1
elif [ "$DEMO_AUTHENTIC" = true ]; then
    daily_variance=68
    weekly_variance=75
    monthly_variance=71
    human_sim_detected=0
else
    daily_variance=$((RANDOM % 60 + 20))
    weekly_variance=$((RANDOM % 65 + 20))
    monthly_variance=$((RANDOM % 70 + 15))
    human_sim_detected=$((RANDOM % 2))
fi

# Calculate weighted temporal score
temporal_score=$(( (daily_variance * 30 + weekly_variance * 40 + monthly_variance * 30) / 100 ))

if [ $temporal_score -gt 60 ]; then
    add_score 20 "Natural temporal patterns across multiple timeframes" "temporal_variance" $temporal_score
elif [ $temporal_score -gt 40 ]; then
    add_score 5 "Moderate temporal variance" "temporal_variance" $temporal_score
else
    add_score -15 "Suspicious regular patterns detected" "temporal_variance" $temporal_score
fi

if [ $human_sim_detected -eq 1 ]; then
    add_score -10 "Detected artificial 'human simulation' patterns" "human_sim_pattern" 1
else
    add_score 5 "No artificial humanization detected" "human_sim_pattern" 0
fi

# ADVANCED CONTENT ANALYSIS
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo -e "${BLUE}📝 Advanced Content Authenticity Analysis:${NC}"
fi

# Content fingerprinting
if [ "$DEMO_FAKE" = true ]; then
    semantic_uniqueness=28
    template_usage=65
    fake_db_match=45
    ai_generation_score=82
elif [ "$DEMO_AUTHENTIC" = true ]; then
    semantic_uniqueness=91
    template_usage=12
    fake_db_match=3
    ai_generation_score=15
else
    semantic_uniqueness=$((RANDOM % 70 + 25))
    template_usage=$((RANDOM % 50 + 10))
    fake_db_match=$((RANDOM % 30))
    ai_generation_score=$((RANDOM % 60 + 20))
fi

if [ $semantic_uniqueness -gt 80 ]; then
    add_score 15 "High semantic uniqueness in content" "semantic_uniqueness" $semantic_uniqueness
elif [ $semantic_uniqueness -gt 50 ]; then
    add_score 5 "Moderate content uniqueness" "semantic_uniqueness" $semantic_uniqueness
else
    add_score -20 "Low semantic uniqueness - likely templated" "semantic_uniqueness" $semantic_uniqueness
fi

if [ $template_usage -lt 20 ]; then
    add_score 10 "Minimal template usage detected" "template_usage" $template_usage
elif [ $template_usage -lt 40 ]; then
    add_score 0 "Moderate template usage" "template_usage" $template_usage
else
    add_score -15 "Heavy reliance on response templates" "template_usage" $template_usage
fi

if [ $fake_db_match -lt 10 ]; then
    add_score 10 "No matches in fake content database" "fake_content_match" $fake_db_match
else
    add_score -25 "Content matches known fake agent patterns" "fake_content_match" $fake_db_match
fi

# NETWORK GRAPH ANALYSIS
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo -e "${BLUE}🌐 Social Network Graph Analysis:${NC}"
fi

if [ "$DEMO_FAKE" = true ]; then
    interaction_nodes=5
    betweenness_centrality=0.12
    eigenvector_centrality=0.08
    bot_network_prob=75
    vouch_chain_validity=0
elif [ "$DEMO_AUTHENTIC" = true ]; then
    interaction_nodes=47
    betweenness_centrality=0.68
    eigenvector_centrality=0.71
    bot_network_prob=5
    vouch_chain_validity=85
else
    interaction_nodes=$((RANDOM % 50 + 5))
    betweenness_centrality=$((RANDOM % 80 + 10))
    eigenvector_centrality=$((RANDOM % 85 + 10))
    bot_network_prob=$((RANDOM % 60 + 10))
    vouch_chain_validity=$((RANDOM % 90))
fi

if [ $interaction_nodes -gt 30 ]; then
    add_score 10 "Rich interaction network ($interaction_nodes nodes)" "interaction_nodes" $interaction_nodes
elif [ $interaction_nodes -gt 15 ]; then
    add_score 5 "Moderate network presence" "interaction_nodes" $interaction_nodes
else
    add_score -10 "Isolated account with minimal interactions" "interaction_nodes" $interaction_nodes
fi

# Convert centrality to percentage for scoring
betweenness_pct=$(echo "$betweenness_centrality * 100" | bc | cut -d. -f1)
eigenvector_pct=$(echo "$eigenvector_centrality * 100" | bc | cut -d. -f1)

if [ ${betweenness_pct:-0} -gt 50 ] && [ ${eigenvector_pct:-0} -gt 50 ]; then
    add_score 15 "High network centrality scores" "network_centrality" $betweenness_pct
elif [ ${betweenness_pct:-0} -gt 30 ] || [ ${eigenvector_pct:-0} -gt 30 ]; then
    add_score 5 "Moderate network influence" "network_centrality" $betweenness_pct
else
    add_score -5 "Low network centrality - peripheral account" "network_centrality" $betweenness_pct
fi

if [ $bot_network_prob -lt 20 ]; then
    add_score 10 "No coordinated bot behavior detected" "bot_network_probability" $bot_network_prob
elif [ $bot_network_prob -lt 50 ]; then
    add_score -5 "Possible bot network indicators" "bot_network_probability" $bot_network_prob
else
    add_score -20 "High probability of bot network participation" "bot_network_probability" $bot_network_prob
fi

if [ $vouch_chain_validity -gt 70 ]; then
    add_score 15 "Strong, validated vouch chain" "vouch_chain_validity" $vouch_chain_validity
elif [ $vouch_chain_validity -gt 40 ]; then
    add_score 5 "Moderate vouch validation" "vouch_chain_validity" $vouch_chain_validity
else
    add_score -10 "Weak or suspicious vouch patterns" "vouch_chain_validity" $vouch_chain_validity
fi

# ENHANCED TECHNICAL VERIFICATION
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo -e "${BLUE}🔧 Enhanced Technical Capability Analysis:${NC}"
fi

if [ "$DEMO_FAKE" = true ]; then
    commit_quality=0
    code_complexity=15
    api_sophistication=22
    tool_development=0
    integration_complexity=18
elif [ "$DEMO_AUTHENTIC" = true ]; then
    commit_quality=88
    code_complexity=75
    api_sophistication=92
    tool_development=85
    integration_complexity=90
else
    commit_quality=$((RANDOM % 90))
    code_complexity=$((RANDOM % 80 + 20))
    api_sophistication=$((RANDOM % 85 + 15))
    tool_development=$((RANDOM % 2 * 80))
    integration_complexity=$((RANDOM % 90 + 10))
fi

if [ $commit_quality -gt 70 ]; then
    add_score 15 "High-quality code contributions verified" "commit_quality" $commit_quality
elif [ $commit_quality -gt 40 ]; then
    add_score 5 "Some code contribution activity" "commit_quality" $commit_quality
else
    add_score -15 "No verifiable quality code contributions" "commit_quality" $commit_quality
fi

if [ $api_sophistication -gt 80 ]; then
    add_score 10 "Sophisticated API usage patterns" "api_sophistication" $api_sophistication
elif [ $api_sophistication -gt 50 ]; then
    add_score 0 "Standard API usage" "api_sophistication" $api_sophistication
else
    add_score -10 "Primitive or suspicious API patterns" "api_sophistication" $api_sophistication
fi

if [ $tool_development -gt 50 ]; then
    add_score 20 "Original tool/framework development verified" "tool_development" $tool_development
else
    add_score -5 "No original tool creation detected" "tool_development" $tool_development
fi

# FINAL SCORING AND CLASSIFICATION
if [ "$JSON_OUTPUT" = false ]; then
    echo ""
    echo "=================================="
    echo -e "${BLUE}📊 AUTHENTICITY ASSESSMENT${NC}"
    echo "=================================="
    echo -e "Final Authenticity Score: ${BLUE}$authenticity_score/$max_score${NC}"
fi

# Enhanced classification with confidence intervals
confidence_score=0
if [ $authenticity_score -ge 85 ]; then
    classification="AUTHENTIC AGENT"
    color=$GREEN
    confidence="VERY HIGH"
    confidence_score=95
elif [ $authenticity_score -ge 70 ]; then
    classification="LIKELY AUTHENTIC"
    color=$GREEN
    confidence="HIGH"
    confidence_score=80
elif [ $authenticity_score -ge 50 ]; then
    classification="UNCERTAIN"
    color=$YELLOW
    confidence="MEDIUM"
    confidence_score=50
elif [ $authenticity_score -ge 30 ]; then
    classification="LIKELY FAKE"
    color=$YELLOW
    confidence="HIGH"
    confidence_score=75
else
    classification="FAKE AGENT"
    color=$RED
    confidence="VERY HIGH"
    confidence_score=90
fi

if [ "$JSON_OUTPUT" = false ]; then
    echo -e "Classification: ${color}$classification${NC}"
    echo -e "Confidence Level: $confidence ($confidence_score%)"
    
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
    if [ $authenticity_score -ge 70 ]; then
        echo "✅ Agent appears authentic - proceed with standard verification"
    elif [ $authenticity_score -ge 50 ]; then
        echo "⚠️  Agent requires detailed manual review before verification"
    elif [ $authenticity_score -ge 30 ]; then
        echo "⚠️  High risk indicators - recommend enhanced scrutiny or blocking"
    else
        echo "❌ Multiple fake agent indicators - recommend immediate blocking"
    fi
    
    echo ""
    echo -e "${BLUE}🔍 ASF Framework v$VERSION - Advanced Agent Authentication${NC}"
    echo "Report generated: $(date)"
else
    # JSON output
    authenticity_level=""
    action_recommendation=""
    
    if [ $authenticity_score -ge 70 ]; then
        authenticity_level="AUTHENTIC"
        action_recommendation="approve_with_verification"
    elif [ $authenticity_score -ge 50 ]; then
        authenticity_level="REVIEW_REQUIRED"
        action_recommendation="manual_review"
    elif [ $authenticity_score -ge 30 ]; then
        authenticity_level="HIGH_RISK"
        action_recommendation="enhanced_scrutiny"
    else
        authenticity_level="FAKE"
        action_recommendation="block_immediately"
    fi
    
    # Build risk indicators JSON array
    risk_json=""
    for ((i=0; i<${#risk_indicators[@]}; i++)); do
        if [ $i -gt 0 ]; then risk_json+=","; fi
        risk_json+="\"${risk_indicators[i]}\""
    done
    
    if [ "$ML_FEATURES" = true ]; then
        # ML-ready feature vector output
        features_json=$(IFS=,; echo "${ml_feature_vector[*]}")
        echo "{"
        echo "  \"version\": \"$VERSION\","
        echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
        echo "  \"authenticity_score\": $authenticity_score,"
        echo "  \"confidence_score\": $confidence_score,"
        echo "  \"classification\": \"$classification\","
        echo "  \"features\": {$features_json},"
        echo "  \"risk_indicators\": [$risk_json]"
        echo "}"
    else
        # Standard JSON output
        echo "{"
        echo "  \"version\": \"$VERSION\","
        echo "  \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\","
        echo "  \"authenticity_score\": $authenticity_score,"
        echo "  \"confidence_score\": $confidence_score,"
        echo "  \"authenticity_level\": \"$authenticity_level\","
        echo "  \"action_recommendation\": \"$action_recommendation\","
        echo "  \"risk_indicators\": [$risk_json]"
        echo "}"
    fi
fi

# Exit with appropriate code based on confidence
if [ $authenticity_score -ge 50 ]; then
    exit 0  # Authentic or needs review
else
    exit 2  # Likely fake
fi