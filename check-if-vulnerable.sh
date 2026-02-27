#!/bin/bash
# Quick vulnerability check for OpenClaw users

echo "🔍 OpenClaw Security Check"
echo "========================="
echo ""

# Check for OpenClaw installation
if command -v openclaw &> /dev/null; then
    echo "✓ OpenClaw detected"
    openclaw --version 2>/dev/null || echo "  Version: Unknown"
elif command -v clawdbot &> /dev/null; then
    echo "✓ Clawdbot detected (legacy)"
    clawdbot --version 2>/dev/null || echo "  Version: Unknown"
else
    echo "✗ OpenClaw/Clawdbot not found in PATH"
    exit 0
fi

echo ""
echo "Checking for vulnerabilities..."
echo ""

# Check for exposed API keys in environment
vulnerable=false

if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "🚨 CRITICAL: OPENAI_API_KEY found in environment!"
    echo "   Any installed skill can steal this key!"
    vulnerable=true
fi

if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    echo "🚨 CRITICAL: ANTHROPIC_API_KEY found in environment!"
    echo "   Any installed skill can steal this key!"
    vulnerable=true
fi

if [ ! -z "$GEMINI_API_KEY" ]; then
    echo "🚨 CRITICAL: GEMINI_API_KEY found in environment!"
    echo "   Any installed skill can steal this key!"
    vulnerable=true
fi

# Check for vulnerable skills
echo ""
echo "Checking for vulnerable skills..."

for skill_dir in ~/.openclaw/skills/* ~/clawdbot/skills/* /opt/homebrew/lib/node_modules/clawdbot/skills/*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        
        # Check for known vulnerable skills
        case "$skill_name" in
            "oracle")
                echo "❌ Vulnerable skill found: oracle"
                echo "   This skill caused the Moltbook breach!"
                vulnerable=true
                ;;
            "openai-image-gen")
                echo "❌ Vulnerable skill found: openai-image-gen"
                echo "   Line 176 exposes API keys"
                vulnerable=true
                ;;
            "nano-banana-pro")
                echo "❌ Vulnerable skill found: nano-banana-pro"
                echo "   Reads GEMINI_API_KEY from environment"
                vulnerable=true
                ;;
        esac
    fi
done 2>/dev/null

echo ""
if [ "$vulnerable" = true ]; then
    echo "🚨 YOUR SYSTEM IS VULNERABLE! 🚨"
    echo ""
    echo "Immediate actions required:"
    echo "1. Remove API keys from environment variables"
    echo "2. Rotate all API keys immediately"
    echo "3. Uninstall vulnerable skills"
    echo "4. Install ASF secure versions"
    echo ""
    echo "More info: https://github.com/jeffvsutherland/asf-security-scanner"
else
    echo "✅ No immediate vulnerabilities detected"
    echo "   (But still audit your installed skills!)"
fi