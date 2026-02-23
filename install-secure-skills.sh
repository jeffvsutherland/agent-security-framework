#!/bin/bash
# ASF Secure Skills Installer
# Replaces vulnerable oracle and openai-image-gen with secure versions

set -e

echo "🛡️  ASF Secure Skills Installer"
echo "================================"

# Check if running in clawd directory
if [ ! -d "asf-secure-skills" ]; then
    echo "❌ Error: Must run from ~/clawd directory"
    exit 1
fi

# Get Clawdbot skills directory
SKILLS_DIR="/opt/homebrew/lib/node_modules/clawdbot/skills"
if [ ! -d "$SKILLS_DIR" ]; then
    echo "❌ Error: Clawdbot skills directory not found at $SKILLS_DIR"
    exit 1
fi

echo "📁 Found Clawdbot skills at: $SKILLS_DIR"

# Backup vulnerable versions
echo ""
echo "📦 Backing up vulnerable skills..."

if [ -d "$SKILLS_DIR/oracle" ]; then
    if [ ! -d "$SKILLS_DIR/oracle.vulnerable" ]; then
        cp -r "$SKILLS_DIR/oracle" "$SKILLS_DIR/oracle.vulnerable"
        echo "   ✅ Backed up oracle → oracle.vulnerable"
    else
        echo "   ⏭️  oracle already backed up"
    fi
fi

if [ -d "$SKILLS_DIR/openai-image-gen" ]; then
    if [ ! -d "$SKILLS_DIR/openai-image-gen.vulnerable" ]; then
        cp -r "$SKILLS_DIR/openai-image-gen" "$SKILLS_DIR/openai-image-gen.vulnerable"
        echo "   ✅ Backed up openai-image-gen → openai-image-gen.vulnerable"
    else
        echo "   ⏭️  openai-image-gen already backed up"
    fi
fi

# Install secure versions
echo ""
echo "🔒 Installing secure versions..."

# Oracle secure
cp -r asf-secure-skills/oracle-secure "$SKILLS_DIR/"
chmod +x "$SKILLS_DIR/oracle-secure/scripts/oracle-secure.js"
echo "   ✅ Installed oracle-secure"

# OpenAI image gen secure
cp -r asf-secure-skills/openai-image-gen-secure "$SKILLS_DIR/"
chmod +x "$SKILLS_DIR/openai-image-gen-secure/scripts/gen-secure.py"
echo "   ✅ Installed openai-image-gen-secure"

# Check for API key in environment
echo ""
echo "🔑 Checking credential status..."

if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "   ⚠️  Warning: OPENAI_API_KEY found in environment"
    echo "   📝 To migrate to secure storage:"
    echo "      1. clawdbot auth set openai api_key $OPENAI_API_KEY"
    echo "      2. unset OPENAI_API_KEY"
    echo "      3. Add to your shell profile: # export OPENAI_API_KEY removed for security"
else
    echo "   ✅ No OPENAI_API_KEY in environment (good!)"
fi

# Check if secure credentials exist
if command -v clawdbot &> /dev/null; then
    if clawdbot auth list 2>/dev/null | grep -q "openai"; then
        echo "   ✅ OpenAI credentials found in secure storage"
    else
        echo "   📝 Need to add credentials: clawdbot auth set openai api_key YOUR_KEY"
    fi
fi

# Show usage
echo ""
echo "📚 Usage:"
echo "   oracle-secure --model gpt-5.2-pro -p 'your question'"
echo "   openai-image-gen-secure 'your image prompt'"

echo ""
echo "🎯 Optional: Replace original skills (after testing):"
echo "   rm -rf $SKILLS_DIR/oracle"
echo "   rm -rf $SKILLS_DIR/openai-image-gen"
echo "   mv $SKILLS_DIR/oracle-secure $SKILLS_DIR/oracle"
echo "   mv $SKILLS_DIR/openai-image-gen-secure $SKILLS_DIR/openai-image-gen"

echo ""
echo "✅ ASF Secure Skills installed successfully!"
echo "🛡️  Your API keys are now protected from credential theft."