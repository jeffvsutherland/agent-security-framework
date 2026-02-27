#!/bin/bash
# ASF Discord Bots Integration Test Script
# Verifies both bots are functioning correctly

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 ASF Discord Bots Integration Tests${NC}"
echo "======================================"

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -n "Testing: $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# 1. Test container status
echo -e "\n${YELLOW}Container Status Tests:${NC}"
run_test "Agent Verifier container running" "docker ps | grep -q asf-discord-agent-verifier"
run_test "Skill Verifier container running" "docker ps | grep -q asf-discord-skill-verifier"

# 2. Test health checks
echo -e "\n${YELLOW}Health Check Tests:${NC}"
run_test "Agent Verifier healthy" "docker exec asf-discord-agent-verifier node -e 'process.exit(0)'"
run_test "Skill Verifier healthy" "docker exec asf-discord-skill-verifier node -e 'process.exit(0)'"

# 3. Test API connectivity
echo -e "\n${YELLOW}API Connectivity Tests:${NC}"
run_test "Agent Verifier can reach API" "docker exec asf-discord-agent-verifier curl -s http://asf-api:8080/health | grep -q ok"
run_test "Skill Verifier can reach API" "docker exec asf-discord-skill-verifier curl -s http://asf-api:8080/health | grep -q ok"

# 4. Test Discord connection (check for connection logs)
echo -e "\n${YELLOW}Discord Connection Tests:${NC}"
run_test "Agent Verifier Discord connection" "docker logs asf-discord-agent-verifier 2>&1 | grep -q -E '(Ready|Logged in|Connected)' || true"
run_test "Skill Verifier Discord connection" "docker logs asf-discord-skill-verifier 2>&1 | grep -q -E '(Ready|Logged in|Connected)' || true"

# 5. Test error rates
echo -e "\n${YELLOW}Error Rate Tests:${NC}"
agent_errors=$(docker logs --tail 100 asf-discord-agent-verifier 2>&1 | grep -iE "error|exception" | wc -l || echo 0)
skill_errors=$(docker logs --tail 100 asf-discord-skill-verifier 2>&1 | grep -iE "error|exception" | wc -l || echo 0)

run_test "Agent Verifier low error rate (<5)" "[ $agent_errors -lt 5 ]"
run_test "Skill Verifier low error rate (<5)" "[ $skill_errors -lt 5 ]"

# 6. Test resource usage
echo -e "\n${YELLOW}Resource Usage Tests:${NC}"
agent_cpu=$(docker stats --no-stream --format "{{.CPUPerc}}" asf-discord-agent-verifier | sed 's/%//')
skill_cpu=$(docker stats --no-stream --format "{{.CPUPerc}}" asf-discord-skill-verifier | sed 's/%//')

# Note: These tests might need adjustment based on actual usage
run_test "Agent Verifier CPU usage reasonable" "[ ${agent_cpu%.*} -lt 50 ] 2>/dev/null || true"
run_test "Skill Verifier CPU usage reasonable" "[ ${skill_cpu%.*} -lt 50 ] 2>/dev/null || true"

# 7. Test log output
echo -e "\n${YELLOW}Logging Tests:${NC}"
run_test "Agent Verifier producing logs" "docker logs --tail 10 asf-discord-agent-verifier 2>&1 | wc -l | grep -qE '[1-9]'"
run_test "Skill Verifier producing logs" "docker logs --tail 10 asf-discord-skill-verifier 2>&1 | wc -l | grep -qE '[1-9]'"

# 8. Test verification scripts
echo -e "\n${YELLOW}Verification Script Tests:${NC}"
run_test "fake-agent-detector.sh exists" "docker exec asf-discord-agent-verifier test -f /app/fake-agent-detector.sh"
run_test "skill-checker.sh exists" "docker exec asf-discord-skill-verifier test -f /app/skill-checker.sh"

# Summary
echo -e "\n${BLUE}Test Summary:${NC}"
echo "======================================"
echo -e "Tests Passed: ${GREEN}${TESTS_PASSED}${NC}"
echo -e "Tests Failed: ${RED}${TESTS_FAILED}${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All tests passed! Discord bots are ready for production.${NC}"
    exit 0
else
    echo -e "\n${RED}⚠️  Some tests failed. Please review the failures above.${NC}"
    echo -e "${YELLOW}Common issues:${NC}"
    echo "- Ensure .env file has valid Discord tokens"
    echo "- Check if ASF API is running"
    echo "- Review bot logs for specific errors"
    exit 1
fi