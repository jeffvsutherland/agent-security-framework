#!/usr/bin/env python3
"""
Working calendar checker - minimal approach
"""

import subprocess
import datetime

def get_calendar_simple():
    """Simple calendar check that actually works"""
    
    # Very basic AppleScript - just check if we can get any events
    script = '''
    tell application "Calendar"
        try
            set today to (current date)
            set startOfToday to today - (time of today)
            set endOfToday to startOfToday + (24 * hours)
            
            set eventCount to 0
            set eventText to ""
            
            -- Check Work calendar first
            try
                set workCal to calendar "Work"
                set workEvents to events of workCal whose start date ≥ startOfToday and start date < endOfToday
                repeat with evt in workEvents
                    set eventCount to eventCount + 1
                    set eventText to eventText & "• " & (summary of evt) & return
                end repeat
            end try
            
            -- Check gmail calendar 
            try
                set gmailCal to calendar "jeff.sutherland@gmail.com"
                set gmailEvents to events of gmailCal whose start date ≥ startOfToday and start date < endOfToday
                repeat with evt in gmailEvents
                    set eventCount to eventCount + 1
                    set eventText to eventText & "• " & (summary of evt) & return
                end repeat
            end try
            
            if eventCount > 0 then
                return eventText
            else
                return "No meetings found in primary calendars"
            end if
            
        on error errMsg
            return "Calendar error: " & errMsg
        end try
    end tell
    '''
    
    try:
        result = subprocess.run(['osascript', '-e', script], 
                              capture_output=True, text=True, check=True, timeout=8)
        
        return result.stdout.strip()
        
    except Exception as e:
        return f"Script error: {e}"

if __name__ == "__main__":
    today = datetime.date.today().strftime("%A, %B %d, %Y")
    print(f"📅 **Today's Schedule - {today}**")
    
    events = get_calendar_simple()
    print(f"\n{events}")
    
    print("\n🏃‍♂️ **Daily Scrum with AgentSaturday** - Security Framework Sprint")