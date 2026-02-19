#!/bin/bash
# Send protocol compliance check to ASF Group

TIME=$(date +"%I:%M %p")
GROUP_CHAT_ID="-1003887253177"

MESSAGE="🔍 *Hourly Protocol Compliance Check - $TIME*

*Expected Status:*
✅ ASF-23: In Progress with updates (@jeffsutherlandbot)
⏳ ASF-26: In Progress with updates (Sales)
⏳ ASF-28: In Progress or helping ASF-23 (Deploy)
⏳ ASF-29: In Progress with findings (Research)
⏳ ASF-33: In Progress with content (Social)

*Check Your Jira Story NOW:*
- Is it in Progress?
- Did you post an hourly update?
- Are you actively working?

*If NOT compliant:*
Fix it immediately. Protocol violations = entropy.

Next check in 60 minutes.
_Every agent works on a story ALL THE TIME_"

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$GROUP_CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Protocol compliance check sent to ASF Group at $TIME"