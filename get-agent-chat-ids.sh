#!/bin/bash
# Check each bot for updates to find agent chat IDs

echo "🔍 Checking for Agent Chat IDs..."
echo "================================="
echo ""

# Sales Bot
echo "📱 Checking Sales Bot (@ASFSalesBot)..."
SALES_UPDATES=$(curl -s "https://api.telegram.org/bot8049864989:AAHdP9iDsSpQWiQ5sKFZGJD060WLbmG5aAM/getUpdates")
echo "$SALES_UPDATES" | jq -r '.result[] | "Chat ID: \(.message.chat.id) - From: \(.message.from.first_name) \(.message.from.username)"' | sort -u | head -5
echo ""

# Deploy Bot
echo "📱 Checking Deploy Bot (@ASFDeployBot)..."
DEPLOY_UPDATES=$(curl -s "https://api.telegram.org/bot8562304149:AAGG8z9voTN0UO8zfI1AjKX5z7K7mQp21ok/getUpdates")
echo "$DEPLOY_UPDATES" | jq -r '.result[] | "Chat ID: \(.message.chat.id) - From: \(.message.from.first_name) \(.message.from.username)"' | sort -u | head -5
echo ""

# Research Bot
echo "📱 Checking Research Bot (@ASFResearchBot)..."
RESEARCH_UPDATES=$(curl -s "https://api.telegram.org/bot8371607764:AAEsQCxbZLi-gcDfcrc4otTg7Tj5wtVTI74/getUpdates")
echo "$RESEARCH_UPDATES" | jq -r '.result[] | "Chat ID: \(.message.chat.id) - From: \(.message.from.first_name) \(.message.from.username)"' | sort -u | head -5
echo ""

# Social Bot
echo "📱 Checking Social Bot (@ASFSocialBot)..."
SOCIAL_UPDATES=$(curl -s "https://api.telegram.org/bot8363670185:AAF87g3nBTkhsQ4O1TIEq1lxiRRQ7_G1BQ4/getUpdates")
echo "$SOCIAL_UPDATES" | jq -r '.result[] | "Chat ID: \(.message.chat.id) - From: \(.message.from.first_name) \(.message.from.username)"' | sort -u | head -5
echo ""

echo "================================="
echo "If chat IDs found above, use them to message agents!"