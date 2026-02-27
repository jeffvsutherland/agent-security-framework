#!/usr/bin/env python3
"""
Enhanced Google Calendar checker that includes all work calendars
"""

import datetime
import os
import pytz
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

# Calendars to check for meetings
WORK_CALENDARS = [
    'primary',  # jeff.sutherland@gmail.com
    'jeff.sutherland@scruminc.com',
    'scruminc.com_pbbrnrhc0m9ncv1bdhj2gupago@group.calendar.google.com',  # Scrum Inc Delivery
    'pqmcrmij2u6o7j5p8vppjdln54@group.calendar.google.com',  # PROJECTS Scrum Inc
]

def get_google_calendar_service():
    """Get authenticated Google Calendar service"""
    creds = None
    
    token_path = os.path.expanduser('~/.config/google/calendar_token.json')
    credentials_path = os.path.expanduser('~/.config/google/calendar_credentials.json')
    
    os.makedirs(os.path.dirname(token_path), exist_ok=True)
    
    if os.path.exists(token_path):
        creds = Credentials.from_authorized_user_file(token_path, SCOPES)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            try:
                creds.refresh(Request())
            except Exception as e:
                return None
        else:
            if not os.path.exists(credentials_path):
                return None
            
            try:
                flow = InstalledAppFlow.from_client_secrets_file(credentials_path, SCOPES)
                creds = flow.run_local_server(port=0)
            except Exception as e:
                return None
        
        with open(token_path, 'w') as token:
            token.write(creds.to_json())
    
    try:
        service = build('calendar', 'v3', credentials=creds)
        return service
    except Exception as e:
        return None

def get_todays_events():
    """Get today's calendar events from all work calendars"""
    service = get_google_calendar_service()
    if not service:
        return []
    
    # Get timezone info
    et_tz = pytz.timezone('US/Eastern')
    utc_tz = pytz.UTC
    
    # Get today's range in ET
    now_et = datetime.datetime.now(et_tz)
    start_of_day_et = now_et.replace(hour=0, minute=0, second=0, microsecond=0)
    end_of_day_et = start_of_day_et + datetime.timedelta(days=1)
    
    # Convert to UTC for API
    start_utc = start_of_day_et.astimezone(utc_tz)
    end_utc = end_of_day_et.astimezone(utc_tz)
    
    all_events = []
    
    # Check each work calendar
    for cal_id in WORK_CALENDARS:
        try:
            events_result = service.events().list(
                calendarId=cal_id,
                timeMin=start_utc.isoformat(),
                timeMax=end_utc.isoformat(),
                singleEvents=True,
                orderBy='startTime',
                maxResults=50
            ).execute()
            
            events = events_result.get('items', [])
            
            for event in events:
                summary = event.get('summary', 'No title')
                
                # Skip 6am running/writing story
                if 'running' in summary.lower() and 'writing' in summary.lower():
                    continue
                
                # Get start time
                start = event['start'].get('dateTime', event['start'].get('date'))
                if 'T' in start:  # DateTime format
                    start_dt = datetime.datetime.fromisoformat(start.replace('Z', '+00:00'))
                    start_et = start_dt.astimezone(et_tz)
                    time_str = start_et.strftime("%I:%M %p").lstrip('0')
                    sort_key = start_et
                else:  # All-day event
                    time_str = "All day"
                    sort_key = start_of_day_et
                
                # Check if we already have this event (avoid duplicates)
                event_key = f"{time_str}-{summary}"
                if not any(e['key'] == event_key for e in all_events):
                    all_events.append({
                        'time': time_str,
                        'title': summary,
                        'start_raw': start,
                        'sort_key': sort_key,
                        'key': event_key
                    })
        
        except HttpError as error:
            # Silently skip calendars we can't access
            pass
        except Exception as error:
            pass
    
    # Sort events by time
    all_events.sort(key=lambda x: x['sort_key'])
    
    return all_events

def format_events_for_heartbeat(events):
    """Format events for morning briefing"""
    today = datetime.date.today().strftime("%A, %B %d, %Y")
    
    output = f"📅 **Today's Schedule - {today}**\n\n"
    
    if not events:
        output += "📋 **No meetings scheduled for today**\n"
    else:
        output += "**Today's Meetings:**\n"
        for event in events:
            output += f"• **{event['time']}** - {event['title']}\n"
    
    # Add our daily scrum
    output += "\n🏃‍♂️ **Daily Scrum with AgentSaturday** - Security Framework Sprint\n"
    
    return output

if __name__ == "__main__":
    events = get_todays_events()
    formatted = format_events_for_heartbeat(events)
    print(formatted)