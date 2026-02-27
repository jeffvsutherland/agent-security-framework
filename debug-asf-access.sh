#!/bin/bash

# Debug ASF project access with enhanced error reporting
source ~/.jira-config

echo "🔍 ASF Project Access Debug"
echo "=========================="
echo "URL: $JIRA_URL"
echo "User: $JIRA_USER"
echo "Project Key: ASF"
echo ""

# Test 1: Basic authentication
echo "1. Testing basic auth..."
auth_test=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/myself" \
    -H "Accept: application/json")

auth_code="${auth_test: -3}"
if [[ "$auth_code" == "200" ]]; then
    echo "   ✅ Authentication successful"
else
    echo "   ❌ Authentication failed (HTTP $auth_code)"
    exit 1
fi

# Test 2: List all projects
echo ""
echo "2. Listing all accessible projects..."
projects_response=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/project" \
    -H "Accept: application/json")

projects_code="${projects_response: -3}"
projects_body="${projects_response%???}"

if [[ "$projects_code" == "200" ]]; then
    echo "   ✅ Projects API accessible"
    if [[ "$projects_body" == "[]" ]]; then
        echo "   ⚠️  No projects returned (permissions issue?)"
    else
        echo "   Available projects:"
        echo "$projects_body" | jq -r '.[] | "   • " + .key + " - " + .name' 2>/dev/null || echo "   • Found projects but couldn't parse"
    fi
else
    echo "   ❌ Projects API failed (HTTP $projects_code)"
    echo "   Response: $projects_body"
fi

# Test 3: Direct ASF access
echo ""
echo "3. Testing direct ASF project access..."
asf_response=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/project/ASF" \
    -H "Accept: application/json")

asf_code="${asf_response: -3}"
asf_body="${asf_response%???}"

if [[ "$asf_code" == "200" ]]; then
    echo "   ✅ ASF project accessible"
    project_name=$(echo "$asf_body" | jq -r '.name // "Unknown"')
    echo "   Project: $project_name"
else
    echo "   ❌ ASF project not accessible (HTTP $asf_code)"
    echo "   Response: $asf_body"
fi

# Test 4: Check issue types in ASF
if [[ "$asf_code" == "200" ]]; then
    echo ""
    echo "4. Checking available issue types in ASF..."
    issue_types=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
        "$JIRA_URL/rest/api/2/issue/createmeta?projectKeys=ASF" \
        -H "Accept: application/json")
    
    if echo "$issue_types" | jq -e '.projects[0].issuetypes' >/dev/null 2>&1; then
        echo "   Available issue types:"
        echo "$issue_types" | jq -r '.projects[0].issuetypes[] | "   • " + .name' 2>/dev/null
    else
        echo "   ❌ Couldn't fetch issue types"
    fi
fi

# Test 5: Try creating a simple test issue
if [[ "$asf_code" == "200" ]]; then
    echo ""
    echo "5. Testing issue creation (test story)..."
    
    test_data='{
      "fields": {
        "project": {"key": "ASF"},
        "summary": "Test Story - DELETE ME",
        "description": "This is a test story to verify API access. Please delete.",
        "issuetype": {"name": "Story"}
      }
    }'
    
    create_response=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
      -X POST \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d "$test_data" \
      "$JIRA_URL/rest/api/2/issue")
      
    create_code="${create_response: -3}"
    create_body="${create_response%???}"
    
    if [[ "$create_code" == "201" ]]; then
        test_key=$(echo "$create_body" | jq -r '.key')
        echo "   ✅ Test issue created: $test_key"
        echo "   🎉 API access is working! Ready to populate stories."
    else
        echo "   ❌ Test issue creation failed (HTTP $create_code)"
        echo "   Response: $create_body"
        
        if [[ "$create_code" == "400" ]]; then
            echo ""
            echo "   Common fixes:"
            echo "   • Check 'Story' issue type exists in ASF project"
            echo "   • Verify required fields are configured correctly"
            echo "   • Ensure you have 'Create Issues' permission"
        fi
    fi
fi