#!/usr/bin/env python3
"""
Simple calendar placeholder for morning heartbeat
Until we fix Calendar app permissions/access
"""

import datetime

def get_calendar_placeholder():
    """Placeholder calendar check"""
    today = datetime.date.today().strftime("%A, %B %d, %Y")
    
    return f"""📅 **Today's Schedule - {today}**

⚠️ Calendar integration in progress - please check manually:
• Review your calendar for today's meetings  
• **Daily Scrum with AgentSaturday** - Security Framework Sprint
• Any prep needed for upcoming meetings?

💡 *Note: Excluding 6am running/writing story as requested*
"""

if __name__ == "__main__":
    print(get_calendar_placeholder())