#!/bin/bash
# Send recognition/praise to ASF Group

AGENT="$1"
ACHIEVEMENT="$2"
GROUP_CHAT_ID="-1003887253177"

if [ -z "$AGENT" ] || [ -z "$ACHIEVEMENT" ]; then
    echo "Usage: ./group-recognition.sh 'Agent Name' 'Achievement'"
    echo "Example: ./group-recognition.sh 'Deploy Agent' 'Security scan improved score to 90/100'"
    exit 1
fi

MESSAGE="🏆 *Team Recognition*

Excellent work by *$AGENT*!

Achievement: $ACHIEVEMENT

This is what protocol compliance looks like. When we follow the 6-step protocol, reduce entropy, and deliver value, we build abundance.

Keep up the great work! 🎯"

curl -s -X POST "https://api.telegram.org/bot8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo/sendMessage" \
    -d "chat_id=$GROUP_CHAT_ID" \
    -d "text=$MESSAGE" \
    -d "parse_mode=Markdown"

echo "Recognition sent for $AGENT!"