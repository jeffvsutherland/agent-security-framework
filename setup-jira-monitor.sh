#!/bin/bash

# Setup Jira Monitor integration with Agent Friday
echo "📋 Setting up Jira Monitor for Agent Friday"

# Add alias for jira-monitor
ALIAS_LINE="alias jira-monitor='/Users/jeffsutherland/clawd/jira-monitor.sh'"

# Add to shell profiles
if [[ -f ~/.bash_profile ]]; then
    if ! grep -q "jira-monitor" ~/.bash_profile; then
        echo "" >> ~/.bash_profile
        echo "# Jira Monitor - Scrum Teams Backlog Watch" >> ~/.bash_profile
        echo "$ALIAS_LINE" >> ~/.bash_profile
        echo "✅ Added to ~/.bash_profile"
    fi
fi

if [[ -f ~/.zshrc ]]; then
    if ! grep -q "jira-monitor" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Jira Monitor - Scrum Teams Backlog Watch" >> ~/.zshrc
        echo "$ALIAS_LINE" >> ~/.zshrc
        echo "✅ Added to ~/.zshrc"
    fi
fi

echo ""
echo "🎉 Jira Monitor Setup Complete!"
echo ""
echo "📋 AVAILABLE COMMANDS:"
echo "• jira-monitor setup     - Configure Jira connection"
echo "• jira-monitor report    - Full team status report"
echo "• jira-monitor sprints   - Active sprint overview"
echo "• jira-monitor backlog   - Backlog health check"
echo "• jira-monitor critical  - High priority & blocked issues"
echo "• jira-monitor velocity  - Team performance metrics"
echo ""
echo "🤖 AGENT FRIDAY INTEGRATION:"
echo "• agent-friday jira      - Quick team status"
echo "• agent-friday morning   - Now includes sprint status"
echo "• agent-friday eod       - Now includes critical issues"
echo ""
echo "⚙️  NEXT STEPS:"
echo "1. Run: jira-monitor setup (configure your Jira connection)"
echo "2. Run: jira-monitor setup-projects (configure project tracking)"
echo "3. Test: agent-friday jira (verify integration)"
echo ""
echo "🚀 Your Scrum teams are now monitored 24/7!"