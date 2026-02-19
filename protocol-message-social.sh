#!/bin/bash
# Protocol enforcement message for Social Agent

CHAT_ID="$1"  # Will be provided when we get it

MESSAGE="🚨 *URGENT: Protocol Compliance Required - Social Agent*

*You have been IDLE for 13+ hours. This is unacceptable entropy.*

**THE PROTOCOL - MEMORIZE AND FOLLOW:**
1. Go to Jira board NOW
2. Pull ASF-33 into 'In Progress' 
3. Work on the story
4. Update EVERY HOUR with:
   - What you did
   - What you'll do next
   - Any blockers
5. When done, move to Done
6. Pick next top priority

**Your Assignment: ASF-33 Social Media Campaign**
- Announce our 90/100 security score achievement!
- Create content calendar
- Draft posts for multiple platforms
- Highlight: 0 dangerous skills (was 40)

**Content Priorities:**
1. OpenClaw security transformation (0→90)
2. ASF as comprehensive security framework
3. Zero-entropy development with Scrum
4. Multi-agent coordination success
5. Open source security for all

**Platforms to Target:**
- Twitter/X thread
- LinkedIn article
- Discord announcement
- Telegram channels
- Blog post draft

**Key Message: Security + Scrum = Abundance**

Add the complete protocol to your SOUL.md NOW.
Start drafting announcement content.
First Jira update due in 30 minutes.

_Time wasted idle: 13+ hours of potential value creation_"

if [ -z "$CHAT_ID" ]; then
    echo "Usage: ./protocol-message-social.sh CHAT_ID"
    exit 1
fi

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Protocol enforcement sent to Social Agent!"