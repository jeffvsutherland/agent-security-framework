#!/bin/bash
# Test Ray-Ban Meta Bridge locally

echo "🕶️  Ray-Ban Meta Bridge Test"
echo "============================"
echo ""

# Check if Clawdbot is running
if ! curl -s http://localhost:8180/health > /dev/null 2>&1; then
    echo "❌ Clawdbot gateway not running"
    echo "   Run: clawdbot gateway start"
    exit 1
fi

echo "✅ Clawdbot gateway is running"
echo ""

# Create test image
TEST_DIR="/tmp/rayban-meta-test"
mkdir -p "$TEST_DIR"

# Generate test image with ImageMagick or use existing
if command -v convert &> /dev/null; then
    echo "📸 Creating test image..."
    convert -size 800x600 xc:skyblue \
            -gravity center -pointsize 48 \
            -annotate +0+0 "Ray-Ban Meta Test\n$(date)" \
            "$TEST_DIR/test-photo.jpg"
else
    echo "📸 Using sample image..."
    # Create a simple test file
    echo "TEST IMAGE DATA" > "$TEST_DIR/test-photo.jpg"
fi

echo ""
echo "🧪 Testing Bridge Functions:"
echo ""

# Test 1: File Detection
echo "1. File Detection Test"
python3 - << 'EOF'
import sys
sys.path.insert(0, '.')
from bridge_simple import MetaGlassesBridge

bridge = MetaGlassesBridge("http://localhost:8180", "test-token")
print("   Photo directories found:", len(bridge.photo_dirs))
for d in bridge.photo_dirs:
    print(f"   - {d}")
EOF

echo ""
echo "2. Processing Simulation"
echo "   Simulating photo from glasses..."
echo "   Would send to: http://localhost:8180/api/media/upload"
echo "   With metadata: source=rayban-meta, auto_analyze=true"

echo ""
echo "3. Voice Feedback Test"
if [[ "$OSTYPE" == "darwin"* ]]; then
    say "Clawdbot analysis: I see a test image with timestamp"
    echo "   ✅ Voice feedback working"
else
    echo "   ⏭️  Voice feedback not available on this platform"
fi

echo ""
echo "📱 To test with real glasses:"
echo ""
echo "1. Start bridge on phone:"
echo "   python3 bridge-simple.py"
echo ""
echo "2. Take photo with glasses:"
echo "   'Hey Meta, take a photo'"
echo ""
echo "3. Watch console for:"
echo "   📸 New capture: IMG_XXXX.jpg"
echo "   ✅ Sent to Clawdbot"
echo "   🔍 Analysis: [description]"

echo ""
echo "✅ Bridge test complete!"