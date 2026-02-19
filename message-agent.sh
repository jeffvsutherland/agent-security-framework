#!/bin/bash
# Send direct message to any agent via OpenClaw CLI

AGENT="$1"
MESSAGE="$2"
TARGET="${3:-1510884737}"  # Default to Jeff's chat ID

if [ -z "$AGENT" ] || [ -z "$MESSAGE" ]; then
    echo "Usage: ./message-agent.sh AGENT_ACCOUNT 'Your message' [TARGET_ID]"
    echo "Example: ./message-agent.sh sales 'Update ASF-26 now!'"
    echo ""
    echo "Available agents:"
    echo "  - main"
    echo "  - sales"
    echo "  - deploy"
    echo "  - research"
    echo "  - social"
    echo "  - product-owner"
    exit 1
fi

echo "Sending message to $AGENT..."
node /app/openclaw.mjs message send \
    --channel telegram \
    --account "$AGENT" \
    --target "$TARGET" \
    --message "$MESSAGE"

echo "Message sent via $AGENT bot!"