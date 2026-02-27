#!/usr/bin/env python3
"""
Calendar checker for morning heartbeat - gets today's events
Excludes 6am running/writing story as requested
"""

import subprocess
import datetime

def get_todays_events():
    """Get today's calendar events using simple osascript approach"""
    
    # Simplified AppleScript to get today's events
    script = '''
    tell application "Calendar"
        set todayStart to (current date) - (time of (current date))
        set todayEnd to todayStart + (24 * hours) - 1
        
        set eventText to ""
        repeat with cal in calendars
            try
                set calEvents to events of cal whose start date ≥ todayStart and start date ≤ todayEnd
                repeat with evt in calEvents
                    set eventText to eventText & (summary of evt) & "|||" & (start date of evt as string) & "\\n"
                end repeat
            end try
        end repeat
        
        return eventText
    end tell
    '''
    
    try:
        result = subprocess.run(['osascript', '-e', script], 
                              capture_output=True, text=True, check=True, timeout=10)
        
        events = []
        if result.stdout.strip():
            lines = result.stdout.strip().split('\\n')
            for line in lines:
                if '|||' in line and line.strip():
                    parts = line.split('|||')
                    if len(parts) >= 2:
                        title = parts[0].strip()
                        date_time = parts[1].strip()
                        
                        # Skip the 6am running/writing story
                        if ("running" in title.lower() and "writing" in title.lower()) or "6:00 AM" in date_time:
                            continue
                            
                        # Extract time
                        time_part = "TBD"
                        if " at " in date_time:
                            time_part = date_time.split(" at ")[1]
                        
                        events.append({
                            'title': title,
                            'time': time_part,
                            'raw_date': date_time
                        })
        
        return events
        
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired) as e:
        print(f"Error getting calendar events: {e}")
        # Return a fallback message
        return [{'title': 'Calendar check failed', 'time': 'Check manually', 'raw_date': ''}]

def format_events_for_heartbeat(events):
    """Format events for morning briefing"""
    if not events:
        return "📅 **No meetings scheduled for today**"
    
    output = "📅 **Today's Meetings:**\n"
    
    # Sort by time if possible
    for event in events:
        time_str = event['time']
        title = event['title']
        
        output += f"• **{time_str}** - {title}\n"
    
    # Add our daily scrum
    output += "\n🏃‍♂️ **Daily Scrum with AgentSaturday** (as requested)\n"
    
    return output

if __name__ == "__main__":
    events = get_todays_events()
    formatted = format_events_for_heartbeat(events)
    print(formatted)