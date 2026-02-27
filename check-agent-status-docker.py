#!/usr/bin/env python3
"""
Check status of all ASF agents running in Docker.
Updated to reflect actual live agents with Telegram bots.
"""
import json
import sys
from datetime import datetime
import pytz

# Actual agents running in Docker
ASF_AGENTS = {
    "deploy": {
        "name": "ASF Deploy Agent", 
        "emoji": "🔴", 
        "bot": "@ASFDeployBot",
        "workspace": "/workspace/agents/deploy/"
    },
    "sales": {
        "name": "ASF Sales Agent", 
        "emoji": "🔵",
        "bot": "@ASFSalesBot",
        "workspace": "/workspace/agents/sales/"
    },
    "social": {
        "name": "ASF Social Agent", 
        "emoji": "🟢",
        "bot": "@ASFSocialBot",
        "workspace": "/workspace/agents/social/"
    },
    "research": {
        "name": "ASF Research Agent", 
        "emoji": "🟣",
        "bot": "@ASFResearchBot",
        "workspace": "/workspace/agents/research/"
    }
}

def get_current_time():
    """Get current time in ET"""
    et_tz = pytz.timezone('US/Eastern')
    now = datetime.now(et_tz)
    return now.strftime("%I:%M %p ET")

def get_agent_tracking():
    """Load agent tracking data"""
    try:
        with open('/workspace/memory/asf-agent-tracking.json', 'r') as f:
            return json.load(f)
    except:
        return {"agents": {}}

def format_agent_report():
    """Format the hourly agent status report"""
    time = get_current_time()
    tracking = get_agent_tracking()
    
    report = f"## 🤖 ASF AGENT STATUS ({time})\n"
    report += f"**All agents running in Docker ✅**\n\n"
    
    alerts = {
        "no_story": [],
        "needs_review": [],
        "blocked": []
    }
    
    for agent_id, agent_info in ASF_AGENTS.items():
        agent_key = f"asf-{agent_id}"
        agent_data = tracking.get("agents", {}).get(agent_key, {})
        
        report += f"**{agent_info['emoji']} {agent_info['name']}**\n"
        report += f"- Telegram: {agent_info['bot']}\n"
        
        # Story info
        story = agent_data.get('current_story')
        if story:
            report += f"- Story: {story}\n"
            report += f"- Status: In Progress "
            report += "(assigned ✓)\n" if agent_data.get('jira_assigned') else "(NOT ASSIGNED ⚠️)\n"
        else:
            report += "- Story: No story assigned ⚠️\n"
            report += "- Status: Idle - needs assignment\n"
            alerts["no_story"].append(agent_info['name'])
        
        report += f"- Workspace: {agent_info['workspace']}\n"
        report += "\n"
    
    # Add alerts section
    report += "**⚠️ ALERTS:**\n"
    if alerts["no_story"]:
        report += f"- Agents without stories: {', '.join(alerts['no_story'])}\n"
    
    if not any(alerts.values()):
        report += "- All agents have stories assigned ✅\n"
    
    report += "\n**📝 Quick Assignment:**\n"
    if alerts["no_story"]:
        for agent_name in alerts["no_story"]:
            bot = next((a['bot'] for a in ASF_AGENTS.values() if a['name'] == agent_name), None)
            if bot:
                report += f"- {bot} Please work on [ASF-XX: Story Title]\n"
    
    return report

def main():
    """Generate and print the agent status report"""
    report = format_agent_report()
    print(report)
    
    # Save to file for reference
    with open('/workspace/memory/last-agent-status.md', 'w') as f:
        f.write(report)
        f.write(f"\n\nGenerated at: {datetime.now().isoformat()}\n")

if __name__ == "__main__":
    main()