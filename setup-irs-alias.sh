#!/bin/bash

# Setup alias for IRS Gem command
echo "Setting up IRS Gem command alias..."

# Add to .bash_profile and .zshrc for compatibility
ALIAS_LINE="alias irs-gem='/Users/jeffsutherland/clawd/irs-gem-function.sh'"

# Add to bash profile
if [[ -f ~/.bash_profile ]]; then
    if ! grep -q "irs-gem" ~/.bash_profile; then
        echo "" >> ~/.bash_profile
        echo "# IRS Gem Command" >> ~/.bash_profile
        echo "$ALIAS_LINE" >> ~/.bash_profile
        echo "✅ Added to ~/.bash_profile"
    else
        echo "⚠️  Alias already exists in ~/.bash_profile"
    fi
fi

# Add to zsh profile
if [[ -f ~/.zshrc ]]; then
    if ! grep -q "irs-gem" ~/.zshrc; then
        echo "" >> ~/.zshrc
        echo "# IRS Gem Command" >> ~/.zshrc  
        echo "$ALIAS_LINE" >> ~/.zshrc
        echo "✅ Added to ~/.zshrc"
    else
        echo "⚠️  Alias already exists in ~/.zshrc"
    fi
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "USAGE:"
echo "  irs-gem           # Send YESTERDAY'S completed note"
echo "  irs-gem today     # Send today's note (if needed)"
echo "  irs-gem 20260201  # Send specific date's note"
echo ""
echo "💡 Restart terminal or run 'source ~/.zshrc' to use the command"