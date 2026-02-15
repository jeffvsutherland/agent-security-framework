#!/bin/bash

# Script to securely share Jira API token with all ASF agents

echo "🔐 Sharing Jira API Token with ASF Agents"
echo "=========================================="

# Check if token exists
if [ -z "$JIRA_API_TOKEN" ]; then
    echo "❌ ERROR: JIRA_API_TOKEN not found in environment"
    echo "Please set it first: export JIRA_API_TOKEN='your-token'"
    exit 1
fi

# Agents to configure
agents=("deploy" "research" "sales" "social" "product-owner")

echo "📝 Creating secure token file..."

# Create a secure token file that agents can source
cat > ./.jira-token-export << EOF
# ASF Team Jira API Token
# Source this file to access Jira API
# DO NOT COMMIT THIS FILE TO GIT

export JIRA_API_TOKEN='$JIRA_API_TOKEN'
export JIRA_URL='https://frequencyfoundation.atlassian.net'
export JIRA_USER='jeff.sutherland@gmail.com'
export JIRA_PROJECT='ASF'

echo "✅ Jira API token loaded for ASF project"
EOF

# Set restrictive permissions
chmod 600 ./.jira-token-export

echo "✅ Token file created: .jira-token-export"
echo ""

# Add to .gitignore if not already there
if ! grep -q "\.jira-token-export" .gitignore 2>/dev/null; then
    echo ".jira-token-export" >> .gitignore
    echo "✅ Added to .gitignore"
fi

echo ""
echo "📋 Instructions for each agent:"
echo "================================"
echo ""
echo "1. In each agent's workspace, run:"
echo "   source /Users/jeffsutherland/clawd/.jira-token-export"
echo ""
echo "2. Then source the automation functions:"
echo "   source /Users/jeffsutherland/clawd/jira-automation.sh"
echo ""
echo "3. Test with:"
echo "   jira_list_stories"
echo ""
echo "⚠️  SECURITY REMINDER:"
echo "- Never commit .jira-token-export to git"
echo "- Each agent should protect their token"
echo "- Revoke and regenerate tokens periodically"
echo ""
echo "🚀 Ready to automate Jira access for all agents!"