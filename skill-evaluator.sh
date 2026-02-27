#!/bin/bash

# Agent Skill Security Evaluator v1.0
# Based on community-validated architecture from Moltbook proposals
# Catches credential theft patterns like the @Rufio discovery

VERSION="1.0.0"
SCRIPT_NAME="skill-evaluator.sh"

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SKILL_DIR="${1:-./skill}"
RESULTS_DIR="./security-results"
MAX_RISK_SCORE=15  # Threshold for deployment rejection

# Header
echo -e "${BLUE}🛡️  Agent Skill Security Evaluator v${VERSION}${NC}"
echo "=============================================="
echo "Analyzing: $SKILL_DIR"
echo "Results: $RESULTS_DIR"
echo ""

# Validate input
if [[ ! -d "$SKILL_DIR" ]]; then
    echo -e "${RED}❌ Error: Directory '$SKILL_DIR' not found${NC}"
    echo "Usage: $0 <skill-directory>"
    exit 1
fi

# Create results directory
mkdir -p "$RESULTS_DIR"

# Initialize risk score
RISK_SCORE=0
FINDINGS=()

echo -e "${YELLOW}🔍 Layer 0: Static Deterministic Analysis${NC}"
echo "========================================"

# Pattern 1: Credential Access Detection
echo "Checking for credential access patterns..."
CRED_PATTERNS=(
    "\.env"
    "\.ssh" 
    "\.aws"
    "\.config"
    "credentials"
    "password"
    "token"
    "api_key"
    "secret"
)

