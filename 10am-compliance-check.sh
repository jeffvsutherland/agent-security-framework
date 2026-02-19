#!/bin/bash
# 10 AM Final Compliance Check

TIME="10:00 AM"
GROUP_CHAT_ID="-1003887253177"

MESSAGE="⏰ *10:00 AM FINAL COMPLIANCE CHECK*

**Manual Forwarding Status:**
✅ Sales Agent - Message delivered
⏳ Deploy Agent - Status unknown
⏳ Research Agent - Status unknown
⏳ Social Agent - Status unknown

**Required Evidence:**
1. Story in 'In Progress' on Jira
2. Update comment posted
3. Acknowledgment of protocol

**Non-compliant agents face immediate escalation.**

Checking Jira now: https://frequencyfoundation.atlassian.net

*The protocol is not optional. Every agent works ALL THE TIME.*"

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$GROUP_CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "10 AM compliance check sent!"