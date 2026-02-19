#!/bin/bash
# Send message to ASF Group where all agents can see

MESSAGE="$1"
GROUP_CHAT_ID="-1003887253177"  # ASF Group upgraded to supergroup

if [ -z "$MESSAGE" ]; then
    echo "Usage: ./send-to-asf-group.sh 'Your message here'"
    exit 1
fi

# Send to ASF Group using my bot token
curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$GROUP_CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Message sent to ASF Group!"