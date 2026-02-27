#!/bin/bash

# Add drjeffsutherland@gmail.com to himalaya configuration

echo "📧 Adding drjeffsutherland@gmail.com to Himalaya"
echo "=============================================="

# First, let's add the account to the config file
echo ""
echo "Adding account configuration..."

cat >> ~/.config/himalaya/config.toml << 'EOF'

[accounts.drjeff]
email = "drjeffsutherland@gmail.com"
display-name = "Dr. Jeff Sutherland [Google]"
downloads-dir = "/Users/jeffsutherland/Downloads"

# IMAP backend for receiving emails
backend.type = "imap"
backend.host = "imap.gmail.com"
backend.port = 993
backend.encryption.type = "tls"
backend.login = "drjeffsutherland@gmail.com"
backend.auth.type = "password"
backend.auth.cmd = "security find-generic-password -s himalaya-drjeff -a drjeffsutherland@gmail.com -w"

# SMTP backend for sending emails
message.send.backend.type = "smtp"
message.send.backend.host = "smtp.gmail.com"
message.send.backend.port = 465
message.send.backend.encryption.type = "tls"
message.send.backend.login = "drjeffsutherland@gmail.com"
message.send.backend.auth.type = "password"
message.send.backend.auth.cmd = "security find-generic-password -s himalaya-drjeff -a drjeffsutherland@gmail.com -w"
EOF

echo "✅ Account configuration added"

echo ""
echo "📝 Next Steps Required:"
echo "1. Generate Google App Password:"
echo "   - Go to: https://myaccount.google.com/apppasswords"
echo "   - Sign in with drjeffsutherland@gmail.com"
echo "   - Generate app password for 'Himalaya Mail'"
echo ""
echo "2. Add password to macOS Keychain:"
echo "   security add-generic-password -s himalaya-drjeff -a drjeffsutherland@gmail.com -w"
echo ""
echo "3. Test the configuration:"
echo "   himalaya -a drjeff list"
echo ""
echo "🔧 Current Himalaya Accounts:"
himalaya accounts | head -10

echo ""
echo "⚠️  Important Notes:"
echo "• Google requires 2FA enabled for app passwords"
echo "• Use App Password, not your regular Gmail password"
echo "• Account name 'drjeff' can be used with: himalaya -a drjeff"