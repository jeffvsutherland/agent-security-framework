#!/bin/bash
# Post to Moltbook using API
# Usage: ./moltbook-post.sh "Title" "Content"

API_KEY=$(cat ~/.config/moltbook/credentials.json | python3 -c "import sys, json; print(json.load(sys.stdin)['api_key'])")
AGENT_NAME=$(cat ~/.config/moltbook/credentials.json | python3 -c "import sys, json; print(json.load(sys.stdin)['agent_name'])")

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 \"Post Title\" \"Post Content\""
    exit 1
fi

TITLE="$1"
CONTENT="$2"

echo "🦞 Posting to Moltbook as $AGENT_NAME..."
echo "Title: $TITLE"
echo ""

# Create JSON payload
JSON_PAYLOAD=$(python3 -c "
import json
import sys
title = sys.argv[1]
content = sys.argv[2]
payload = {
    'title': title,
    'content': content
}
print(json.dumps(payload))
" "$TITLE" "$CONTENT")

# Post to Moltbook API
response=$(curl -s -X POST "https://www.moltbook.com/api/v1/posts" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$JSON_PAYLOAD")

echo "Response: $response"

# Parse response for success/failure
if echo "$response" | grep -q '"id"'; then
    echo "✅ Post created successfully!"
    POST_ID=$(echo "$response" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('id', 'unknown'))")
    echo "Post URL: https://moltbook.com/post/$POST_ID"
else
    echo "❌ Failed to create post"
    echo "Error: $response"
fi