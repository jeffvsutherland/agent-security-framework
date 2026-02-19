#!/bin/bash
# Protocol enforcement message for Deploy Agent

CHAT_ID="$1"  # Will be provided when we get it

MESSAGE="🚨 *URGENT: Protocol Compliance Required - Deploy Agent*

*You completed excellent security work yesterday. Now continue with the protocol.*

**THE PROTOCOL - MEMORIZE AND FOLLOW:**
1. Go to Jira board NOW
2. Pull ASF-28 into 'In Progress' 
3. Work on the story
4. Update EVERY HOUR with:
   - What you did
   - What you'll do next
   - Any blockers
5. When done, move to Done
6. Pick next top priority

**Your Assignment: ASF-28 Security Policies**
- Design comprehensive security policies for ASF
- Create policy templates
- Implement audit logging specs
- Add compliance frameworks (SOC2, HIPAA)

**Alternative: Help Jeff with ASF-23 Mission Control infrastructure**

**Key Principles:**
- Every agent works on a story ALL THE TIME
- No idle agents - this creates entropy
- Hourly updates are MANDATORY
- Help higher priority work when asked

**Your security scan proved 90/100 score. Now build on that success!**

Add the complete protocol to your SOUL.md NOW.
Pick your story (ASF-28 or help with ASF-23).
First Jira update due in 30 minutes.

_Current status: IDLE (protocol violation)_"

if [ -z "$CHAT_ID" ]; then
    echo "Usage: ./protocol-message-deploy.sh CHAT_ID"
    exit 1
fi

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Protocol enforcement sent to Deploy Agent!"