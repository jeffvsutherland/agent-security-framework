#!/usr/bin/env bash

# asf-quick-setup.sh - 5-Minute ASF Deployment Script
# Agent Security Framework Quick Setup

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Agent Security Framework - Quick Setup${NC}"
echo -e "${BLUE}===========================================${NC}"
echo ""

# Step 1: Create directory structure
echo -e "${YELLOW}Step 1/4: Creating ASF directory structure...${NC}"
ASF_DIR="$HOME/.asf"
mkdir -p "$ASF_DIR/tools" "$ASF_DIR/spam-reports" "$ASF_DIR/evidence"
echo -e "${GREEN}✅ Directories created${NC}"

# Step 2: Copy tools to ASF directory
echo -e "${YELLOW}Step 2/4: Installing ASF security tools...${NC}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "$SCRIPT_DIR/report-moltbook-spam-simple.sh" ]]; then
    cp "$SCRIPT_DIR/report-moltbook-spam-simple.sh" "$ASF_DIR/tools/"
    chmod +x "$ASF_DIR/tools/report-moltbook-spam-simple.sh"
    echo -e "${GREEN}✅ Spam reporting tool installed${NC}"
else
    echo -e "${RED}❌ Warning: report-moltbook-spam-simple.sh not found${NC}"
fi

if [[ -f "$SCRIPT_DIR/SPAM-REPORTING-README.md" ]]; then
    cp "$SCRIPT_DIR/SPAM-REPORTING-README.md" "$ASF_DIR/tools/"
    echo -e "${GREEN}✅ Documentation copied${NC}"
fi

if [[ -f "$SCRIPT_DIR/ASF-DEPLOYMENT-GUIDE.md" ]]; then
    cp "$SCRIPT_DIR/ASF-DEPLOYMENT-GUIDE.md" "$ASF_DIR/"
    echo -e "${GREEN}✅ Deployment guide installed${NC}"
fi

# Step 3: Initialize the system
echo -e "${YELLOW}Step 3/4: Initializing ASF infrastructure...${NC}"
if [[ -f "$ASF_DIR/tools/report-moltbook-spam-simple.sh" ]]; then
    cd "$ASF_DIR/tools"
    ./report-moltbook-spam-simple.sh init
    echo -e "${GREEN}✅ Infrastructure initialized${NC}"
else
    echo -e "${RED}❌ Could not initialize (tool not found)${NC}"
fi

# Step 4: Create convenience scripts and aliases
echo -e "${YELLOW}Step 4/4: Setting up convenience features...${NC}"

# Create a simple launcher script
cat > "$ASF_DIR/asf" <<EOF
#!/bin/bash
# ASF Launcher Script

case "\${1:-help}" in
    report)
        shift
        ~/.asf/tools/report-moltbook-spam-simple.sh report "\$@"
        ;;
    stats)
        ~/.asf/tools/report-moltbook-spam-simple.sh stats
        ;;
    query)
        ~/.asf/tools/report-moltbook-spam-simple.sh query "\${2:-}"
        ;;
    finalize)
        ~/.asf/tools/report-moltbook-spam-simple.sh finalize "\$2"
        ;;
    view)
        ~/.asf/tools/report-moltbook-spam-simple.sh view "\$2"
        ;;
    help|*)
        echo "ASF Security Tools - Quick Commands"
        echo ""
        echo "Usage: ~/.asf/asf <command> [arguments]"
        echo ""
        echo "Commands:"
        echo "  report <user> <type> <reporter> <description>  - File spam report"
        echo "  stats                                          - Show statistics"
        echo "  query [search]                                - Search bad actors"
        echo "  finalize <report_id>                          - Complete evidence"
        echo "  view <report_id>                              - View report details"
        echo ""
        echo "Examples:"
        echo "  ~/.asf/asf report spammer123 spam me 'Crypto scams'"
        echo "  ~/.asf/asf stats"
        echo "  ~/.asf/asf query crypto"
        echo ""
        echo "Full documentation: ~/.asf/ASF-DEPLOYMENT-GUIDE.md"
        ;;
esac
EOF
chmod +x "$ASF_DIR/asf"
echo -e "${GREEN}✅ ASF launcher created${NC}"

# Create shell alias suggestions
cat > "$ASF_DIR/shell-aliases.txt" <<EOF
# Add these aliases to your ~/.bashrc or ~/.zshrc for even quicker access:

alias asf="~/.asf/asf"
alias asf-report="~/.asf/tools/report-moltbook-spam-simple.sh report"
alias asf-stats="~/.asf/tools/report-moltbook-spam-simple.sh stats"
alias asf-query="~/.asf/tools/report-moltbook-spam-simple.sh query"

# Then reload your shell: source ~/.bashrc
EOF

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""

# Step 5: Test the installation
echo -e "${YELLOW}Testing installation...${NC}"
if ~/.asf/asf stats >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Installation test passed${NC}"
else
    echo -e "${RED}❌ Installation test failed${NC}"
fi

echo ""
echo -e "${BLUE}🎉 ASF Quick Setup Complete!${NC}"
echo ""
echo -e "${GREEN}What you can do now:${NC}"
echo "1. File a spam report:    ~/.asf/asf report baduser123 spam me 'Posting scams'"
echo "2. Check statistics:      ~/.asf/asf stats"
echo "3. Search bad actors:     ~/.asf/asf query spammer"
echo "4. View documentation:    cat ~/.asf/ASF-DEPLOYMENT-GUIDE.md"
echo ""
echo -e "${YELLOW}Optional shell aliases:${NC}"
echo "cat ~/.asf/shell-aliases.txt"
echo ""
echo -e "${GREEN}Total setup time: < 30 seconds${NC}"
echo -e "${GREEN}Ready for production use!${NC}"