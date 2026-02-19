#!/bin/bash
# Hourly status check - Send compliance report to Jeff

HOUR=$(date +"%I %p")
DATE=$(date +"%B %d, %Y")

MESSAGE="⏰ *Hourly Status Check - $HOUR*

*Protocol Compliance Check:*
Please verify each agent is:
1. Working on their assigned story
2. Posting hourly Jira updates
3. Following the 6-step protocol

*Expected Status:*
- Jeff: ASF-23 (Mission Control)
- Sales: ASF-26 (Website) 
- Deploy: ASF-28 (Security Policies)
- Research: ASF-29 (Competitive Analysis)
- Social: ASF-33 (Social Campaign)

*If agents are idle or not updating:*
Please remind them of protocol violation

*Next check: 1 hour*"

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=1510884737" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Hourly status check sent at $HOUR on $DATE"