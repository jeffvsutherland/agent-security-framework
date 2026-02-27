# Raven's Google Calendar Access Guide

**Updated: 2026-02-24**
**Status: ✅ WORKING — Calendar access confirmed**

---

## 🌅 Morning Report — Today's Schedule

**This is the #1 use case.** Every morning, Raven runs the today-schedule script to get Jeff's schedule and include it in the Morning Report.

### Run Today's Schedule (PRIMARY COMMAND):

```bash
docker exec openclaw-gateway python3 /workspace/today-schedule.py
```

This checks **both** calendars:
- `primary` — Jeff's Gmail calendar
- `jeff.sutherland@scruminc.com` — Scrum Inc calendar (this is where most meetings live)

It returns: time, title, location, attendees, Meet links, and notes for **today only**.

### Morning Report Format

Include the schedule output in your Morning Report like this:

```
## 🌅 Morning Report — [Date]

### 📅 Today's Schedule
- **6:00 AM** — Running 5k / Writing
- **9:00 AM** — #4 The World Outside: meet Jeff Sutherland (Teams) [Eurobet team]
- **12:00 PM** — Companyon Ventures Q4 Quarterly LP Zoom
- **12:20 PM** — Quest Diagnostics Appointment @ Brighton, MA
- **2:00 PM** — Touchpoint [Scrum Inc team]

### 📧 Email Summary
[use check-email.py]

### 🎯 Today's Priorities
[from Mission Control board]
```

### If the script is missing from the container:
```bash
docker cp /Users/jeffsutherland/clawd/today-schedule.py openclaw-gateway:/workspace/today-schedule.py
```

---

## Quick Reference

| Item | Value |
|---|---|
| **Today's schedule script** | `/workspace/today-schedule.py` |
| **Weekly calendar script** | `/workspace/check-calendar.py` |
| Token location (container) | `/home/node/.config/google/calendar_token.json` |
| Token location (host) | `/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/config/google/calendar_token.json` |
| Scope | `calendar.readonly` (read-only access) |
| Primary calendar | `jeff.sutherland@gmail.com` |
| Scrum Inc calendar | `jeff.sutherland@scruminc.com` |
| Auth type | OAuth2 with refresh token (auto-refreshes) |

---

## How to Check Jeff's Calendar

### Today's schedule (for Morning Report):
```bash
docker exec openclaw-gateway python3 /workspace/today-schedule.py
```

### Full week overview:
```bash
docker exec openclaw-gateway python3 /workspace/check-calendar.py
```

This shows:
- Token validity status
- Events for the next 7 days
- List of all available calendars

### Programmatic access (Python inside container):

```python
import json, datetime
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build

# Load credentials
token_path = '/home/node/.config/google/calendar_token.json'
SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']
creds = Credentials.from_authorized_user_file(token_path, SCOPES)

# Auto-refresh if expired
if not creds.valid and creds.expired and creds.refresh_token:
    creds.refresh(Request())
    with open(token_path, 'w') as f:
        f.write(creds.to_json())

# Build service
service = build('calendar', 'v3', credentials=creds)

# Get today's events
now = datetime.datetime.utcnow()
start = now.replace(hour=0, minute=0, second=0, microsecond=0)
end = start + datetime.timedelta(days=1)

events = service.events().list(
    calendarId='primary',
    timeMin=start.isoformat() + 'Z',
    timeMax=end.isoformat() + 'Z',
    singleEvents=True,
    orderBy='startTime'
).execute().get('items', [])

for e in events:
    time = e['start'].get('dateTime', e['start'].get('date'))
    title = e.get('summary', '(no title)')
    print(f'{time}: {title}')
```

---

## Available Calendars

As of 2026-02-24, Jeff has these calendars accessible:

| Calendar | Description |
|---|---|
| **Jeff Sutherland gmail** | PRIMARY calendar |
| Jens | |
| Financial | |
| Editorial Calendar | |
| revasutherland@gmail.com | |
| Work | |
| PROJECTS Scrum Inc | |
| Family | |
| Holidays in United States | |
| Scrum Inc Delivery | |
| arline.sutherland@scruminc.com | |
| jeff.sutherland@scruminc.com | |
| Scrum Inc. Office Calendar | |

