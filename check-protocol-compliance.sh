#!/bin/bash
# Check if agents are following protocol after enforcement

echo "🔍 PROTOCOL COMPLIANCE CHECK"
echo "============================"
echo ""

# Check current time
CURRENT_TIME=$(date +"%I:%M %p")
echo "Check time: $CURRENT_TIME"
echo ""

# Expected state after protocol enforcement
echo "📋 Expected Status:"
echo "- ASF-23: In Progress (Jeff)"
echo "- ASF-26: In Progress (Sales)"
echo "- ASF-28: In Progress (Deploy)"
echo "- ASF-29: In Progress (Research)"
echo "- ASF-33: In Progress (Social)"
echo ""

echo "⏰ Checking Jira for updates..."
echo "(Manual check required at: https://frequencyfoundation.atlassian.net)"
echo ""

# Send status request to Jeff
MESSAGE="🔍 *30-Minute Protocol Compliance Check*

Time: $CURRENT_TIME

*Please check Jira for:*
1. Are all stories in 'In Progress'?
2. Have agents posted updates?
3. Is anyone still idle?

*Expected:*
✅ ASF-26 (Sales) - In Progress with update
✅ ASF-28 (Deploy) - In Progress or helping ASF-23
✅ ASF-29 (Research) - In Progress with findings
✅ ASF-33 (Social) - In Progress with drafts

*If non-compliant:*
Escalate immediately. Protocol is mandatory.

*Goal: 100% compliance, zero idle agents*"

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=1510884737" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo ""
echo "✅ Compliance check sent!"