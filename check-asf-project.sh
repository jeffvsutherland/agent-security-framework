#!/bin/bash

# Check for ASF project with various possible keys
source ~/.jira-config

echo "🔍 Checking for ASF project..."
echo "URL: $JIRA_URL"
echo ""

# Try different possible project keys
KEYS=("ASF" "AGENTSECURITY" "AGENTSECURITYFRAMEWORK" "AS")

for key in "${KEYS[@]}"; do
    echo "Trying key: $key"
    response=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
        "$JIRA_URL/rest/api/2/project/$key" \
        -H "Accept: application/json")
    
    http_code="${response: -3}"
    response_body="${response%???}"
    
    if [[ "$http_code" == "200" ]]; then
        echo "✅ Found project with key: $key"
        project_name=$(echo "$response_body" | jq -r '.name // "Unknown"')
        echo "   Name: $project_name"
        echo "   URL: $JIRA_URL/projects/$key"
        echo ""
        
        # Update our population script with the correct key
        sed -i '' "s/ASF/$key/g" asf-populate-stories.sh
        echo "Updated story population script with correct key: $key"
        break
    else
        echo "❌ Not found with key: $key (HTTP $http_code)"
    fi
done

# Also try to list all available projects
echo ""
echo "📋 Attempting to list all projects..."
all_projects=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/project" \
    -H "Accept: application/json")

if [[ "$all_projects" != "[]" && "$all_projects" != "" ]]; then
    echo "Available projects:"
    echo "$all_projects" | jq -r '.[] | "• " + .key + " - " + .name'
else
    echo "No projects found or permission issue"
    echo "Raw response: $all_projects"
fi