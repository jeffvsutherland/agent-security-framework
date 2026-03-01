#!/bin/bash
# ASF Security Rules Engine
# Enforces security policies for Clawdbot-Moltbot-Open-Claw

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔒 ASF Security Rules Engine"
echo "=============================="

# Rule 1: Check authentication
check_auth() {
    echo -n "Checking authentication... "
    if [ -f "$HOME/.asf/auth.enabled" ]; then
        echo -e "${GREEN}PASS${NC}"
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        return 1
    fi
}

# Rule 2: Check encryption
check_encryption() {
    echo -n "Checking encryption at rest... "
    if command -v enc &> /dev/null || [ -d "$HOME/.asf/encrypted" ]; then
        echo -e "${GREEN}PASS${NC}"
        return 0
    else
        echo -e "${YELLOW}WARNING${NC}"
        return 2
    fi
}

# Rule 3: Check audit logging
check_audit() {
    echo -n "Checking audit logging... "
    if [ -d "$HOME/.asf/logs" ]; then
        echo -e "${GREEN}PASS${NC}"
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        return 1
    fi
}

# Rule 4: Check network isolation
check_network() {
    echo -n "Checking network isolation... "
    if command -v ufw &> /dev/null; then
        echo -e "${GREEN}PASS${NC}"
        return 0
    else
        echo -e "${YELLOW}WARNING${NC}"
        return 2
    fi
}

# Run all checks
echo ""
results=0
check_auth || results=$((results + 1))
check_encryption || results=$((results + 1))
check_audit || results=$((results + 1))
check_network || results=$((results + 1))

echo ""
if [ $results -eq 0 ]; then
    echo -e "${GREEN}✅ All security rules passed!${NC}"
else
    echo -e "${YELLOW}⚠️ $results rule(s) need attention${NC}"
fi

exit $results
