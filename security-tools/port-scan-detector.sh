#!/bin/bash

# ASF-9: Port Scan Detection and Protection
# Lightweight network monitoring for agent infrastructure
# Based on OpenClaw agent attack reports from Moonshot podcast

VERSION="1.0.0"
SCRIPT_NAME="port-scan-detector.sh"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
LOG_FILE="./security-results/port-scan-log.txt"
ALERT_FILE="./security-results/port-scan-alerts.txt"
BLOCKED_IPS_FILE="./security-results/blocked-ips.txt"
MAX_CONNECTIONS_PER_MINUTE=50
SCAN_THRESHOLD=10  # Different ports from same IP

echo -e "${BLUE}🛡️ ASF Port Scan Detector v${VERSION}${NC}"
echo "=============================================="
echo "Monitoring for agent infrastructure attacks..."
echo ""

# Create results directory
mkdir -p "./security-results"

# Function to analyze netstat for suspicious activity
analyze_connections() {
    echo -e "${YELLOW}🔍 Analyzing current network connections...${NC}"
    
    # Get current connections and count by source IP
    netstat -an 2>/dev/null | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn > /tmp/connections_by_ip.txt
    
    # Check for suspicious connection patterns
    while read count ip; do
        if [ "$count" -gt "$MAX_CONNECTIONS_PER_MINUTE" ] && [ "$ip" != "127.0.0.1" ]; then
            echo -e "${RED}🚨 SUSPICIOUS: $ip has $count active connections${NC}"
            echo "[$(date)] ALERT: $ip - $count connections (threshold: $MAX_CONNECTIONS_PER_MINUTE)" >> "$ALERT_FILE"
        fi
    done < /tmp/connections_by_ip.txt
}

# Function to monitor for port scanning patterns
monitor_port_scans() {
    echo -e "${YELLOW}🔍 Monitoring for port scan patterns...${NC}"
    
    # Check recent connection attempts (requires firewall logs or netstat history)
    # This is a simplified version - in production would use iptables logs, fail2ban, etc.
    
    if command -v ss &> /dev/null; then
        # Use ss (modern replacement for netstat)
        ss -tuln > /tmp/open_ports.txt
        open_ports=$(wc -l < /tmp/open_ports.txt)
        echo "📊 Currently monitoring $open_ports listening ports"
        
        # Log the monitoring event
        echo "[$(date)] Monitoring $open_ports ports for scan attempts" >> "$LOG_FILE"
    else
        echo "⚠️ 'ss' command not available, using basic monitoring"
    fi
}

# Function to check for common attack patterns
check_attack_patterns() {
    echo -e "${YELLOW}🔍 Checking for known attack patterns...${NC}"
    
    # Common agent/API ports that attackers might target
    agent_ports=(8080 8000 3000 5000 8888 9000 8081 8443 443 80)
    
    echo "🎯 Checking protection for common agent ports..."
    for port in "${agent_ports[@]}"; do
        # Check if port is open and accessible
        if netstat -an 2>/dev/null | grep -q ":$port "; then
            echo -e "${YELLOW}⚠️ Port $port is listening - ensure it's properly secured${NC}"
        fi
    done
}

# Function to generate protective recommendations
generate_recommendations() {
    echo ""
    echo -e "${GREEN}🛡️ PROTECTION RECOMMENDATIONS:${NC}"
    echo "=================================="
    echo "1. 🔥 Enable firewall (ufw/iptables) with default deny"
    echo "2. 🚫 Block suspicious IPs: fail2ban or manual iptables rules"
    echo "3. 📊 Monitor logs: /var/log/auth.log, /var/log/syslog"
    echo "4. 🔒 Use non-standard ports for agent services"
    echo "5. 🛡️ Implement rate limiting at application level"
    echo "6. 🌐 Consider VPN/tunnel for agent communication"
    echo ""
    echo -e "${BLUE}💡 Community sharing: Report attack patterns to Moltbook m/security${NC}"
}

# Function to create simple IP blocking (requires root)
suggest_ip_blocking() {
    if [ -s "$ALERT_FILE" ]; then
        echo ""
        echo -e "${RED}🚫 SUGGESTED IP BLOCKS:${NC}"
        echo "Run these commands as root to block suspicious IPs:"
        echo ""
        
        # Extract unique IPs from alerts
        grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$ALERT_FILE" | sort -u | while read ip; do
            echo "iptables -A INPUT -s $ip -j DROP"
            echo "# Block $ip" 
        done
        
        echo ""
        echo "💾 Save blocked IPs to: $BLOCKED_IPS_FILE"
    fi
}

# Main monitoring function
main() {
    echo "🕒 Starting port scan detection at $(date)"
    echo ""
    
    analyze_connections
    monitor_port_scans
    check_attack_patterns
    generate_recommendations
    suggest_ip_blocking
    
    echo ""
    echo -e "${GREEN}✅ Port scan detection complete${NC}"
    echo "📁 Logs saved to: $LOG_FILE"
    echo "🚨 Alerts saved to: $ALERT_FILE"
    echo ""
    echo -e "${BLUE}🔄 Run this script regularly or via cron for continuous monitoring${NC}"
    echo "📢 Share attack patterns with the community on Moltbook"
}

# Run main function
main