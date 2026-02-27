#!/bin/bash

# ASF-11: Infrastructure Security Assessment Tool
# Validates VPN/Antivirus/DNS protection for agent systems
# Part of ASF Layer 3: Infrastructure Security

VERSION="1.0.0"
SCRIPT_NAME="infrastructure-security-check.sh"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
RESULTS_DIR="./security-results"
INFRA_LOG="$RESULTS_DIR/infrastructure-security.txt"

echo -e "${BLUE}🛡️ ASF Infrastructure Security Assessment v${VERSION}${NC}"
echo "========================================================="
echo "Validating Layer 3: Infrastructure Security"
echo ""

# Create results directory
mkdir -p "$RESULTS_DIR"

# Initialize scoring
SECURITY_SCORE=0
MAX_SCORE=100
ISSUES=()
PASSED=()

echo -e "${YELLOW}🔍 LAYER 3 ASSESSMENT: Infrastructure Security${NC}"
echo "=============================================="

# 1. VPN Protection Check
check_vpn_protection() {
    echo "1️⃣ VPN Protection Status..."
    
    # Check for active VPN interfaces
    VPN_INTERFACES=$(ifconfig | grep -E "utun|tun|tap" | grep -E "UP|RUNNING" | wc -l)
    
    if [ "$VPN_INTERFACES" -gt 0 ]; then
        echo -e "${GREEN}   ✅ VPN interfaces detected: $VPN_INTERFACES active tunnels${NC}"
        SECURITY_SCORE=$((SECURITY_SCORE + 25))
        PASSED+=("VPN tunneling active")
        
        # Check for traffic routing through VPN
        DEFAULT_ROUTE=$(route get google.com | grep interface | awk '{print $2}')
        if echo "$DEFAULT_ROUTE" | grep -q "utun"; then
            echo -e "${GREEN}   ✅ Traffic routing through VPN interface: $DEFAULT_ROUTE${NC}"
            SECURITY_SCORE=$((SECURITY_SCORE + 15))
            PASSED+=("Traffic routing through VPN")
        else
            echo -e "${YELLOW}   ⚠️ Traffic may not be routing through VPN${NC}"
            ISSUES+=("Verify traffic routing through VPN")
        fi
    else
        echo -e "${RED}   ❌ No VPN tunnels detected${NC}"
        ISSUES+=("VPN protection not active - CRITICAL security gap")
    fi
}

# 2. DNS Security Check
check_dns_security() {
    echo ""
    echo "2️⃣ DNS Security Status..."
    
    # Get current DNS servers
    DNS_SERVERS=$(scutil --dns | grep "nameserver\[" | head -5)
    echo "   Current DNS servers:"
    echo "$DNS_SERVERS" | while read line; do
        echo "      $line"
    done
    
    # Check for secure DNS (Cloudflare, Google, VPN DNS)
    if echo "$DNS_SERVERS" | grep -qE "1\.1\.1\.1|8\.8\.8\.8|10\..*"; then
        echo -e "${GREEN}   ✅ Secure/filtered DNS detected${NC}"
        SECURITY_SCORE=$((SECURITY_SCORE + 20))
        PASSED+=("Secure DNS configuration")
    else
        echo -e "${YELLOW}   ⚠️ Using ISP DNS - consider secure alternatives${NC}"
        ISSUES+=("Consider Cloudflare (1.1.1.1) or Google (8.8.8.8) DNS")
    fi
}

# 3. Antivirus/Security Software Check
check_antivirus_protection() {
    echo ""
    echo "3️⃣ Antivirus/Security Software Status..."
    
    # Check for common antivirus processes
    AV_PROCESSES=$(ps aux | grep -iE "avg|norton|mcafee|kaspersky|bitdefender|avast|malware|clamav" | grep -v grep | wc -l)
    
    if [ "$AV_PROCESSES" -gt 0 ]; then
        echo -e "${GREEN}   ✅ Antivirus/security processes detected: $AV_PROCESSES running${NC}"
        SECURITY_SCORE=$((SECURITY_SCORE + 25))
        PASSED+=("Antivirus protection active")
        
        # Show detected security software
        ps aux | grep -iE "avg|norton|mcafee|kaspersky|bitdefender|avast|malware|clamav" | grep -v grep | head -3 | while read line; do
            APP=$(echo "$line" | awk '{print $11}' | xargs basename)
            echo -e "${BLUE}      → $APP${NC}"
        done
    else
        echo -e "${RED}   ❌ No antivirus/security software detected${NC}"
        ISSUES+=("Install antivirus protection - CRITICAL security gap")
    fi
}

