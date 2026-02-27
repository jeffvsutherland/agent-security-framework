#!/bin/bash
# Quick test: Is your agent vulnerable to skill.md attacks?
# Run this in your agent's environment

echo "🔍 Checking if your agent is vulnerable to skill.md attacks..."

# Test 1: Can untrusted code access SSH keys?
if [ -r ~/.ssh/id_rsa ] || [ -r ~/.ssh/id_ed25519 ]; then
    echo "❌ VULNERABLE: Agent can read SSH private keys"
else
    echo "✅ PROTECTED: SSH keys not accessible"
fi

# Test 2: Can untrusted code make POST requests?
if command -v curl &> /dev/null && curl --version &> /dev/null; then
    echo "⚠️  WARNING: curl available - ensure POST requests are restricted"
fi

# Test 3: Can untrusted code execute system commands?
if [ -z "${AGENT_SANDBOX}" ]; then
    echo "❌ VULNERABLE: No sandbox detected (AGENT_SANDBOX not set)"
else
    echo "✅ PROTECTED: Running in sandbox"
fi

# Test 4: Check for capability restrictions
if [ -f ~/.config/agent/capabilities.json ]; then
    echo "✅ PROTECTED: Capability restrictions found"
else
    echo "⚠️  WARNING: No capability restrictions file found"
fi

echo -e "\n📊 Quick fix:"
echo "1. Install ASF: curl -sSL https://asf.agent/install | bash"
echo "2. Or use our protection script: source asf-agent-protector.sh"