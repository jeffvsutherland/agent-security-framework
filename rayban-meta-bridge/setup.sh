#!/bin/bash
# Ray-Ban Meta Bridge Setup Script

echo "🕶️  Ray-Ban Meta → Clawdbot Bridge Setup"
echo "========================================"
echo ""

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    echo "📱 Platform: macOS (for development/testing)"
elif [[ -d "/sdcard" ]]; then
    PLATFORM="android"
    echo "📱 Platform: Android"
else
    PLATFORM="ios"
    echo "📱 Platform: iOS"
fi

echo ""
echo "Step 1: Gateway Configuration"
echo "----------------------------"

# Get gateway URL
read -p "Enter Clawdbot Gateway URL [http://192.168.1.100:8180]: " GATEWAY_URL
GATEWAY_URL=${GATEWAY_URL:-http://192.168.1.100:8180}

# Test connection
echo "Testing connection to $GATEWAY_URL..."
if curl -s "$GATEWAY_URL/health" > /dev/null; then
    echo "✅ Gateway reachable!"
else
    echo "❌ Cannot reach gateway. Make sure Clawdbot is running."
    echo "   On your Mac: clawdbot gateway start"
    exit 1
fi

echo ""
echo "Step 2: Node Pairing"
echo "-------------------"

# Get pairing code
echo "On your Mac, run: clawdbot nodes pending"
read -p "Enter pairing code: " PAIRING_CODE

# Create config
CONFIG_DIR="$HOME/.rayban-meta-bridge"
mkdir -p "$CONFIG_DIR"

cat > "$CONFIG_DIR/config.json" << EOF
{
  "gateway_url": "$GATEWAY_URL",
  "pairing_code": "$PAIRING_CODE",
  "platform": "$PLATFORM",
  "auto_process": true,
  "voice_feedback": true
}
EOF

echo "✅ Configuration saved to $CONFIG_DIR/config.json"

echo ""
echo "Step 3: Platform-Specific Setup"
echo "-------------------------------"

if [[ "$PLATFORM" == "android" ]]; then
    echo "📱 Android Setup:"
    echo "1. Install Termux from F-Droid"
    echo "2. Run these commands in Termux:"
    echo ""
    echo "   pkg install python"
    echo "   pip install requests"
    echo "   curl -O $GATEWAY_URL/api/download/bridge-simple.py"
    echo "   python bridge-simple.py"
    echo ""
    echo "3. Grant storage permissions when asked"
    
elif [[ "$PLATFORM" == "ios" ]]; then
    echo "📱 iOS Setup:"
    echo ""
    echo "Option A - Pythonista (Recommended):"
    echo "1. Install Pythonista from App Store"
    echo "2. Copy bridge-simple.py to Pythonista"
    echo "3. Run the script"
    echo ""
    echo "Option B - Shortcuts:"
    echo "1. Open Shortcuts app"
    echo "2. Create 'Send to Clawdbot' shortcut"
    echo "3. Follow instructions in ios-shortcut.md"
fi

echo ""
echo "Step 4: Test the Bridge"
echo "----------------------"
echo "1. Take a photo with your Ray-Ban Meta glasses"
echo "2. Wait for sync to phone (usually instant)"
echo "3. Bridge should detect and send to Clawdbot"
echo "4. You'll hear the analysis through your phone"

echo ""
echo "🎯 Quick Test Commands:"
echo "- 'Hey Meta, take a photo' → Auto-analyzes scene"
echo "- 'Hey Meta, record video' → Summarizes when done"

echo ""
echo "✅ Setup complete! The bridge will run in the background."
echo ""
echo "To start manually:"
echo "- Python: python3 bridge-simple.py"
echo "- Node.js: node phone-bridge.js"

# Save quick start script
cat > "$CONFIG_DIR/start.sh" << 'EOF'
#!/bin/bash
CONFIG_FILE="$HOME/.rayban-meta-bridge/config.json"
if [ -f "$CONFIG_FILE" ]; then
    GATEWAY_URL=$(grep gateway_url "$CONFIG_FILE" | cut -d'"' -f4)
    echo "🕶️ Starting Ray-Ban Meta Bridge..."
    echo "📡 Gateway: $GATEWAY_URL"
    python3 "$(dirname "$0")/../bridge-simple.py" "$GATEWAY_URL"
else
    echo "❌ No configuration found. Run setup.sh first."
fi
EOF

chmod +x "$CONFIG_DIR/start.sh"
echo ""
echo "Created quick start script: $CONFIG_DIR/start.sh"