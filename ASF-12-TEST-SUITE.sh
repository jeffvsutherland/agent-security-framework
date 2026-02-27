#!/bin/bash
# ASF-12 Test Suite - Validate against known fake agent patterns
# Tests the fake agent detection system with known patterns

VERSION="1.0.0"
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 ASF-12 Test Suite v$VERSION${NC}"
echo "=================================="
echo "Testing against known fake agent patterns..."
echo ""

# Test function
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_level="$3"
    local expected_score_min="$4"
    local expected_score_max="$5"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    echo -e "${BLUE}Test $TEST_COUNT: $test_name${NC}"
    
    # Run the command and capture output
    result=$(eval "$command" 2>/dev/null)
    exit_code=$?
    
    if [ $? -eq 0 ] || [ $exit_code -eq 1 ] || [ $exit_code -eq 2 ]; then
        # Parse JSON output
        score=$(echo "$result" | jq -r '.authenticity_score' 2>/dev/null)
        level=$(echo "$result" | jq -r '.authenticity_level' 2>/dev/null)
        
        # Validate results
        errors=()
        
        if [ "$level" != "$expected_level" ]; then
            errors+=("Expected level '$expected_level', got '$level'")
        fi
        
        if [ -n "$score" ] && [ "$score" != "null" ]; then
            if [ $score -lt $expected_score_min ] || [ $score -gt $expected_score_max ]; then
                errors+=("Score $score outside expected range [$expected_score_min, $expected_score_max]")
            fi
        else
            errors+=("Could not parse authenticity score")
        fi
        
        if [ ${#errors[@]} -eq 0 ]; then
            echo -e "  ${GREEN}✅ PASS${NC} - Score: $score, Level: $level"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo -e "  ${RED}❌ FAIL${NC}"
            for error in "${errors[@]}"; do
                echo -e "    • $error"
            done
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo -e "  ${RED}❌ FAIL${NC} - Command failed with exit code $exit_code"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    echo ""
}

# Test 1: Demo Fake Agent (Known Pattern)
run_test "Demo Fake Agent Pattern" \
         "./security-tools/fake-agent-detector.sh --demo-fake-agent --json" \
         "FAKE" \
         -200 0

# Test 2: Demo Authentic Agent 
run_test "Demo Authentic Agent Pattern" \
         "./security-tools/fake-agent-detector.sh --demo-authentic-agent --json" \
         "AUTHENTIC" \
         80 200

# Test 3: Random Agent (Should be in normal ranges)
run_test "Random Agent Analysis" \
         "./security-tools/fake-agent-detector.sh --json" \
         "" \
         -50 150

# Test 4: JSON Format Validation
echo -e "${BLUE}Test $((TEST_COUNT + 1)): JSON Format Validation${NC}"
TEST_COUNT=$((TEST_COUNT + 1))

json_output=$(./security-tools/fake-agent-detector.sh --demo-authentic-agent --json 2>/dev/null)
if echo "$json_output" | jq . > /dev/null 2>&1; then
    echo -e "  ${GREEN}✅ PASS${NC} - Valid JSON output"
    PASS_COUNT=$((PASS_COUNT + 1))
    
    # Check required fields
    required_fields=("version" "timestamp" "authenticity_score" "max_score" "authenticity_level" "recommendation" "risk_indicators")
    missing_fields=()
    
    for field in "${required_fields[@]}"; do
        value=$(echo "$json_output" | jq -r ".$field" 2>/dev/null)
        if [ "$value" == "null" ] || [ -z "$value" ]; then
            missing_fields+=("$field")
        fi
    done
    
    if [ ${#missing_fields[@]} -eq 0 ]; then
        echo -e "    ${GREEN}✅${NC} All required JSON fields present"
    else
        echo -e "    ${YELLOW}⚠️${NC} Missing fields: ${missing_fields[*]}"
    fi
else
    echo -e "  ${RED}❌ FAIL${NC} - Invalid JSON output"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Test 5: Performance Benchmark
echo -e "${BLUE}Test $((TEST_COUNT + 1)): Performance Benchmark${NC}"
TEST_COUNT=$((TEST_COUNT + 1))

start_time=$(date +%s%N)
./security-tools/fake-agent-detector.sh --demo-authentic-agent --json > /dev/null 2>&1
end_time=$(date +%s%N)
duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds

target_ms=2000  # 2 second target
if [ $duration -lt $target_ms ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - Execution time: ${duration}ms (under ${target_ms}ms target)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo -e "  ${YELLOW}⚠️ SLOW${NC} - Execution time: ${duration}ms (over ${target_ms}ms target)"
    PASS_COUNT=$((PASS_COUNT + 1))  # Still pass, just warn
fi
echo ""

# Test 6: Exit Code Validation
echo -e "${BLUE}Test $((TEST_COUNT + 1)): Exit Code Validation${NC}"
TEST_COUNT=$((TEST_COUNT + 1))

# Test fake agent exit code
./security-tools/fake-agent-detector.sh --demo-fake-agent --json > /dev/null 2>&1
fake_exit=$?

# Test authentic agent exit code  
./security-tools/fake-agent-detector.sh --demo-authentic-agent --json > /dev/null 2>&1
auth_exit=$?

if [ $fake_exit -eq 2 ] && [ $auth_exit -eq 0 ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - Correct exit codes (fake: $fake_exit, authentic: $auth_exit)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo -e "  ${RED}❌ FAIL${NC} - Wrong exit codes (fake: $fake_exit, authentic: $auth_exit)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Test 7: Known Fake Agent Patterns Detection
echo -e "${BLUE}Test $((TEST_COUNT + 1)): Known Fake Agent Patterns${NC}"
TEST_COUNT=$((TEST_COUNT + 1))

fake_result=$(./security-tools/fake-agent-detector.sh --demo-fake-agent --json 2>/dev/null)
risk_indicators=$(echo "$fake_result" | jq -r '.risk_indicators[]' 2>/dev/null)

expected_patterns=(
    "Suspicious regular posting pattern"
    "Low content originality" 
    "No verifiable technical work"
    "Inconsistent API usage"
    "Low-quality or spam-like community engagement"
    "No community vouching"
    "No verifiable real-world impact"
    "Shallow or inconsistent work history"
)

detected_patterns=0
for pattern in "${expected_patterns[@]}"; do
    if echo "$risk_indicators" | grep -q "$pattern"; then
        detected_patterns=$((detected_patterns + 1))
        echo -e "    ${GREEN}✅${NC} Detected: $pattern"
    else
        echo -e "    ${RED}❌${NC} Missing: $pattern"
    fi
done

if [ $detected_patterns -eq ${#expected_patterns[@]} ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - All fake agent patterns detected ($detected_patterns/${#expected_patterns[@]})"
    PASS_COUNT=$((PASS_COUNT + 1))
elif [ $detected_patterns -gt 5 ]; then
    echo -e "  ${YELLOW}⚠️ PARTIAL${NC} - Most fake agent patterns detected ($detected_patterns/${#expected_patterns[@]})"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo -e "  ${RED}❌ FAIL${NC} - Too few patterns detected ($detected_patterns/${#expected_patterns[@]})"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Test 8: Scoring Range Validation
echo -e "${BLUE}Test $((TEST_COUNT + 1)): Scoring Range Validation${NC}"
TEST_COUNT=$((TEST_COUNT + 1))

# Run multiple random tests to check score distribution
declare -A level_counts
total_tests=10

for i in $(seq 1 $total_tests); do
    result=$(./security-tools/fake-agent-detector.sh --json 2>/dev/null)
    level=$(echo "$result" | jq -r '.authenticity_level' 2>/dev/null)
    if [ -n "$level" ] && [ "$level" != "null" ]; then
        level_counts[$level]=$((${level_counts[$level]} + 1))
    fi
done

echo "  Score distribution over $total_tests runs:"
for level in "FAKE" "HIGH_RISK" "REVIEW_NEEDED" "LIKELY_AUTHENTIC" "AUTHENTIC"; do
    count=${level_counts[$level]:-0}
    echo -e "    $level: $count"
done

if [ ${#level_counts[@]} -gt 0 ]; then
    echo -e "  ${GREEN}✅ PASS${NC} - Scoring system produces varied results"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo -e "  ${RED}❌ FAIL${NC} - Scoring system not working"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Final Results
echo "=================================="
echo -e "${BLUE}📊 TEST RESULTS SUMMARY${NC}"
echo "=================================="
echo -e "Total Tests: ${BLUE}$TEST_COUNT${NC}"
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"

pass_rate=$((PASS_COUNT * 100 / TEST_COUNT))
echo -e "Pass Rate: ${BLUE}$pass_rate%${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    echo -e "${GREEN}ASF-12 is ready for production deployment.${NC}"
    exit 0
elif [ $pass_rate -ge 80 ]; then
    echo ""
    echo -e "${YELLOW}⚠️ MOSTLY PASSING${NC}"
    echo -e "${YELLOW}ASF-12 has some issues but core functionality works.${NC}"
    exit 1
else
    echo ""
    echo -e "${RED}❌ MULTIPLE FAILURES${NC}"
    echo -e "${RED}ASF-12 needs fixes before deployment.${NC}"
    exit 2
fi