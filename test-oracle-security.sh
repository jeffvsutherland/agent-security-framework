#!/bin/bash
# Test script to verify oracle is using secure credentials

echo "=== Oracle Security Test ==="
echo ""

# 1. Check environment (should be empty)
echo "1. Checking environment variables..."
if [ -z "$OPENAI_API_KEY" ]; then
    echo "   ✅ GOOD: No OPENAI_API_KEY in environment"
else
    echo "   ❌ WARNING: OPENAI_API_KEY found in environment!"
fi

# 2. Check auth profiles exist
echo ""
echo "2. Checking secure auth storage..."
AUTH_FILE="$HOME/.clawdbot/agents/main/agent/auth-profiles.json"
if [ -f "$AUTH_FILE" ]; then
    echo "   ✅ Auth profiles file exists"
    # Check permissions
    PERMS=$(stat -f "%Lp" "$AUTH_FILE" 2>/dev/null || stat -c "%a" "$AUTH_FILE" 2>/dev/null)
    if [ "$PERMS" = "600" ]; then
        echo "   ✅ File permissions are secure (600)"
    else
        echo "   ⚠️  File permissions are $PERMS (should be 600)"
    fi
    
    # Check if OpenAI key is configured
    if grep -q '"openai"' "$AUTH_FILE"; then
        echo "   ✅ OpenAI profile configured"
    else
        echo "   ❌ OpenAI profile NOT found - need to add it"
    fi
else
    echo "   ❌ Auth profiles file not found"
fi

# 3. Check which oracle is being used
echo ""
echo "3. Checking oracle skill location..."
if [ -f "$HOME/clawd/skills/oracle/SKILL.md" ]; then
    echo "   ✅ Secure oracle skill installed in user directory"
    if grep -q "oracle-secure" "$HOME/clawd/skills/oracle/SKILL.md"; then
        echo "   ✅ Confirmed: Using secure version"
    fi
else
    echo "   ❌ Secure oracle skill not found in user directory"
fi

# 4. Show current skills
echo ""
echo "4. User skills (take precedence over built-in):"
ls -la "$HOME/clawd/skills/" 2>/dev/null | grep -E "oracle|openai"

echo ""
echo "=== Summary ==="
echo "To complete secure setup:"
echo "1. Add OpenAI key to $AUTH_FILE"
echo "2. Ensure NO environment variables are set"
echo "3. User skills in ~/clawd/skills/ override built-in skills"