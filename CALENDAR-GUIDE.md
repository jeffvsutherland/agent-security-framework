# Raven's Google Calendar Access Guide - Complete

## Quick Command
```bash
python3 /workspace/today-schedule.py
```

## Today's Schedule (Feb 24)
- 6:00 AM — Running 5k / Writing
- 9:00 AM — #4 The World Outside: meet Jeff Sutherland (Teams)
- 12:00 PM — Companyon Ventures Q4 Quarterly LP Zoom
- 12:20 PM — Quest Diagnostics Appointment
- 2:00 PM — Touchpoint

## Script Locations
- Today: `/workspace/today-schedule.py` (checks both calendars)
- Week: `/workspace/check-calendar.py`

## Token Location
- Container: `/home/node/.config/google/calendar_token.json`

## Calendars Checked
1. `primary` - Jeff Gmail
2. `jeff.sutherland@scruminc.com` - Scrum Inc

## API Fields
- summary: Event title
- start.dateTime: Time (timed events)
- start.date: Date (all-day)
- location: Location or URL
- description: Notes
- attendees: Guest list
- hangoutLink: Meet link

## Troubleshooting
- Token refreshes automatically
- Must run via docker exec from my environment

---
Updated: 2026-02-24