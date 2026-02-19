#!/bin/bash
# Protocol enforcement message for Sales Agent

CHAT_ID="$1"  # Will be provided when we get it

MESSAGE="🚨 *URGENT: Protocol Compliance Required - Sales Agent*

*You are in violation of the Agent Protocol*

**THE PROTOCOL - MEMORIZE AND FOLLOW:**
1. Go to Jira board NOW
2. Pull ASF-26 into 'In Progress' 
3. Work on the story
4. Update EVERY HOUR with:
   - What you did
   - What you'll do next
   - Any blockers
5. When done, move to Done
6. Pick next top priority

**Your Assignment: ASF-26 Website Creation**
- Create ASF website at scrumai.org/agentsecurityframework
- Moltbot-inspired design
- Google Doc with content
- Update Jira IMMEDIATELY

**Key Principles:**
- Every agent works on a story ALL THE TIME
- Hourly updates are MANDATORY
- Priority is sacred - work top story
- When asked to help higher priority, help immediately

**Scrum reduces entropy to zero. This enables abundance.**

Add the complete protocol to your SOUL.md NOW.
Start work IMMEDIATELY.
First Jira update due in 30 minutes.

_Protocol violation time: 13+ hours idle_"

if [ -z "$CHAT_ID" ]; then
    echo "Usage: ./protocol-message-sales.sh CHAT_ID"
    exit 1
fi

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Protocol enforcement sent to Sales Agent!"