### To query a specific calendar:

Use the calendar's email or ID instead of `'primary'`:
```python
events = service.events().list(
    calendarId='jeff.sutherland@scruminc.com',  # or any calendar ID
    timeMin=start.isoformat() + 'Z',
    timeMax=end.isoformat() + 'Z',
    singleEvents=True,
    orderBy='startTime'
).execute().get('items', [])
```

---

## Useful Queries

### Get today's events only:
```python
start = now.replace(hour=0, minute=0, second=0, microsecond=0)
end = start + datetime.timedelta(days=1)
```

### Get this week's events:
```python
end = start + datetime.timedelta(days=7)
```

### Get events for a specific date:
```python
target = datetime.datetime(2026, 2, 25)
start = target.isoformat() + 'Z'
end = (target + datetime.timedelta(days=1)).isoformat() + 'Z'
```

### Search for events by keyword:
```python
events = service.events().list(
    calendarId='primary',
    q='Scrum',  # search term
    timeMin=start.isoformat() + 'Z',
    singleEvents=True,
    orderBy='startTime'
).execute().get('items', [])
```

---

## Event Data Fields

Each event object contains:

| Field | Example |
|---|---|
| `summary` | "Frequency Scrum" |
| `start.dateTime` | "2026-02-25T10:00:00-05:00" (timed events) |
| `start.date` | "2026-03-01" (all-day events) |
| `end.dateTime` | "2026-02-25T11:00:00-05:00" |
| `location` | "Conference Room" or URL |
| `description` | Event notes/description |
| `attendees` | List of attendee emails |
| `hangoutLink` | Google Meet link if present |
| `htmlLink` | Link to view event in Google Calendar |

---

## Troubleshooting

### Token expired?
The script auto-refreshes. If it fails:
```bash
docker exec openclaw-gateway python3 -c "
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
creds = Credentials.from_authorized_user_file('/home/node/.config/google/calendar_token.json')
print('Valid:', creds.valid, 'Expired:', creds.expired)
if creds.expired and creds.refresh_token:
    creds.refresh(Request())
    with open('/home/node/.config/google/calendar_token.json', 'w') as f:
        f.write(creds.to_json())
    print('REFRESHED')
"
```

### Import errors?
Required packages are pre-installed in the gateway:
- `google-api-python-client`
- `google-auth-httplib2`
- `google-auth-oauthlib`

### Container not running?
```bash
docker ps | grep openclaw-gateway
# If not running:
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml up -d openclaw
```

---

## Limitations

- **Read-only access** — cannot create, modify, or delete events
- **OAuth scope**: `calendar.readonly` only
- **Token auto-refreshes** but the refresh token could expire if unused for extended periods (rare with Google)
- **Runs inside Docker** — must execute via `docker exec openclaw-gateway`

---

## Quick One-Liner: "What's on Jeff's calendar today?"

```bash
docker exec openclaw-gateway python3 -c "
import datetime
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
creds = Credentials.from_authorized_user_file('/home/node/.config/google/calendar_token.json', ['https://www.googleapis.com/auth/calendar.readonly'])
if not creds.valid and creds.expired and creds.refresh_token:
    creds.refresh(Request())
service = build('calendar', 'v3', credentials=creds)
now = datetime.datetime.utcnow()
start = now.replace(hour=0,minute=0,second=0,microsecond=0)
end = start + datetime.timedelta(days=1)
events = service.events().list(calendarId='primary',timeMin=start.isoformat()+'Z',timeMax=end.isoformat()+'Z',singleEvents=True,orderBy='startTime').execute().get('items',[])
print(f'Today ({now.strftime(\"%Y-%m-%d\")}): {len(events)} events')
for e in events:
    t = e['start'].get('dateTime',e['start'].get('date'))
    print(f'  {t}: {e.get(\"summary\",\"(no title)\")}')
if not events: print('  No events today')
"
```

