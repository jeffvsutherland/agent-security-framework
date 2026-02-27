#!/usr/bin/env python3
"""
Find the Newfire webteam meeting across all calendars
"""

import datetime
import os
import pytz
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build

SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']

def get_calendar_service():
    creds = None
    token_path = os.path.expanduser('~/.config/google/calendar_token.json')
    
    if os.path.exists(token_path):
        creds = Credentials.from_authorized_user_file(token_path, SCOPES)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
    
    return build('calendar', 'v3', credentials=creds)

def find_newfire_meeting():
    service = get_calendar_service()
    
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
    
    print(f"🔍 Searching for Newfire/webteam meeting on {start_of_day_et.strftime('%A, %B %d, %Y')}\n")
    
    # Get all calendars
    calendar_list = service.calendarList().list().execute()
    calendars = calendar_list.get('items', [])
    
    found_meetings = []
    
    # Check each calendar
    for cal in calendars:
        cal_id = cal['id']
        cal_name = cal['summary']
        
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
                summary = event.get('summary', '').lower()
                
                # Check if this might be the Newfire meeting
                if any(keyword in summary for keyword in ['newfire', 'webteam', 'web team', '9:00', '9am']):
                    start = event['start'].get('dateTime', event['start'].get('date'))
                    if 'T' in start:
                        start_dt = datetime.datetime.fromisoformat(start.replace('Z', '+00:00'))
                        start_et = start_dt.astimezone(et_tz)
                        time_str = start_et.strftime("%I:%M %p ET").lstrip('0')
                        
                        # Check if it's around 9 AM
                        if start_et.hour == 9 or '9' in event.get('summary', ''):
                            found_meetings.append({
                                'calendar': cal_name,
                                'calendar_id': cal_id,
                                'time': time_str,
                                'title': event.get('summary', 'No title'),
                                'is_primary': cal.get('primary', False)
                            })
        
        except Exception as e:
            pass
    
    # Also check for ANY 9 AM meetings
    print("📋 All 9 AM meetings across all calendars:")
    
    for cal in calendars:
        cal_id = cal['id']
        cal_name = cal['summary']
        
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
                start = event['start'].get('dateTime', event['start'].get('date'))
                if 'T' in start:
                    start_dt = datetime.datetime.fromisoformat(start.replace('Z', '+00:00'))
                    start_et = start_dt.astimezone(et_tz)
                    
                    if start_et.hour == 9:
                        print(f"\n✅ Found 9 AM meeting!")
                        print(f"   Calendar: {cal_name}")
                        print(f"   Title: {event.get('summary', 'No title')}")
                        print(f"   Time: {start_et.strftime('%I:%M %p ET')}")
                        print(f"   Is Primary Calendar: {'Yes' if cal.get('primary') else 'No'}")
        
        except Exception as e:
            pass
    
    return found_meetings

if __name__ == "__main__":
    meetings = find_newfire_meeting()
    
    if meetings:
        print("\n🎯 FOUND NEWFIRE/WEBTEAM MEETINGS:")
        for meeting in meetings:
            print(f"\n📅 {meeting['title']}")
            print(f"   Time: {meeting['time']}")
            print(f"   Calendar: {meeting['calendar']}")
            print(f"   Primary: {'Yes' if meeting['is_primary'] else 'No'}")