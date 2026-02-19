#!/bin/bash
# Enforce protocol on all agents once we have chat IDs

echo "🚨 PROTOCOL ENFORCEMENT - ALL AGENTS"
echo "==================================="

# Check if we have chat IDs as arguments
if [ "$#" -ne 4 ]; then
    echo "Usage: ./enforce-protocol-all.sh SALES_ID DEPLOY_ID RESEARCH_ID SOCIAL_ID"
    echo "Example: ./enforce-protocol-all.sh 12345 67890 11111 22222"
    exit 1
fi

SALES_CHAT_ID=$1
DEPLOY_CHAT_ID=$2
RESEARCH_CHAT_ID=$3
SOCIAL_CHAT_ID=$4

echo "Sending protocol enforcement to all agents..."
echo ""

# Send to Sales Agent
echo "📨 Messaging Sales Agent (Chat ID: $SALES_CHAT_ID)..."
./protocol-message-sales.sh "$SALES_CHAT_ID"
sleep 2

# Send to Deploy Agent
echo "📨 Messaging Deploy Agent (Chat ID: $DEPLOY_CHAT_ID)..."
./protocol-message-deploy.sh "$DEPLOY_CHAT_ID"
sleep 2

# Send to Research Agent
echo "📨 Messaging Research Agent (Chat ID: $RESEARCH_CHAT_ID)..."
./protocol-message-research.sh "$RESEARCH_CHAT_ID"
sleep 2

# Send to Social Agent
echo "📨 Messaging Social Agent (Chat ID: $SOCIAL_CHAT_ID)..."
./protocol-message-social.sh "$SOCIAL_CHAT_ID"
sleep 2

echo ""
echo "✅ Protocol enforcement sent to all agents!"
echo ""
echo "Expected actions within 30 minutes:"
echo "- All agents pull stories into 'In Progress'"
echo "- First Jira updates posted"
echo "- Protocol added to SOUL.md files"
echo ""
echo "Monitor compliance at: https://frequencyfoundation.atlassian.net"