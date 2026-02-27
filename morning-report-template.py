#!/usr/bin/env python3
"""
Generate comprehensive morning report with agent status.
Run at 7:00 AM ET daily.
"""
import subprocess
import json
from datetime import datetime, timezone
import pytz

def get_et_time():
    et = pytz.timezone('US/Eastern')
    return datetime.now(et)

def get_market_data():
    """Get latest market prices"""
    try:
        result = subprocess.run(['python3', '/workspace/get-prices.py'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    return "Market data unavailable"

def get_calendar_events():
    """Get today's calendar events"""
    try:
        result = subprocess.run(['python3', '/workspace/get-calendar-google.py'],
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    return "Calendar data unavailable"

def get_agent_status():
    """Get status of all ASF agents"""
    try:
        result = subprocess.run(['python3', '/workspace/check-agent-status.py'],
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            return result.stdout.strip()
    except:
        pass
    return "Agent status unavailable"

def get_email_summary():
    """Check for urgent emails"""
    try:
        result = subprocess.run(['python3', '/workspace/get-email-ff.py', '--recent', '10'],
                              capture_output=True, text=True, timeout=15)
        if result.returncode == 0:
            # Parse for urgent items
            lines = result.stdout.split('\n')
            urgent = [l for l in lines if any(word in l.lower() for word in ['urgent', 'asap', 'critical', 'important'])]
            return f"{len(urgent)} potentially urgent items" if urgent else "No urgent emails"
    except:
        pass
    return "Email check unavailable"

def get_sprint_status():
    """Get current sprint information"""
    # Read from heartbeat state
    try:
        with open('/workspace/memory/heartbeat-state.json', 'r') as f:
            state = json.load(f)
            sprint = state.get('sprintStatus', {}).get('asf_sprint_2', {})
            return {
                'name': 'ASF Sprint 2',
                'day': 'Day 4 of 7',
                'completed': len(sprint.get('completed', [])),
                'pending': sprint.get('pending', []),
                'velocity': state.get('sprintStatus', {}).get('asf_sprint_1', {}).get('velocity', 21)
            }
    except:
        pass
    return None

def generate_morning_report():
    """Generate the complete morning report"""
    now = get_et_time()
    day = now.strftime('%A')
    date = now.strftime('%Y-%m-%d')
    
    report = f"""📅 Good Morning Jeff! Here's your {day} briefing (7:00 AM ET):
Date: {date}

## 🤖 ASF AGENT STATUS
{get_agent_status()}

## 📊 Market Update
{get_market_data()}

## 🎯 Sprint Status
"""
    
    sprint = get_sprint_status()
    if sprint:
        report += f"""**{sprint['name']} ({sprint['day']})**
- Completed: {sprint['completed']} stories
- Pending: {', '.join(sprint['pending']) if sprint['pending'] else 'None'}
- Velocity: {sprint['velocity']} points (Sprint 1)

**Today's #1 Priority:** Complete Discord bot deployment and ensure all agents are working on assigned stories
"""
    
    report += f"""
## 📅 Today's Schedule
{get_calendar_events()}

## 📧 Email Status
{get_email_summary()}

## ⚠️ Key Alerts
- ASF Sprint 2: Day 4 of 7 - Need to accelerate delivery
- OpenClaw vulnerability disclosure still pending
- Moltbook ASF comment still at 0 upvotes after 13+ hours

## 🎯 Top 3 Priorities for Today
1. Spawn all ASF agents and assign Jira stories
2. Complete Discord bot deployment (ASF-27)
3. Submit OpenClaw vulnerability report through official channels

---
*Hourly agent checks active - Next check at 8:00 AM ET*
"""
    
    return report

if __name__ == "__main__":
    print(generate_morning_report())