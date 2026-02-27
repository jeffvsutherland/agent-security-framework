#!/bin/bash

# Setup Agent Friday alias and integration
echo "🤖 Setting up Agent Friday - Your Executive Assistant"

# Add alias
ALIAS_LINE="alias agent-friday='/Users/jeffsutherland/clawd/agent-friday.sh'"

# Add to shell profiles
if [[ -f ~/.bash_profile ]]; then
    if ! grep -q "agent-friday" ~/.bash_profile; then
        echo "" >> ~/.bash_profile
        echo "# Agent Friday - Executive Assistant" >> ~/.bash_profile
        echo "$ALIAS_LINE" >> ~/.bash_profile
        echo "✅ Added to ~/.bash_profile"
    fi
fi

if [[ -f ~/.zshrc ]]; then
    if ! grep -q "agent-friday" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# Agent Friday - Executive Assistant" >> ~/.zshrc
        echo "$ALIAS_LINE" >> ~/.zshrc
        echo "✅ Added to ~/.zshrc"
    fi
fi

echo ""
echo "🎉 Agent Friday Setup Complete!"
echo ""
echo "📅 AUTOMATED SCHEDULE:"
echo "• 7:30 AM  - Morning briefing & priority scan"
echo "• 5:30 PM  - End-of-day shutdown report"
echo "• Fridays  - Weekly strategic review"
echo "• Midnight - JVS note automation continues"
echo ""
echo "💻 MANUAL COMMANDS:"
echo "• agent-friday morning   - Get daily briefing"
echo "• agent-friday eod       - End-of-day report"
echo "• agent-friday commit    - Add commitment"
echo "• agent-friday status    - Check system status"
echo ""
echo "🚀 Ready to be your Agent Friday!"