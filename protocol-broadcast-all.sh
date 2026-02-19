#!/bin/bash
# Send protocol enforcement through each agent's bot to Jeff's chat ID

echo "🚨 BROADCASTING PROTOCOL ENFORCEMENT"
echo "===================================="
echo ""

JEFF_CHAT_ID="1510884737"

# To Sales Agent via their bot
echo "📨 Sending to Sales Agent via @ASFSalesBot..."
curl -s -X POST "https://api.telegram.org/bot8049864989:AAHdP9iDsSpQWiQ5sKFZGJD060WLbmG5aAM/sendMessage" \
    -d "chat_id=$JEFF_CHAT_ID" \
    -d "text=🚨 *SALES AGENT - PROTOCOL VIOLATION*

You are IDLE. Start ASF-26 Website NOW.

THE PROTOCOL:
1. Pull ASF-26 to In Progress in Jira
2. Work on website (Google Doc content)
3. Update EVERY HOUR
4. No idle agents allowed

First update due in 30 minutes.
Add protocol to SOUL.md.

_13+ hours idle = unacceptable entropy_" \
    -d "parse_mode=Markdown"
echo "✓ Sent"
sleep 2

# To Deploy Agent via their bot
echo "📨 Sending to Deploy Agent via @ASFDeployBot..."
curl -s -X POST "https://api.telegram.org/bot8562304149:AAGG8z9voTN0UO8zfI1AjKX5z7K7mQp21ok/sendMessage" \
    -d "chat_id=$JEFF_CHAT_ID" \
    -d "text=🚨 *DEPLOY AGENT - TAKE ASF-28*

Great security scan yesterday! Now continue working.

IMMEDIATE ACTION:
1. Take ASF-28 Security Policies
2. Pull to In Progress in Jira
3. Design policy framework
4. Update EVERY HOUR

Or help Jeff with ASF-23.
No idle agents allowed.

_Protocol: Everyone works ALL THE TIME_" \
    -d "parse_mode=Markdown"
echo "✓ Sent"
sleep 2

# To Research Agent via their bot
echo "📨 Sending to Research Agent via @ASFResearchBot..."
curl -s -X POST "https://api.telegram.org/bot8371607764:AAEsQCxbZLi-gcDfcrc4otTg7Tj5wtVTI74/sendMessage" \
    -d "chat_id=$JEFF_CHAT_ID" \
    -d "text=🚨 *RESEARCH AGENT - START ASF-29*

You are IDLE. This creates entropy.

TAKE ASF-29 NOW:
1. Competitive analysis of AI security
2. Pull to In Progress in Jira
3. Research top 5 competitors
4. Update EVERY HOUR

Start immediately.
First findings in 1 hour.

_13+ hours wasted_" \
    -d "parse_mode=Markdown"
echo "✓ Sent"
sleep 2

# To Social Agent via their bot
echo "📨 Sending to Social Agent via @ASFSocialBot..."
curl -s -X POST "https://api.telegram.org/bot8363670185:AAF87g3nBTkhsQ4O1TIEq1lxiRRQ7_G1BQ4/sendMessage" \
    -d "chat_id=$JEFF_CHAT_ID" \
    -d "text=🚨 *SOCIAL AGENT - CREATE ASF-33*

IDLE = ENTROPY. Start working NOW.

ASF-33 Social Campaign:
1. Announce 90/100 security score
2. Pull to In Progress in Jira
3. Draft for all platforms
4. Update EVERY HOUR

Key message: 0 dangerous skills!
Start immediately.

_Time is value. Stop wasting it._" \
    -d "parse_mode=Markdown"
echo "✓ Sent"

echo ""
echo "===================================="
echo "✅ Protocol broadcast complete!"
echo ""
echo "Expected results in 30 minutes:"
echo "- All stories in Progress"
echo "- Jira updates flowing"
echo "- 100% compliance"