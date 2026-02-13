#!/bin/bash
#===============================================================================
# Agent Security Framework - Deployment Script
# Deploys the ASF Discord bot and security tools
#===============================================================================

set -e

echo "=============================================="
echo "Agent Security Framework - Deployment"
echo "=============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -d "security-tools" ]; then
    echo -e "${RED}Error: security-tools directory not found${NC}"
    echo "Please run this script from the agent-security-framework directory"
    exit 1
fi

echo ""
echo -e "${GREEN}✅ Found security-tools directory${NC}"

# Make all scripts executable
echo ""
echo "Making scripts executable..."
chmod +x security-tools/*.sh
echo -e "${GREEN}✅ Scripts are now executable${NC}"

# List available tools
echo ""
echo "=============================================="
echo "Available Security Tools:"
echo "=============================================="
echo ""
echo "1. Fake Agent Detector"
echo "   Usage: ./security-tools/fake-agent-detector.sh"
echo ""
echo "2. Infrastructure Security Check"
echo "   Usage: ./security-tools/infrastructure-security-check.sh"
echo ""
echo "3. Moltbook Spam Monitor"
echo "   Usage: ./security-tools/moltbook-spam-monitor.sh"
echo ""
echo "4. Port Scan Detector"
echo "   Usage: ./security-tools/port-scan-detector.sh"
echo ""

# Check for Discord bot deployment
if [ -f "../discord-asf-bot.js" ]; then
    echo "=============================================="
    echo "Discord Bot Setup"
    echo "=============================================="
    echo ""
    echo "Found Discord bot at: ../discord-asf-bot.js"
    echo ""

    # Check for Node.js
    if command -v node &> /dev/null; then
        echo -e "${GREEN}✅ Node.js is installed: $(node --version)${NC}"
    else
        echo -e "${RED}❌ Node.js is not installed${NC}"
        echo "Install with: brew install node"
        exit 1
    fi

    # Check for npm
    if command -v npm &> /dev/null; then
        echo -e "${GREEN}✅ npm is installed: $(npm --version)${NC}"
    else
        echo -e "${RED}❌ npm is not installed${NC}"
        exit 1
    fi

    # Install dependencies
    echo ""
    echo "Installing dependencies..."
    cd ..
    if [ -f "package.json" ]; then
        npm install
        echo -e "${GREEN}✅ Dependencies installed${NC}"
    else
        echo "Creating package.json..."
        cat > package.json << 'EOF'
{
  "name": "asf-discord-bot",
  "version": "1.0.0",
  "description": "Agent Security Framework Discord Bot",
  "main": "discord-asf-bot.js",
  "scripts": {
    "start": "node discord-asf-bot.js",
    "dev": "nodemon discord-asf-bot.js"
  },
  "dependencies": {
    "discord.js": "^14.14.1",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
EOF
        npm install
        echo -e "${GREEN}✅ Created package.json and installed dependencies${NC}"
    fi
    cd agent-security-framework
fi

echo ""
echo "=============================================="
echo "Environment Setup"
echo "=============================================="
echo ""

# Check for .env file
if [ -f "../.env" ]; then
    echo -e "${GREEN}✅ .env file found${NC}"
else
    echo -e "${YELLOW}⚠️  No .env file found${NC}"
    echo ""
    echo "Create a .env file with your Discord bot token:"
    echo ""
    echo "  DISCORD_TOKEN=your_discord_bot_token"
    echo "  DISCORD_CLIENT_ID=your_client_id"
    echo "  DISCORD_GUILD_ID=your_guild_id"
    echo ""
fi

echo ""
echo "=============================================="
echo "Deployment Complete!"
echo "=============================================="
echo ""
echo "To start the Discord bot:"
echo "  cd .. && npm start"
echo ""
echo "To run security tools:"
echo "  ./security-tools/fake-agent-detector.sh"
echo "  ./security-tools/infrastructure-security-check.sh"
echo "  ./security-tools/port-scan-detector.sh"
echo ""

