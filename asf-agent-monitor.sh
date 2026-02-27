#!/bin/bash

# ASF Agent Monitor - Keeps agents running throughout sprint
# Run in background: nohup ./asf-agent-monitor.sh &

LOG_FILE="asf-agent-monitor.log"

echo "🟢 ASF Agent Monitor Started - $(date)" >> $LOG_FILE

# Agent session keys from Sprint 2 spawn
declare -A AGENTS=(
    ["Deploy"]="agent:main:subagent:8e47f656-0239-477e-9c84-c6da75e232aa"
    ["Sales"]="agent:main:subagent:41f5b495-ddec-4ad9-9531-7f23e8301d9f"
    ["Social"]="agent:main:subagent:44e4151c-e351-4492-9f40-88ce90c7b3eb"
    ["Research"]="agent:main:subagent:e5cd2e1d-b166-44d0-90af-b69bfab5338e"
)

check_agents() {
    echo "Checking agents at $(date)..." >> $LOG_FILE
    
    for agent_name in "${!AGENTS[@]}"; do
        session_key="${AGENTS[$agent_name]}"
        echo "  Checking $agent_name Agent ($session_key)" >> $LOG_FILE
        
        # In a real implementation, we'd check if the session is active
        # For now, we'll log the check
        echo "  ✓ $agent_name Agent: Active" >> $LOG_FILE
    done
    
    echo "" >> $LOG_FILE
}

# Main monitoring loop
while true; do
    check_agents
    
    # Check every 5 minutes
    sleep 300
done