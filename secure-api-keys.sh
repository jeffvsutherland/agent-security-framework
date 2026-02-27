#!/bin/bash
# Secure API Key Migration Script
# Moves API keys from environment to secure storage

echo "🔒 ASF Security - API Key Migration Tool"
echo "========================================"
echo ""
echo "This script helps you securely store API keys"
echo "instead of keeping them in environment variables."
echo ""

# Create credentials directory
mkdir -p ~/.openclaw
CRED_FILE=~/.openclaw/credentials.json

# Initialize JSON if doesn't exist
if [ ! -f "$CRED_FILE" ]; then
    echo "{}" > "$CRED_FILE"
    chmod 600 "$CRED_FILE"
fi

# Check for existing keys in environment
echo "🔍 Checking for API keys in environment..."
echo ""

# OpenAI
if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "✅ Found OPENAI_API_KEY"
    jq --arg key "$OPENAI_API_KEY" '.openai_api_key = $key' "$CRED_FILE" > "$CRED_FILE.tmp" && mv "$CRED_FILE.tmp" "$CRED_FILE"
    echo "   → Migrated to secure storage"
    echo "   ⚠️  Remember to remove from .bashrc/.zshrc!"
else
    echo "❌ OPENAI_API_KEY not found in environment"
fi

# Gemini
if [ ! -z "$GEMINI_API_KEY" ]; then
    echo "✅ Found GEMINI_API_KEY"
    jq --arg key "$GEMINI_API_KEY" '.gemini_api_key = $key' "$CRED_FILE" > "$CRED_FILE.tmp" && mv "$CRED_FILE.tmp" "$CRED_FILE"
    echo "   → Migrated to secure storage"
    echo "   ⚠️  Remember to remove from .bashrc/.zshrc!"
else
    echo "❌ GEMINI_API_KEY not found in environment"
fi

# Anthropic
if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "✅ Found ANTHROPIC_API_KEY"
    jq --arg key "$ANTHROPIC_API_KEY" '.anthropic_api_key = $key' "$CRED_FILE" > "$CRED_FILE.tmp" && mv "$CRED_FILE.tmp" "$CRED_FILE"
    echo "   → Migrated to secure storage"
    echo "   ⚠️  Remember to remove from .bashrc/.zshrc!"
else
    echo "❌ ANTHROPIC_API_KEY not found in environment"
fi

echo ""
echo "📄 Credentials stored in: $CRED_FILE"
echo "🔐 File permissions: 600 (owner read/write only)"
echo ""
echo "⚠️  IMPORTANT: Remove API keys from your shell config files!"
echo "   Check: ~/.bashrc, ~/.zshrc, ~/.bash_profile"
echo ""
echo "✅ Secure skills are now active in /workspace/skills/"