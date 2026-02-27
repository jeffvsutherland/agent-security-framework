#!/bin/bash

# Advanced: Send Today's JVS Management Note to IRS Audit Gem via Clawdbot
# This version uses Clawdbot's browser automation for full automation

# Configuration
GEMINI_GEM_URL="YOUR_IRS_AUDIT_GEM_URL_HERE"
TODAY=$(date +"%Y%m%d")
NOTE_TITLE="${TODAY} JVS Management"

echo "🤖 Clawdbot: Automated IRS Gem Submission"
echo "📅 Date: $TODAY"
echo "📝 Note: $NOTE_TITLE"
echo ""

# Check if Clawdbot is available
if ! command -v clawdbot &> /dev/null; then
    echo "❌ Clawdbot not found in PATH"
    exit 1
fi

# Get note content via Clawdbot
echo "🔍 Retrieving note content..."

# Create a temporary Clawdbot command to get the note and send to Gem
COMMAND="Get today's JVS Management note titled '$NOTE_TITLE' and send it to the IRS Audit Gemini Gem at $GEMINI_GEM_URL. Format the content properly for Gemini processing and automate the browser interaction to paste it into the Gem's chat interface."

echo "📤 Sending command to Clawdbot..."
echo "Command: $COMMAND"

# This would typically be done via the API or CLI if available
echo ""
echo "⚠️  Manual setup required:"
echo "1. Set GEMINI_GEM_URL to your actual Gem URL"
echo "2. Run this command with Clawdbot:"
echo ""
echo "\"$COMMAND\""
echo ""

# For now, fall back to the basic version
exec ./send-to-irs-gem.sh