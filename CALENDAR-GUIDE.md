# Raven's Google Calendar Access Guide

## Quick Reference

| Item | Value |
|------|-------|
| Script | python3 /workspace/check-calendar.py |
| Token | /home/node/.config/google/calendar_token.json |
| Scope | calendar.readonly |

## Check Calendar

```bash
python3 /workspace/check-calendar.py
```

## Today's Events (Feb 24, 2026)
- Wed 10am: Frequency Scrum
- Fri 10am: Frequency Scrum
- Sun Mar 1: Mass Annual Report
- Mon Mar 2: Frequency Scrum

## Available Calendars (13)
- Jeff Sutherland gmail (PRIMARY)
- Jens
- Financial
- Work
- PROJECTS Scrum Inc
- Family
- Holidays in United States
- Scrum Inc Delivery
- And more...

## Query Specific Calendar

```python
# Use calendarId instead of 'primary'
events = service.events().list(
    calendarId='jeff.sutherland@scruminc.com',
    timeMin=start.isoformat() + 'Z',
    timeMax=end.isoformat() + 'Z',
    singleEvents=True,
    orderBy='startTime'
).execute().get('items', [])
```

---
Updated: 2026-02-24