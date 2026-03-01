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

def get_moltbook_trending():
    """Get Moltbook trending status for ASF"""
    try:
        import os
        memory_dir = '/workspace/agents/product-owner/memory'
        
        trending_info = []
        if os.path.exists(memory_dir):
            for f in sorted(os.listdir(memory_dir))[-3:]:
                if f.endswith('.md'):
                    with open(os.path.join(memory_dir, f), 'r') as file:
                        content = file.read()
                        for line in content.split('\n'):
                            if 'moltbook' in line.lower() or 'upvot' in line.lower():
                                if len(line) > 20 and len(line) < 150:
                                    trending_info.append(line.strip())
        
        if trending_info:
            return "📱 **Moltbook Trending:**\n" + "\n".join([f"• {t[:80]}" for t in trending_info[:3]])
        
        return "📱 **Moltbook:** No trending data - check manually"
    except:
        return "📱 **Moltbook:** Check manually at moltbook.com"

def get_sprint_status():
    """Get current sprint information"""
    # Read from heartbeat state
    try:
        with open('/workspace/memory/heartbeat-state.json', 'r') as f:
            state = json.load(f)
            sprint = state.get('sprintStatus', {}).get('asf_sprint_2', {})
            return {
                'name': 'ASF Daily Sprint',
                'day': 'Daily Sprint - ' + datetime.now().strftime('%Y-%m-%d'),
                'completed': len(sprint.get('completed', [])),
                'pending': sprint.get('pending', []),
                'velocity': state.get('sprintStatus', {}).get('asf_sprint_1', {}).get('velocity', 21)
            }
    except:
        pass
    return None


def get_yesterday_completed():
    """Get stories completed yesterday for IRS documentation"""
    try:
        # Use curl directly with agent token
        board_id = "24394a90-a74e-479c-95e8-e5d24c7b4a40"
        token = "WeWnFbK9IoknRjXFPGsV-xHlgGJkXZNcfgltKCQasFQ"
        url = f"http://host.docker.internal:8001/api/v1/agent/boards/{board_id}/tasks"
        
        result = subprocess.run(
            ['curl', '-s', '-H', f'Authorization: Bearer {token}', url],
            capture_output=True, text=True, timeout=15
        )
        if result.returncode != 0:
            return "MC API unavailable"
        
        data = json.loads(result.stdout)
        from datetime import timedelta
        yesterday = (datetime.now(timezone.utc) - timedelta(days=1)).date()
        
        completed = []
        total_points = 0
        for task in data.get('items', []):
            if task.get('status') == 'done' and task.get('story_points'):
                # Use created_at as completion date proxy - only include ones with points assigned
                created = task.get('created_at', '')
                if created:
                    created_date = datetime.fromisoformat(created.replace('Z', '+00:00')).date()
                    # Only show previous day for IRS
                    if created_date == yesterday:
                        points = task.get('story_points', 0) or 0
                        title = task.get('title', '')[:55]
                        # Get more description for IRS
                        desc = task.get('description', '')[:120].replace('\n', ' ').strip()
                        # Extract just the ID part, not the full title
                        if '[' in title:
                            asf_id = title.split('[')[1].split(']')[0]
                        else:
                            asf_id = 'ASF'
                        completed.append(f"• {asf_id} ({points} pts)\n   {title}\n   Deliverable: {desc}")
                        total_points += points
        
        if not completed:
            # Show all completed stories with full details for IRS
            recent = []
            total = 0
            for task in data.get('items', []):
                if task.get('status') == 'done' and task.get('story_points', 0):
                    points = task.get('story_points', 0)
                    title = task.get('title', '')[:55]
                    created = task.get('created_at', '')[:10]
                    desc = task.get('description', '')[:150].replace('\n', ' ').strip()
                    
                    # Extract ASF ID - avoid duplicates
                    asf_id = 'ASF'
                    if '[' in title:
                        try:
                            part = title.split('[')[1].split(']')[0]
                            # Avoid duplicating like "[ASF-44] [ASF-44]"
                            if 'ASF' in part and 'ASF' not in asf_id:
                                asf_id = part
                            elif 'ASF' not in part:
                                asf_id = part
                        except:
                            pass
                    
                    recent.append(f"**{asf_id}** ({points} pts) - {created}\n   {title}\n   Deliverable: {desc}")
                    total += points
            
            if recent:
                return "**IRS: Completed Stories with Details:**\n\n" + "\n\n".join(recent) + f"\n\n**TOTAL POINTS: {total}**"
            return "No completed stories with points found"
        
        return f"**Yesterday's Completed Stories ({yesterday}):**\n" + "\n".join(completed) + f"\n\n**Total: {len(completed)} stories, {total_points} points**"
    except Exception as e:
        return f"Unable to fetch: {e}"

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

**Today's #1 Priority:** Complete website deployment stories (ASF-46, ASF-47, ASF-48)
"""
    
    report += f"""
## 📅 Today's Schedule
{get_calendar_events()}

## 📋 IRS Documentation (Previous Day)
{get_yesterday_completed()}

## 📧 Email Status
{get_email_summary()}

## 📱 Moltbook Trending
{get_moltbook_trending()}

## ⚠️ Key Alerts
- Daily Sprint: Need to complete stories for website deployment
- OpenClaw vulnerability disclosure still pending

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