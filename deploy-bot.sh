#!/bin/bash

# ASF Discord Bot - THE ONE THING Deployment
# Working software > Documentation

echo "🎯 ASF Discord Bot - THE ONE THING Deployment"
echo "============================================="
echo "📦 Working software > Documentation"
echo "👥 Community value > Revenue projections"
echo "🚢 Ship daily > Plan weekly"
echo ""

# Check if we have Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 16+ first."
    exit 1
fi

echo "✅ Node.js found: $(node --version)"

# Check if we have fake-agent-detector.sh
if [ ! -f "./fake-agent-detector.sh" ]; then
    echo "❌ fake-agent-detector.sh not found in current directory"
    echo "   This bot requires the ASF detector script to work"
    exit 1
fi

echo "✅ fake-agent-detector.sh found"

# Make detector executable
chmod +x ./fake-agent-detector.sh

# Install dependencies
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ Failed to install dependencies"
        exit 1
    fi
    echo "✅ Dependencies installed"
else
    echo "✅ Dependencies already installed"
fi

# Check environment variables
if [ -z "$DISCORD_BOT_TOKEN" ] || [ -z "$DISCORD_CLIENT_ID" ]; then
    echo ""
    echo "⚠️  SETUP REQUIRED: Discord Bot Configuration"
    echo "============================================="
    echo ""
    echo "You need to:"
    echo "1. Go to https://discord.com/developers/applications"
    echo "2. Create a new application"
    echo "3. Go to 'Bot' section and create a bot"
    echo "4. Copy the bot token"
    echo "5. Copy the application ID (from General Information)"
    echo ""
    echo "Then set these environment variables:"
    echo "export DISCORD_BOT_TOKEN='your-bot-token-here'"
    echo "export DISCORD_CLIENT_ID='your-application-id-here'"
    echo ""
    echo "Or create a .env file with:"
    echo "DISCORD_BOT_TOKEN=your-bot-token-here"
    echo "DISCORD_CLIENT_ID=your-application-id-here"
    echo ""
    echo "Bot permissions needed:"
    echo "• Send Messages"
    echo "• Use Slash Commands"
    echo "• Read Message History"
    echo ""
    
    if [ -f ".env" ]; then
        echo "📄 Found .env file, sourcing it..."
        source .env
    fi
    
    if [ -z "$DISCORD_BOT_TOKEN" ] || [ -z "$DISCORD_CLIENT_ID" ]; then
        echo "❌ Still missing environment variables. Please set them and try again."
        exit 1
    fi
fi

echo "✅ Discord configuration found"
echo ""

# Test the detector script
echo "🧪 Testing fake-agent-detector.sh..."
./fake-agent-detector.sh TestAgent --json > /tmp/asf-test.json 2>/dev/null
if [ $? -eq 0 ] && [ -s /tmp/asf-test.json ]; then
    echo "✅ Detector script working"
    rm -f /tmp/asf-test.json
else
    echo "⚠️  Detector script test failed, but continuing..."
    echo "   The bot will handle errors gracefully"
fi

echo ""
echo "🚀 Starting ASF Discord Bot..."
echo "================================"
echo "Commands available:"
echo "• /verify-agent <name> - Verify agent authenticity"  
echo "• /asf-help - Show help and usage"
echo ""
echo "Success metric: Get 5+ active users verifying agents"
echo "Press Ctrl+C to stop"
echo ""

# Start the bot
node discord-asf-bot.js