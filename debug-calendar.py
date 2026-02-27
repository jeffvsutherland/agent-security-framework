#!/usr/bin/env python3
"""
Debug version of Google Calendar checker to find missing meetings
"""

import datetime
import os
import sys
import pytz
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

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
                print(f"Token refresh failed: {e}")
                return None
        else:
            if not os.path.exists(credentials_path):
                print("❌ Google Calendar credentials not found!")
                return None
            
            try:
                flow = InstalledAppFlow.from_client_secrets_file(credentials_path, SCOPES)
                creds = flow.run_local_server(port=0)
            except Exception as e:
                print(f"OAuth flow failed: {e}")
                return None
        
        with open(token_path, 'w') as token:
            token.write(creds.to_json())
    
    try:
        service = build('calendar', 'v3', credentials=creds)
        return service
    except Exception as e:
        print(f"Failed to build calendar service: {e}")
        return None

def debug_calendars():
    """Debug all calendars and events"""
    service = get_google_calendar_service()
    if not service:
        return
    
    print("🔍 DEBUG: Calendar Investigation\n")
    
    # Get list of all calendars
    try:
        calendar_list = service.calendarList().list().execute()
        calendars = calendar_list.get('items', [])
        
        print(f"📅 Found {len(calendars)} calendars:")
        for cal in calendars:
            print(f"  - {cal['summary']} (ID: {cal['id']})")
            if cal.get('primary'):
                print("    ^ PRIMARY CALENDAR")
        print()
        
    except Exception as e:
        print(f"Error listing calendars: {e}")
        return
    
    # Get timezone info
    et_tz = pytz.timezone('US/Eastern')
    utc_tz = pytz.UTC
    
    # Get today's events in ET
    now_et = datetime.datetime.now(et_tz)
    start_of_day_et = now_et.replace(hour=0, minute=0, second=0, microsecond=0)
    end_of_day_et = start_of_day_et + datetime.timedelta(days=1)
    
    # Convert to UTC for API
    start_utc = start_of_day_et.astimezone(utc_tz)
    end_utc = end_of_day_et.astimezone(utc_tz)
    
    print(f"🕐 Time Debug:")
    print(f"  Current time ET: {now_et.strftime('%I:%M %p ET')}")
    print(f"  Searching from: {start_of_day_et.strftime('%Y-%m-%d %I:%M %p ET')}")
    print(f"  Searching to: {end_of_day_et.strftime('%Y-%m-%d %I:%M %p ET')}")
    print(f"  UTC range: {start_utc.isoformat()} to {end_utc.isoformat()}")
    print()
    
    # Check each calendar for events
    for cal in calendars[:3]:  # Check first 3 calendars
        cal_id = cal['id']
        cal_name = cal['summary']
        
        print(f"📋 Checking calendar: {cal_name}")
        
        try:
            events_result = service.events().list(
                calendarId=cal_id,
                timeMin=start_utc.isoformat(),
                timeMax=end_utc.isoformat(),
                singleEvents=True,
                orderBy='startTime',
                maxResults=20
            ).execute()
            
            events = events_result.get('items', [])
            
            if not events:
                print("  No events today")
            else:
                print(f"  Found {len(events)} events:")
                for event in events:
                    summary = event.get('summary', 'No title')
                    start = event['start'].get('dateTime', event['start'].get('date'))
                    
                    if 'T' in start:
                        start_dt = datetime.datetime.fromisoformat(start.replace('Z', '+00:00'))
                        start_et = start_dt.astimezone(et_tz)
                        time_str = start_et.strftime("%I:%M %p ET").lstrip('0')
                    else:
                        time_str = "All day"
                    
                    print(f"    • {time_str} - {summary}")
                    
                    # Check if this is the missing Newfire meeting
                    if 'newfire' in summary.lower() or 'webteam' in summary.lower():
                        print("      ⚠️ FOUND NEWFIRE MEETING!")
        
        except Exception as e:
            print(f"  Error: {e}")
        
        print()

if __name__ == "__main__":
    debug_calendars()