#!/bin/bash
# Securely add OpenAI API key to Clawdbot auth profiles

AUTH_FILE="$HOME/.clawdbot/agents/main/agent/auth-profiles.json"

echo "=== Secure OpenAI Key Setup ==="
echo ""
echo "This will add your OpenAI API key to Clawdbot's secure auth storage."
echo "The key will NOT be stored in environment variables."
echo ""

# Check if auth file exists
if [ ! -f "$AUTH_FILE" ]; then
    echo "❌ Auth file not found at: $AUTH_FILE"
    exit 1
fi

# Prompt for API key
echo -n "Enter your OpenAI API key (input will be hidden): "
read -s OPENAI_KEY
echo ""

# Validate key format
if [[ ! "$OPENAI_KEY" =~ ^sk-[a-zA-Z0-9]{48}$ ]]; then
    echo "❌ Invalid key format. OpenAI keys start with 'sk-' followed by 48 characters."
    exit 1
fi

# Create backup
cp "$AUTH_FILE" "$AUTH_FILE.backup"
echo "✅ Created backup at $AUTH_FILE.backup"

# Read current content
CURRENT=$(cat "$AUTH_FILE")

# Add OpenAI key using jq or python
if command -v jq &> /dev/null; then
    # Use jq if available
    echo "$CURRENT" | jq --arg key "$OPENAI_KEY" '. + {"openai": {"api_key": $key}}' > "$AUTH_FILE"
else
    # Fall back to Python
    python3 -c "
import json
data = json.loads('$CURRENT')
data['openai'] = {'api_key': '$OPENAI_KEY'}
print(json.dumps(data, indent=2))
" > "$AUTH_FILE"
fi

# Set secure permissions
chmod 600 "$AUTH_FILE"

echo "✅ OpenAI key added to secure storage"
echo "✅ File permissions set to 600 (owner-only)"
echo ""
echo "To test:"
echo "  ./test-oracle-security.sh"
echo ""
echo "Your oracle skill will now use secure credential storage!"