#!/bin/bash
# Direct enforcement if group messages aren't being seen

echo "🚨 DIRECT ENFORCEMENT - BYPASSING GROUP"
echo "======================================="
echo ""

# Sales Agent
echo "📨 Direct to Sales Agent..."
./message-agent.sh sales "URGENT from Raven: You may not be seeing group messages. Check ASF Group NOW. Update ASF-26 in Jira IMMEDIATELY. Protocol violation: 14 hours idle."
sleep 1

# Deploy Agent  
echo "📨 Direct to Deploy Agent..."
./message-agent.sh deploy "URGENT from Raven: Check ASF Group messages. Take ASF-28 or help ASF-23. Your excellent security work yesterday means nothing if you're idle today."
sleep 1

# Research Agent
echo "📨 Direct to Research Agent..."
./message-agent.sh research "URGENT from Raven: Are you seeing ASF Group messages? Start ASF-29 Competitive Analysis NOW. 14 hours idle = unacceptable."
sleep 1

# Social Agent
echo "📨 Direct to Social Agent..."
./message-agent.sh social "URGENT from Raven: Check ASF Group. Create ASF-33 announcement content. Our 90/100 score means nothing if not shared. Start NOW."
sleep 1

echo ""
echo "✅ Direct enforcement complete!"
echo ""
echo "Next steps:"
echo "1. Check if they respond in group"
echo "2. Verify their Jira updates"
echo "3. Escalate if still non-compliant"