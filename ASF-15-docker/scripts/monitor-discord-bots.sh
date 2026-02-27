#!/bin/bash
# ASF Discord Bots Monitoring Script
# Real-time monitoring and alerting for production bots

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Monitoring configuration
CHECK_INTERVAL=30  # seconds
LOG_TAIL_LINES=50
ALERT_WEBHOOK_URL="${DISCORD_ALERT_WEBHOOK:-}"

# Function to send Discord alert
send_discord_alert() {
    local message="$1"
    if [ -n "$ALERT_WEBHOOK_URL" ]; then
        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\":\"⚠️ **ASF Bot Alert**: $message\"}" \
             "$ALERT_WEBHOOK_URL" 2>/dev/null
    fi
}

# Function to check container status
check_container_status() {
    local container=$1
    local status=$(docker inspect -f '{{.State.Status}}' $container 2>/dev/null)
    
    if [ "$status" = "running" ]; then
        echo -e "${GREEN}✅ ${container}: Running${NC}"
        return 0
    else
        echo -e "${RED}❌ ${container}: ${status:-Not Found}${NC}"
        send_discord_alert "${container} is ${status:-not found}!"
        return 1
    fi
}

# Function to check container health
check_container_health() {
    local container=$1
    local health=$(docker inspect -f '{{.State.Health.Status}}' $container 2>/dev/null)
    
    if [ "$health" = "healthy" ]; then
        echo -e "${GREEN}   Health: Healthy${NC}"
    elif [ "$health" = "unhealthy" ]; then
        echo -e "${RED}   Health: Unhealthy${NC}"
        send_discord_alert "${container} is unhealthy!"
    else
        echo -e "${YELLOW}   Health: ${health:-Unknown}${NC}"
    fi
}

# Function to show resource usage
show_resource_usage() {
    local container=$1
    local stats=$(docker stats --no-stream --format "CPU: {{.CPUPerc}} | Memory: {{.MemUsage}}" $container 2>/dev/null)
    if [ -n "$stats" ]; then
        echo -e "${BLUE}   Resources: ${stats}${NC}"
    fi
}

# Function to check recent errors in logs
check_recent_errors() {
    local container=$1
    local error_count=$(docker logs --tail 100 $container 2>&1 | grep -iE "error|exception|critical" | wc -l)
    if [ $error_count -gt 0 ]; then
        echo -e "${YELLOW}   Recent errors: ${error_count}${NC}"
        if [ $error_count -gt 10 ]; then
            send_discord_alert "${container} has ${error_count} errors in recent logs!"
        fi
    else
        echo -e "${GREEN}   No recent errors${NC}"
    fi
}

# Main monitoring loop
clear
echo -e "${BLUE}🔍 ASF Discord Bots Monitor${NC}"
echo "================================="
echo "Monitoring interval: ${CHECK_INTERVAL}s"
echo "Press Ctrl+C to stop"
echo ""

while true; do
    echo -e "\n${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} Checking bot status..."
    echo "---------------------------------"
    
    # Check Agent Verifier Bot
    echo -e "\n${YELLOW}Agent Verifier Bot:${NC}"
    if check_container_status "asf-discord-agent-verifier"; then
        check_container_health "asf-discord-agent-verifier"
        show_resource_usage "asf-discord-agent-verifier"
        check_recent_errors "asf-discord-agent-verifier"
    fi
    
    # Check Skill Verifier Bot
    echo -e "\n${YELLOW}Skill Verifier Bot:${NC}"
    if check_container_status "asf-discord-skill-verifier"; then
        check_container_health "asf-discord-skill-verifier"
        show_resource_usage "asf-discord-skill-verifier"
        check_recent_errors "asf-discord-skill-verifier"
    fi
    
    # Check API connectivity
    echo -e "\n${YELLOW}API Connectivity:${NC}"
    api_health=$(docker exec asf-discord-agent-verifier curl -s http://asf-api:8080/health 2>/dev/null | grep -o "ok" || echo "failed")
    if [ "$api_health" = "ok" ]; then
        echo -e "${GREEN}✅ ASF API: Connected${NC}"
    else
        echo -e "${RED}❌ ASF API: Connection Failed${NC}"
        send_discord_alert "Discord bots cannot connect to ASF API!"
    fi
    
    # Show uptime
    echo -e "\n${BLUE}Uptime:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}" | grep discord
    
    echo -e "\n${BLUE}Next check in ${CHECK_INTERVAL} seconds...${NC}"
    sleep $CHECK_INTERVAL
    clear
done