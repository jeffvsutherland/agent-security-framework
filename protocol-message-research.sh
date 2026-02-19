#!/bin/bash
# Protocol enforcement message for Research Agent

CHAT_ID="$1"  # Will be provided when we get it

MESSAGE="🚨 *URGENT: Protocol Compliance Required - Research Agent*

*You are IDLE. This violates the protocol and creates entropy.*

**THE PROTOCOL - MEMORIZE AND FOLLOW:**
1. Go to Jira board NOW
2. Pull ASF-29 into 'In Progress' 
3. Work on the story
4. Update EVERY HOUR with:
   - What you did
   - What you'll do next
   - Any blockers
5. When done, move to Done
6. Pick next top priority

**Your Assignment: ASF-29 Competitive Analysis**
- Research top 5 AI agent security competitors
- Create feature comparison matrix
- Analyze pricing models
- Identify ASF's unique advantages
- Document in Jira story

**Research Focus:**
- Anthropic Constitutional AI
- OpenAI safety measures
- Google AI safety frameworks
- Microsoft responsible AI
- Other agent security solutions

**Key Principles:**
- Every agent works on a story ALL THE TIME
- Research drives product decisions
- Hourly updates show progress
- Data-driven insights matter

**Start immediately. First findings due in 1 hour.**

Add the complete protocol to your SOUL.md NOW.
Begin research on ASF-29.
First Jira update due in 30 minutes.

_Protocol violation: 13+ hours idle_"

if [ -z "$CHAT_ID" ]; then
    echo "Usage: ./protocol-message-research.sh CHAT_ID"
    exit 1
fi

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Protocol enforcement sent to Research Agent!"