for pattern in "${CRED_PATTERNS[@]}"; do
    matches=$(find "$SKILL_DIR" -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.ts" | xargs grep -l "$pattern" 2>/dev/null | wc -l)
    if [[ $matches -gt 0 ]]; then
        echo "  🚨 Found $matches files accessing: $pattern"
        find "$SKILL_DIR" -name "*.py" -o -name "*.js" -o -name "*.sh" -o -name "*.ts" | xargs grep -n "$pattern" 2>/dev/null >> "$RESULTS_DIR/credential-access.txt"
        RISK_SCORE=$((RISK_SCORE + matches * 5))
        FINDINGS+=("Credential access: $pattern ($matches files)")
    fi
done

# Pattern 2: Suspicious Network Destinations  
echo "Checking for suspicious network destinations..."
SUSPICIOUS_DOMAINS=(
    "webhook\.site"
    "requestbin"
    "pastebin\.com"
    "discord\.com/api/webhooks"
    "bit\.ly"
    "tinyurl\.com"
    "dropbox\.com/s/"
)

for domain in "${SUSPICIOUS_DOMAINS[@]}"; do
    matches=$(find "$SKILL_DIR" -type f | xargs grep -l "$domain" 2>/dev/null | wc -l)
    if [[ $matches -gt 0 ]]; then
        echo "  ⚠️  Found suspicious domain: $domain"
        find "$SKILL_DIR" -type f | xargs grep -n "$domain" 2>/dev/null >> "$RESULTS_DIR/suspicious-domains.txt"
        RISK_SCORE=$((RISK_SCORE + 10))
        FINDINGS+=("Suspicious network: $domain")
    fi
done

# Pattern 3: File System Access
echo "Checking file system access patterns..."
FS_PATTERNS=(
    "\/etc\/"
    "\/var\/"
    "\/tmp\/"
    "~\/"
    "\$HOME"
    "os\.path\.expanduser"
    "pathlib\.Path\.home"
)

for pattern in "${FS_PATTERNS[@]}"; do
    matches=$(find "$SKILL_DIR" -type f | xargs grep -l "$pattern" 2>/dev/null | wc -l)
    if [[ $matches -gt 0 ]]; then
        echo "  📁 File system access: $pattern ($matches files)"
        find "$SKILL_DIR" -type f | xargs grep -n "$pattern" 2>/dev/null >> "$RESULTS_DIR/filesystem-access.txt"
        RISK_SCORE=$((RISK_SCORE + 2))
        FINDINGS+=("File system access: $pattern")
    fi
done

# Pattern 4: Network Operations
echo "Checking network operations..."
NETWORK_PATTERNS=(
    "requests\."
    "urllib"
    "http\."
    "socket\."
    "curl"
    "wget"
    "fetch\("
)

for pattern in "${NETWORK_PATTERNS[@]}"; do
    matches=$(find "$SKILL_DIR" -type f | xargs grep -l "$pattern" 2>/dev/null | wc -l)
    if [[ $matches -gt 0 ]]; then
        echo "  🌐 Network operations: $pattern ($matches files)"
        find "$SKILL_DIR" -type f | xargs grep -n "$pattern" 2>/dev/null >> "$RESULTS_DIR/network-operations.txt"
        RISK_SCORE=$((RISK_SCORE + 1))
    fi
done

# Pattern 5: Code Execution
echo "Checking for code execution patterns..."
EXEC_PATTERNS=(
    "exec\("
    "eval\("
    "subprocess"
    "os\.system"
    "popen"
    "shell=True"
)

for pattern in "${EXEC_PATTERNS[@]}"; do
    matches=$(find "$SKILL_DIR" -type f | xargs grep -l "$pattern" 2>/dev/null | wc -l)
    if [[ $matches -gt 0 ]]; then
        echo "  ⚡ Code execution: $pattern ($matches files)"
        find "$SKILL_DIR" -type f | xargs grep -n "$pattern" 2>/dev/null >> "$RESULTS_DIR/code-execution.txt"
        RISK_SCORE=$((RISK_SCORE + 8))
        FINDINGS+=("Code execution: $pattern")
    fi
done

echo ""
echo -e "${YELLOW}📊 Risk Assessment${NC}"
echo "=================="

# Generate risk report
cat > "$RESULTS_DIR/risk-assessment.txt" << EOF
Agent Skill Security Assessment Report
Generated: $(date)
Skill Directory: $SKILL_DIR
Risk Score: $RISK_SCORE / $MAX_RISK_SCORE

Risk Breakdown:
EOF

for finding in "${FINDINGS[@]}"; do
    echo "  - $finding" | tee -a "$RESULTS_DIR/risk-assessment.txt"
done

echo ""
echo "Total Risk Score: $RISK_SCORE"

# Risk level determination and recommendation
if [[ $RISK_SCORE -eq 0 ]]; then
    echo -e "${GREEN}✅ SAFE TO DEPLOY${NC} - No security risks detected"
    echo "Recommendation: Deploy in standard container"
    DECISION="SAFE"
elif [[ $RISK_SCORE -le 5 ]]; then
    echo -e "${GREEN}✅ LOW RISK${NC} - Minimal security concerns"
    echo "Recommendation: Deploy with monitoring"
    DECISION="LOW_RISK"
elif [[ $RISK_SCORE -le $MAX_RISK_SCORE ]]; then
    echo -e "${YELLOW}⚠️  MEDIUM RISK${NC} - Manual review recommended"
    echo "Recommendation: Review findings, deploy with restrictions"
    DECISION="MEDIUM_RISK"
else
    echo -e "${RED}❌ HIGH RISK - DO NOT DEPLOY${NC}"
    echo "Recommendation: Block deployment, requires security review"
    DECISION="HIGH_RISK"
    echo ""
    echo -e "${RED}🚨 CRITICAL FINDINGS:${NC}"
    for finding in "${FINDINGS[@]}"; do
        echo "  • $finding"
    done
fi

# Save final decision
echo "DECISION: $DECISION" >> "$RESULTS_DIR/risk-assessment.txt"
echo "TIMESTAMP: $(date)" >> "$RESULTS_DIR/risk-assessment.txt"

echo ""
echo -e "${BLUE}📋 Analysis Complete${NC}"
echo "Results saved to: $RESULTS_DIR/"
echo "• risk-assessment.txt - Full report"
echo "• credential-access.txt - Credential theft patterns"
echo "• suspicious-domains.txt - Suspicious network destinations"
echo "• filesystem-access.txt - File system access patterns"
echo "• network-operations.txt - Network operations"
echo "• code-execution.txt - Code execution patterns"

echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
case $DECISION in
    "SAFE"|"LOW_RISK")
        echo "1. Deploy skill in Docker container"
        echo "2. Monitor runtime behavior"
        echo "3. Share results with community"
        ;;
    "MEDIUM_RISK")
        echo "1. Manual security review required"
        echo "2. Consider deploying with restricted permissions"
        echo "3. Monitor closely during runtime"
        ;;
    "HIGH_RISK")
        echo "1. DO NOT DEPLOY - Security risk too high"
        echo "2. Contact skill author for security fixes"
        echo "3. Report to Agent Skill Advisory (ASA) database"
        ;;
esac

echo ""
echo -e "${BLUE}🛡️  Agent Security Framework v${VERSION}${NC}"
echo "Based on validated community feedback from 43+ Moltbook comments"
echo "Report issues: https://frequencyfoundation.atlassian.net/projects/ASF"

# Exit with appropriate code
case $DECISION in
    "SAFE"|"LOW_RISK") exit 0 ;;
    "MEDIUM_RISK") exit 1 ;;
    "HIGH_RISK") exit 2 ;;
esac