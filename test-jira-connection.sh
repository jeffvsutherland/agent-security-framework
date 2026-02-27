#!/bin/bash

# Test Jira connection using curl
source ~/.jira-config

echo "🧪 Testing Jira Connection..."
echo "URL: $JIRA_URL"
echo "User: $JIRA_USER" 
echo "Project: FF"
echo ""

# Test basic API connectivity
echo "📡 Testing API connection..."
response=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/project/FF" \
    -H "Accept: application/json")

http_code="${response: -3}"
response_body="${response%???}"

if [[ "$http_code" == "200" ]]; then
    echo "✅ Connection successful!"
    echo "Project details:"
    echo "$response_body" | jq -r '.name // "Name not found"' 2>/dev/null || echo "FF Project found"
    echo ""
    
    # Test issues query
    echo "📋 Testing issues query..."
    issues_response=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
        "$JIRA_URL/rest/api/2/search?jql=project=FF&maxResults=5" \
        -H "Accept: application/json")
    
    issue_count=$(echo "$issues_response" | jq -r '.total // 0' 2>/dev/null || echo "0")
    echo "Found $issue_count issues in FF project"
    
    if [[ "$issue_count" -gt 0 ]]; then
        echo ""
        echo "Recent issues:"
        echo "$issues_response" | jq -r '.issues[]? | "• " + .key + ": " + .fields.summary' 2>/dev/null | head -5 || echo "Issues found but couldn't parse details"
    fi
    
else
    echo "❌ Connection failed (HTTP $http_code)"
    echo "Response: $response_body"
    echo ""
    echo "Common issues:"
    echo "• Check API token is valid"
    echo "• Verify project key 'FF' exists"
    echo "• Ensure user has access to project"
fi