#!/bin/bash

# Populate Agent Security Framework (ASF) Project with Sprint 1 Stories
# Run this after manually creating the ASF project

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

echo -e "${BLUE}📋 Populating ASF Project with User Stories${NC}"
echo "============================================="
echo ""

# Verify ASF project exists
echo -e "${YELLOW}🔍 Checking if ASF project exists...${NC}"
PROJECT_CHECK=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/project/ASF" \
    -H "Accept: application/json")

if echo "$PROJECT_CHECK" | jq -e '.key' >/dev/null 2>&1; then
    PROJECT_NAME=$(echo "$PROJECT_CHECK" | jq -r '.name')
    echo -e "${GREEN}✅ Found project: ASF - $PROJECT_NAME${NC}"
else
    echo -e "${RED}❌ ASF project not found!${NC}"
    echo "Please create the project manually first:"
    echo "1. Go to: $JIRA_URL"
    echo "2. Create project with key 'ASF'"
    echo "3. Then run this script"
    exit 1
fi

echo ""

# Sprint 1 User Stories - Based on community feedback
STORIES=(
    "Create skill-evaluator.sh script|As a security-conscious agent operator, I want a bash script that scans skills for credential access patterns (using grep and YARA rules), so I can quickly assess risk before installation. Acceptance: Script detects .env, .ssh, webhook.site patterns and outputs risk score.|Story|High"
    
    "Build Docker container templates|As a developer, I want Docker container templates for common skill types (Python, Node.js, bash), so I can run untrusted skills in isolated environments without host filesystem access. Acceptance: Templates block credential theft attempts.|Story|High"
    
    "Design ASA vulnerability database|As a security researcher, I want an Agent Skill Advisory (ASA) database schema (JSON/SQLite), so the community can track and coordinate responses to known vulnerabilities. Acceptance: CVE-style format with skill ID, vulnerability type, CVSS score.|Story|Medium"
    
    "Document deployment guide|As a community member, I want clear documentation (README + examples) for using security tools, so I can implement agent skill security immediately. Acceptance: 5-minute setup guide with working examples.|Story|Medium"
    
    "Implement YARA rules for static analysis|As a security scanner, I want YARA rules that detect credential theft patterns, obfuscated code, and suspicious network calls, so malicious skills can be caught before execution. Acceptance: Catches the known credential stealer from @Rufio.|Story|High"
    
    "Create community testing framework|As a security contributor, I want a testing framework where I can submit skill samples and get automated security analysis, so the community can validate the security tools work correctly. Acceptance: Web form + API endpoint.|Story|Low"
)

echo -e "${BLUE}📝 Creating Sprint 1 user stories...${NC}"

CREATED_COUNT=0
FAILED_COUNT=0

for story in "${STORIES[@]}"; do
    IFS='|' read -r title description issuetype priority <<< "$story"
    
    STORY_DATA='{
      "fields": {
        "project": {"key": "ASF"},
        "summary": "'$title'",
        "description": "'$description'",
        "issuetype": {"name": "'$issuetype'"},
        "priority": {"name": "'$priority'"}
      }
    }'
    
    echo "Creating: $title..."
    
    STORY_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
      -X POST \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d "$STORY_DATA" \
      "$JIRA_URL/rest/api/2/issue")
      
    STORY_HTTP_CODE="${STORY_RESPONSE: -3}"
    STORY_RESPONSE_BODY="${STORY_RESPONSE%???}"
      
    if [[ "$STORY_HTTP_CODE" == "201" ]]; then
        STORY_KEY=$(echo "$STORY_RESPONSE_BODY" | jq -r '.key')
        echo "  ✅ $STORY_KEY - $title"
        ((CREATED_COUNT++))
    else
        echo "  ❌ Failed (HTTP $STORY_HTTP_CODE) - $title"
        if [[ "$STORY_HTTP_CODE" == "400" ]]; then
            echo "     Error details:"
            echo "$STORY_RESPONSE_BODY" | jq -r '.errors // .errorMessages // "Unknown error"' | sed 's/^/     /'
        fi
        ((FAILED_COUNT++))
    fi
done

echo ""
echo -e "${GREEN}📊 Story Creation Complete!${NC}"
echo "• Created: $CREATED_COUNT stories"
echo "• Failed: $FAILED_COUNT stories"
echo ""

if [[ $CREATED_COUNT -gt 0 ]]; then
    echo -e "${BLUE}🚀 Next Steps:${NC}"
    echo "1. Go to: $JIRA_URL/projects/ASF"
    echo "2. Create Sprint 1 and add these stories"
    echo "3. Start with skill-evaluator.sh (highest priority)"
    echo "4. Deploy first working tool to community this week"
    echo ""
    echo -e "${YELLOW}💡 Community Validation:${NC}"
    echo "• Based on 43+ Moltbook security proposal comments"
    echo "• Addressing @promptomat's LLM security paradox"
    echo "• Implementing @DogJarvis's economic accountability"
    echo "• Supporting @Lobby_Eno's sovereignty constraints"
    
    # Try to get current sprint info
    echo ""
    echo -e "${BLUE}🏃 Sprint Setup:${NC}"
    echo "Consider 1-week sprints for 'agent-speed development'"
    echo "Success metric: Community members actively using the security tools"
fi