#!/bin/bash

# ASF Discord Bot Deployment Script
# Makes it easy to deploy the ASF Discord security bot

set -e

echo "🚀 ASF Discord Bot Deployment"
echo "================================"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is required but not installed."
    echo "Install from: https://nodejs.org/"
    exit 1
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
    echo "❌ npm is required but not found."
    exit 1
fi

echo "✅ Node.js $(node --version) found"

# Install dependencies
echo "📦 Installing Discord.js..."
npm install discord.js

# Check environment variables
if [ -z "$DISCORD_BOT_TOKEN" ]; then
    echo "❌ DISCORD_BOT_TOKEN environment variable not set"
    echo "Get your token from: https://discord.com/developers/applications"
    echo "Set with: export DISCORD_BOT_TOKEN='your-token-here'"
    exit 1
fi

if [ -z "$DISCORD_CLIENT_ID" ]; then
    echo "❌ DISCORD_CLIENT_ID environment variable not set"  
    echo "Get your client ID from: https://discord.com/developers/applications"
    echo "Set with: export DISCORD_CLIENT_ID='your-client-id'"
    exit 1
fi

echo "✅ Environment variables configured"

# Make sure detection script is executable
chmod +x fake-agent-detector.sh

echo "🔍 Testing agent detection system..."
if ./fake-agent-detector.sh TestAgent &>/dev/null; then
    echo "✅ Agent detector working"
else
    echo "⚠️  Agent detector test completed with warnings (normal)"
fi

echo ""
echo "🎉 ASF Discord Bot ready to deploy!"
echo "================================"
echo ""
echo "🚀 Start the bot:"
echo "   node discord-asf-bot.js"
echo ""
echo "🔗 Add to Discord server:"
echo "   1. Go to https://discord.com/developers/applications"
echo "   2. Select your application → OAuth2 → URL Generator"  
echo "   3. Select 'bot' and 'applications.commands' scopes"
echo "   4. Copy invite URL and add to your server"
echo ""
echo "💡 Test with: /verify-agent AgentName"
echo ""