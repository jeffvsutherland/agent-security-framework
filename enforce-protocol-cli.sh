#!/bin/bash
# Enforce protocol on all agents using OpenClaw CLI

echo "🚨 ENFORCING PROTOCOL VIA OPENCLAW CLI"
echo "======================================"
echo ""

# Sales Agent
echo "📨 Messaging Sales Agent..."
node /app/openclaw.mjs message send --channel telegram --account sales --target 1510884737 \
    --message "PROTOCOL ENFORCEMENT: Update ASF-26 Website in Jira NOW. Add hourly updates. No more idle time."
sleep 1

# Deploy Agent  
echo "📨 Messaging Deploy Agent..."
node /app/openclaw.mjs message send --channel telegram --account deploy --target 1510884737 \
    --message "PROTOCOL ENFORCEMENT: Take ASF-28 Security Policies or help with ASF-23. Update Jira hourly."
sleep 1

# Research Agent
echo "📨 Messaging Research Agent..."
node /app/openclaw.mjs message send --channel telegram --account research --target 1510884737 \
    --message "PROTOCOL ENFORCEMENT: Start ASF-29 Competitive Analysis. Post findings to Jira every hour."
sleep 1

# Social Agent
echo "📨 Messaging Social Agent..."
node /app/openclaw.mjs message send --channel telegram --account social --target 1510884737 \
    --message "PROTOCOL ENFORCEMENT: Create ASF-33 content. Announce 90/100 security score. Update Jira."
sleep 1

echo ""
echo "✅ Protocol enforcement complete via CLI!"
echo "All agents messaged directly through their accounts."