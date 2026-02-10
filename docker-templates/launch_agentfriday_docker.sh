#!/bin/bash

# 🤖 AgentFriday Docker Launcher
# Simple script to setup and run AgentFriday in Docker

set -e

echo "🤖 AgentFriday Docker Setup & Launch"
echo "====================================="

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed"
    echo "   Install Python 3 first, then run this script again"
    exit 1
fi

# Run the main setup script
echo "🚀 Running setup script..."
python3 docker_setup_agentfriday.py

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Edit your API keys:"
echo "   cd ~/agentfriday-docker"
echo "   cp secrets/api_keys.json.template secrets/api_keys.json"
echo "   # Edit secrets/api_keys.json with your real keys"
echo ""
echo "2. Start AgentFriday:"
echo "   docker-compose up -d"
echo ""
echo "3. View logs:"
echo "   docker-compose logs -f"
echo ""
echo "📖 Full documentation: DOCKER_SETUP_README.md"