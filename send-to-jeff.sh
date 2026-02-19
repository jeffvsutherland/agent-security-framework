#!/bin/bash
# send-to-jeff.sh - Send a message to Dr. Sutherland via Telegram

MESSAGE="$1"

if [ -z "$MESSAGE" ]; then
    echo "Usage: ./send-to-jeff.sh 'Your message here'"
    exit 1
fi

# Using my bot token to send to Jeff
curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=1510884737" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Message sent to Jeff!"