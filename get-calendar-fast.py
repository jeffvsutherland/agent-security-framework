#!/usr/bin/env python3
"""
Fast calendar checker - gets today's events from primary calendars only
"""

import subprocess
import datetime

def get_todays_events_fast():
    """Get today's calendar events using a faster approach"""
    
    # More efficient AppleScript - just get today's events
    script = '''
    tell application "Calendar"
        set todayStart to (current date) - (time of (current date))
        set todayEnd to todayStart + (24 * hours)
        
        set eventList to {}
        set primaryCals to {"Work", "jeff.sutherland@scruminc.com", "jeff.sutherland@gmail.com"}
        
        repeat with calName in primaryCals
            try
                set cal to calendar calName
                set calEvents to events of cal whose start date ≥ todayStart and start date < todayEnd
                repeat with evt in calEvents
                    set end of eventList to (summary of evt) & " at " & (time string of start date of evt)
                end repeat
            end try
        end repeat
        
        return my joinList(eventList, "\\n")
    end tell
    
    on joinList(lst, delim)
        set retVal to ""
        repeat with i from 1 to length of lst
            set retVal to retVal & item i of lst
            if i < length of lst then set retVal to retVal & delim
        end repeat
        return retVal
    end joinList
    '''
    
    try:
        result = subprocess.run(['osascript', '-e', script], 
                              capture_output=True, text=True, check=True, timeout=5)
        
        events = []
        if result.stdout.strip():
            lines = result.stdout.strip().split('\\n')
            for line in lines:
                if line.strip():
                    # Skip 6am running/writing
                    if ("running" in line.lower() and "writing" in line.lower()) or "6:00:00 AM" in line:
                        continue
                    events.append(line.strip())
        
        return events
        
    except Exception as e:
        print(f"Calendar error: {e}")
        return ["Manual calendar check needed"]

if __name__ == "__main__":
    events = get_todays_events_fast()
    
    today = datetime.date.today().strftime("%A, %B %d, %Y")
    print(f"📅 **Today's Schedule - {today}**\\n")
    
    if events and events[0] != "Manual calendar check needed":
        print("**Today's Meetings:**")
        for event in events:
            print(f"• {event}")
        print("\\n🏃‍♂️ **Daily Scrum with AgentSaturday** - Security Framework Sprint")
    else:
        print("⚠️ Calendar check needed - please review manually:")
        print("• Check for today's critical meetings")
        print("• **Daily Scrum with AgentSaturday** - Security Framework Sprint")
        print("• Any prep needed for upcoming meetings?")