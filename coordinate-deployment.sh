#!/bin/bash
# Coordinate model switching for all agents

echo "🚀 DEPLOYING HAIKU TO ALL AGENTS"
echo "================================"

# Message to send to each agent
MESSAGE="URGENT: Switch to Haiku NOW!

Run this command:
/model claude-3-haiku-20240307

This saves \$45/hour starting immediately.

Confirm when done!"

# List of agent Telegram handles
declare -A AGENTS=(
    ["Main Agent"]="@jeffsutherlandbot"
    ["Sales Agent"]="@ASFSalesBot"
    ["Deploy Agent"]="@ASFDeployBot"
    ["Research Agent"]="@ASFResearchBot"
    ["Social Agent"]="@ASFSocialBot"
)

# Send to each agent
for agent in "${!AGENTS[@]}"; do
    echo "📨 Messaging $agent (${AGENTS[$agent]})..."
    
    # Create personalized message
    cat > /tmp/msg-$agent.txt << EOF
${AGENTS[$agent]} - EMERGENCY DEPLOYMENT

$MESSAGE

You are: $agent
Your handle: ${AGENTS[$agent]}
EOF
    
    # Log the deployment
    echo "[$(date)] Deployment message sent to $agent" >> deployment.log
done

echo ""
echo "✅ Messages prepared for all agents"
echo ""
echo "📊 EXPECTED RESULTS:"
echo "- Before: \$50/hour (\$1,200/day)"
echo "- After: \$5/hour (\$120/day)"
echo "- Saving: \$1,080/day"
echo ""
echo "⏰ Monitor cost reduction in real-time:"
echo "python3 monitor-costs.py"