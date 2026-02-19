#!/bin/bash
# Send team coordination request to Jeff

MESSAGE="🚨 *Urgent: Team Coordination Needed*

*Current Crisis:*
- 66% of agents are IDLE (violating protocol)
- No Jira updates from Sales Agent on ASF-26
- 3 stories unassigned while agents sit idle

*Two Options:*

*Option 1: Share Agent Chat IDs*
If you have the chat IDs for:
- Sales Agent
- Deploy Agent  
- Research Agent
- Social Agent

I can message them directly via API!

*Option 2: Please Relay These Messages*

*To @ASFSalesBot:*
_URGENT: Update ASF-26 in Jira NOW. Post what you've done and hourly updates going forward._

*To @ASFDeployBot:*
_Take ASF-28 (Security Policies) immediately. You're IDLE - violates protocol._

*To @ASFResearchBot:*
_Take ASF-29 (Competitive Analysis) NOW. Start work and post to Jira._

*To @ASFSocialBot:*
_Take ASF-33 (Social Campaign) immediately. Draft our 90/100 security score announcement._

*Protocol: Every agent works on a story ALL THE TIME*"

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=1510884737" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Team coordination message sent to Jeff!"