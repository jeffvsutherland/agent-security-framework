# Google Calendar Integration Needed

## Current Status
The Docker container cannot access jeff.sutherland@scruminc.com calendar due to missing Google OAuth credentials.

## To Enable Calendar Access:

### Option 1: Manual OAuth Setup
1. Visit https://console.developers.google.com/
2. Create new project (or select existing)
3. Enable Google Calendar API
4. Create OAuth 2.0 credentials
5. Download credentials.json
6. Save as: `/home/node/.config/google/calendar_credentials.json`
7. Run: `python3 get-calendar-google.py` to complete OAuth flow

### Option 2: Service Account (Recommended for automation)
1. Create service account in Google Cloud Console
2. Grant calendar access to service account email
3. Download service account JSON key
4. Configure in calendar script

### Option 3: Use Host Machine
Run calendar scripts from your host machine where Google access may already be configured.

## Temporary Workaround
For now, I can only see cached calendar data:
- Last known meeting: 10:00 AM Frequency Scrum (from yesterday)
- Daily Scrum with AgentSaturday continues

## What I Need to See Your Calendar:
- Google Calendar API credentials
- OAuth authentication completed
- Or access from environment with existing Google auth