# 4. System Security Configuration
check_system_security() {
    echo ""
    echo "4️⃣ System Security Configuration..."
    
    # Check firewall status (macOS)
    if command -v pfctl &> /dev/null; then
        FIREWALL_STATUS=$(sudo pfctl -s info 2>/dev/null | grep "Status" || echo "Status: Unknown")
        if echo "$FIREWALL_STATUS" | grep -q "Enabled"; then
            echo -e "${GREEN}   ✅ Firewall active${NC}"
            SECURITY_SCORE=$((SECURITY_SCORE + 10))
            PASSED+=("Firewall protection enabled")
        else
            echo -e "${YELLOW}   ⚠️ Firewall status: $FIREWALL_STATUS${NC}"
            ISSUES+=("Enable system firewall for additional protection")
        fi
    else
        echo -e "${BLUE}   ℹ️ pfctl not available - checking alternative methods${NC}"
        SECURITY_SCORE=$((SECURITY_SCORE + 5))
    fi
    
    # Check for automatic updates
    if defaults read /Library/Preferences/com.apple.SoftwareUpdate 2>/dev/null | grep -q "AutomaticCheckEnabled.*1"; then
        echo -e "${GREEN}   ✅ Automatic security updates enabled${NC}"
        SECURITY_SCORE=$((SECURITY_SCORE + 5))
        PASSED+=("Automatic updates enabled")
    else
        echo -e "${YELLOW}   ⚠️ Consider enabling automatic security updates${NC}"
        ISSUES+=("Enable automatic security updates")
    fi
}

# 5. Generate Assessment Report
generate_report() {
    echo ""
    echo -e "${BLUE}📊 INFRASTRUCTURE SECURITY ASSESSMENT${NC}"
    echo "======================================"
    echo ""
    
    # Calculate grade
    if [ "$SECURITY_SCORE" -ge 90 ]; then
        GRADE="A"
        GRADE_COLOR="$GREEN"
    elif [ "$SECURITY_SCORE" -ge 80 ]; then
        GRADE="B"
        GRADE_COLOR="$GREEN"
    elif [ "$SECURITY_SCORE" -ge 70 ]; then
        GRADE="C"
        GRADE_COLOR="$YELLOW"
    elif [ "$SECURITY_SCORE" -ge 60 ]; then
        GRADE="D"
        GRADE_COLOR="$YELLOW"
    else
        GRADE="F"
        GRADE_COLOR="$RED"
    fi
    
    echo -e "🎯 ${GRADE_COLOR}SECURITY SCORE: $SECURITY_SCORE/$MAX_SCORE (Grade: $GRADE)${NC}"
    echo ""
    
    if [ ${#PASSED[@]} -gt 0 ]; then
        echo -e "${GREEN}✅ SECURITY MEASURES ACTIVE:${NC}"
        for item in "${PASSED[@]}"; do
            echo "   • $item"
        done
        echo ""
    fi
    
    if [ ${#ISSUES[@]} -gt 0 ]; then
        echo -e "${YELLOW}⚠️ RECOMMENDATIONS:${NC}"
        for item in "${ISSUES[@]}"; do
            echo "   • $item"
        done
        echo ""
    fi
    
    # ASF Layer 3 Compliance
    if [ "$SECURITY_SCORE" -ge 70 ]; then
        echo -e "${GREEN}🛡️ ASF LAYER 3 COMPLIANCE: PASSED${NC}"
        echo "✅ System meets minimum infrastructure security requirements"
    else
        echo -e "${RED}🛡️ ASF LAYER 3 COMPLIANCE: FAILED${NC}"
        echo "❌ System does not meet minimum infrastructure security requirements"
        echo "🚨 Address critical issues before deploying other ASF layers"
    fi
    
    echo ""
    echo -e "${BLUE}💡 UPGRADE RECOMMENDATIONS:${NC}"
    echo "• Consider Cloudflare WARP for enhanced DDoS protection"
    echo "• Implement DNS filtering (Cloudflare for Families, OpenDNS)"
    echo "• Regular security software updates and scans"
    echo "• Monitor VPN connection stability"
    
    # Write results to log
    {
        echo "[$(date)] Infrastructure Security Assessment"
        echo "Score: $SECURITY_SCORE/$MAX_SCORE (Grade: $GRADE)"
        echo "Passed checks: ${#PASSED[@]}"
        echo "Issues found: ${#ISSUES[@]}"
    } >> "$INFRA_LOG"
}

# Main execution
main() {
    check_vpn_protection
    check_dns_security  
    check_antivirus_protection
    check_system_security
    generate_report
    
    echo ""
    echo -e "${GREEN}✅ Infrastructure security assessment complete${NC}"
    echo "📄 Results logged to: $INFRA_LOG"
    echo ""
    echo -e "${BLUE}🔄 Run regularly to ensure continuous protection${NC}"
    echo "📢 Share results with ASF community for security benchmarking"
}

# Run assessment
main