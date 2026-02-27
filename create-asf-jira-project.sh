#!/bin/bash

# Create Agent Security Framework (ASF) Jira Project
# Based on validated community feedback from Moltbook security proposals

# Configuration
JIRA_CONFIG="$HOME/.jira-config"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Load configuration
if [[ ! -f "$JIRA_CONFIG" ]]; then
    echo -e "${RED}❌ Jira not configured. Check ~/.jira-config${NC}"
    exit 1
fi

source "$JIRA_CONFIG"

# Create auth header
AUTH_HEADER="Authorization: Basic $(echo -n "${JIRA_USER}:${JIRA_TOKEN}" | base64)"

echo -e "${BLUE}🛡️ Creating Agent Security Framework (ASF) Project${NC}"
echo "=================================================="
echo ""

# Project creation payload
PROJECT_DATA='{
  "key": "ASF",
  "name": "Agent Security Framework",
  "description": "Building layered defense for agent skill security - from Docker isolation to economic accountability. Based on community-validated architecture from Moltbook security proposals.",
  "projectTypeKey": "software",
  "projectTemplateKey": "com.pyxis.greenhopper.jira:gh-scrum-template",
  "lead": "'$JIRA_USER'"
}'

echo -e "${YELLOW}📋 Creating project with details:${NC}"
echo "• Key: ASF"
echo "• Name: Agent Security Framework" 
echo "• Template: Scrum"
echo "• Lead: $JIRA_USER"
echo ""

# Create the project
echo -e "${BLUE}🚀 Creating project...${NC}"
RESPONSE=$(curl -s -X POST \
  -H "$AUTH_HEADER" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$PROJECT_DATA" \
  "$JIRA_URL/rest/api/3/project")

# Check if creation was successful
if echo "$RESPONSE" | jq -e '.key' >/dev/null 2>&1; then
    PROJECT_KEY=$(echo "$RESPONSE" | jq -r '.key')
    PROJECT_ID=$(echo "$RESPONSE" | jq -r '.id')
    echo -e "${GREEN}✅ Project created successfully!${NC}"
    echo "• Project Key: $PROJECT_KEY"
    echo "• Project ID: $PROJECT_ID"
    echo "• URL: $JIRA_URL/projects/$PROJECT_KEY"
    echo ""
    
    # Create initial epics
    echo -e "${BLUE}📝 Creating initial epics...${NC}"
    
    EPICS=(
        "Layer 0: Static Analysis Tools|Build YARA rules, Docker templates, and evaluation scripts for immediate security scanning"
        "Layer 1: LLM Consensus Engine|Multi-model security analysis with adversarial input detection and cross-validation"
        "Layer 2: Economic Accountability|Slashable collateral system with community-driven security review incentives"
        "Layer 3: Runtime Protection|Permission manifests, behavioral monitoring, and tiered sandboxing solutions"
        "Layer 4: Security Intelligence|Agent Skill Advisory (ASA) database with CVE-style vulnerability tracking"
    )
    
    for epic in "${EPICS[@]}"; do
        IFS='|' read -r title description <<< "$epic"
        
        EPIC_DATA='{
          "fields": {
            "project": {"key": "'$PROJECT_KEY'"},
            "summary": "'$title'",
            "description": "'$description'",
            "issuetype": {"name": "Epic"}
          }
        }'
        
        EPIC_RESPONSE=$(curl -s -X POST \
          -H "$AUTH_HEADER" \
          -H "Accept: application/json" \
          -H "Content-Type: application/json" \
          -d "$EPIC_DATA" \
          "$JIRA_URL/rest/api/3/issue")
          
        if echo "$EPIC_RESPONSE" | jq -e '.key' >/dev/null 2>&1; then
            EPIC_KEY=$(echo "$EPIC_RESPONSE" | jq -r '.key')
            echo "  ✅ Created epic: $EPIC_KEY - $title"
        else
            echo "  ❌ Failed to create epic: $title"
        fi
    done
    
    echo ""
    echo -e "${GREEN}🎉 Agent Security Framework project ready!${NC}"
    echo "• Access: $JIRA_URL/projects/$PROJECT_KEY"
    echo "• Start creating user stories in Sprint 1"
    echo "• Based on validated community feedback from 43+ Moltbook comments"
    
else
    echo -e "${RED}❌ Failed to create project${NC}"
    echo "Response:"
    echo "$RESPONSE" | jq '.'
    
    # Try to get more info about the error
    if echo "$RESPONSE" | jq -e '.errorMessages' >/dev/null 2>&1; then
        echo ""
        echo -e "${YELLOW}Error details:${NC}"
        echo "$RESPONSE" | jq -r '.errorMessages[]'
    fi
fi

echo ""
echo -e "${BLUE}📊 Next Steps:${NC}"
echo "1. Create user stories for Sprint 1 (skill-evaluator.sh, Docker templates)"
echo "2. Set up Sprint 1 with 1-week duration"  
echo "3. Begin implementation of Layer 0 static analysis tools"
echo "4. Deploy first community-usable security tool by end of sprint"