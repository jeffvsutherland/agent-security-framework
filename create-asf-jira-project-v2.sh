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

echo -e "${BLUE}🛡️ Creating Agent Security Framework (ASF) Project${NC}"
echo "=================================================="
echo ""

# First, let's check existing projects
echo -e "${YELLOW}📋 Checking existing projects...${NC}"
EXISTING_PROJECTS=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/project" \
    -H "Accept: application/json")

if echo "$EXISTING_PROJECTS" | jq -e '.[0]' >/dev/null 2>&1; then
    echo "Existing projects:"
    echo "$EXISTING_PROJECTS" | jq -r '.[] | "• " + .key + " - " + .name'
else
    echo "• No existing projects found (or permissions issue)"
fi
echo ""

# Check if ASF already exists
if echo "$EXISTING_PROJECTS" | jq -e '.[] | select(.key == "ASF")' >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  ASF project already exists!${NC}"
    PROJECT_URL=$(echo "$EXISTING_PROJECTS" | jq -r '.[] | select(.key == "ASF") | .self')
    echo "• URL: $JIRA_URL/projects/ASF"
    exit 0
fi

# Project creation payload for API v2
PROJECT_DATA='{
  "key": "ASF",
  "name": "Agent Security Framework",
  "description": "Building layered defense for agent skill security - from Docker isolation to economic accountability. Based on community-validated architecture from Moltbook security proposals.",
  "projectTypeKey": "software",
  "lead": "'$JIRA_USER'"
}'

echo -e "${YELLOW}📋 Creating project with details:${NC}"
echo "• Key: ASF"
echo "• Name: Agent Security Framework" 
echo "• Type: Software"
echo "• Lead: $JIRA_USER"
echo ""

# Create the project using API v2
echo -e "${BLUE}🚀 Creating project...${NC}"
RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$PROJECT_DATA" \
  "$JIRA_URL/rest/api/2/project")

HTTP_CODE="${RESPONSE: -3}"
RESPONSE_BODY="${RESPONSE%???}"

# Check if creation was successful
if [[ "$HTTP_CODE" == "201" ]]; then
    PROJECT_KEY=$(echo "$RESPONSE_BODY" | jq -r '.key')
    PROJECT_ID=$(echo "$RESPONSE_BODY" | jq -r '.id')
    echo -e "${GREEN}✅ Project created successfully!${NC}"
    echo "• Project Key: $PROJECT_KEY"
    echo "• Project ID: $PROJECT_ID"
    echo "• URL: $JIRA_URL/projects/$PROJECT_KEY"
    echo ""
    
    # Wait a moment for project to be fully initialized
    sleep 2
    
    # Create initial user stories for Sprint 1
    echo -e "${BLUE}📝 Creating initial user stories for Sprint 1...${NC}"
    
    STORIES=(
        "Create skill-evaluator.sh script|As a security-conscious agent operator, I want a bash script that scans skills for credential access patterns, so I can quickly assess risk before installation.|Story"
        "Build Docker container templates|As a developer, I want Docker templates for common skill types, so I can run untrusted skills in isolated environments.|Story"
        "Design ASA vulnerability database|As a security researcher, I want an Agent Skill Advisory (ASA) database schema, so the community can track and coordinate responses to known vulnerabilities.|Story"
        "Document deployment guide|As a community member, I want clear documentation for using security tools, so I can implement agent skill security immediately.|Story"
        "Implement YARA rules for static analysis|As a security scanner, I want YARA rules that detect credential theft patterns, so malicious skills can be caught before execution.|Story"
    )
    
    for story in "${STORIES[@]}"; do
        IFS='|' read -r title description issuetype <<< "$story"
        
        STORY_DATA='{
          "fields": {
            "project": {"key": "'$PROJECT_KEY'"},
            "summary": "'$title'",
            "description": "'$description'",
            "issuetype": {"name": "'$issuetype'"}
          }
        }'
        
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
            echo "  ✅ Created story: $STORY_KEY - $title"
        else
            echo "  ❌ Failed to create story: $title (HTTP $STORY_HTTP_CODE)"
        fi
    done
    
    echo ""
    echo -e "${GREEN}🎉 Agent Security Framework project ready!${NC}"
    echo "• Access: $JIRA_URL/projects/$PROJECT_KEY"
    echo "• Sprint 1 stories created and ready for development"
    echo "• Based on validated community feedback from 43+ Moltbook comments"
    echo ""
    echo -e "${BLUE}📊 Immediate Next Steps:${NC}"
    echo "1. 🏃 Start Sprint 1 (1-week duration)"
    echo "2. 🛠️  Begin with skill-evaluator.sh script implementation"
    echo "3. 🐳 Create Docker templates for safe skill execution"
    echo "4. 📚 Write deployment documentation"
    echo "5. 🚀 Deploy first community-usable tool by end of sprint"
    
elif [[ "$HTTP_CODE" == "400" ]]; then
    echo -e "${RED}❌ Project creation failed (HTTP $HTTP_CODE)${NC}"
    echo "This usually means:"
    echo "• Project key 'ASF' might already exist"
    echo "• Invalid project configuration"
    echo ""
    echo "Response details:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    
elif [[ "$HTTP_CODE" == "401" || "$HTTP_CODE" == "403" ]]; then
    echo -e "${RED}❌ Authentication/Permission error (HTTP $HTTP_CODE)${NC}"
    echo "• Check that API token is valid"
    echo "• Verify user has project creation permissions"
    echo ""
    echo "Response: $RESPONSE_BODY"
    
else
    echo -e "${RED}❌ Unexpected error (HTTP $HTTP_CODE)${NC}"
    echo "Response:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
fi