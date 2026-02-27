#!/bin/bash

# Configuration setup for IRS Gem automation
CONFIG_FILE="$HOME/.irs-gem-config"

echo "🛠️  IRS Gem Configuration Setup"
echo ""

if [[ -f "$CONFIG_FILE" ]]; then
    echo "📋 Current configuration:"
    cat "$CONFIG_FILE"
    echo ""
    read -p "Do you want to update the configuration? (y/N): " update
    if [[ ! "$update" =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo "Please provide your IRS Audit Gem URL:"
echo "(e.g., https://gemini.google.com/app/abc123...)"
echo ""
read -p "Gem URL: " gem_url

if [[ -z "$gem_url" ]]; then
    echo "❌ No URL provided. Configuration cancelled."
    exit 1
fi

# Save configuration
cat > "$CONFIG_FILE" << EOF
# IRS Audit Gem Configuration
GEMINI_GEM_URL="$gem_url"
CREATED_DATE="$(date)"
EOF

echo ""
echo "✅ Configuration saved to $CONFIG_FILE"
echo ""
echo "🚀 Enhanced features now available:"
echo "  - Automatic browser opening"
echo "  - Direct navigation to your Gem" 
echo "  - Auto-paste functionality"
echo ""
echo "Test with: irs-gem"