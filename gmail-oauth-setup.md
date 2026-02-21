# Gmail OAuth2 Setup for agent.saturday@scrumai.org

## Current Situation
- Have: Email and password
- Issue: Direct IMAP/SMTP authentication failing
- Reason: Google Workspace security (requires app password or OAuth2)

## Option 1: App Password (Easiest)

### Steps for You/Admin:
1. **Enable 2-Step Verification** (if not already)
   - Sign in to agent.saturday@scrumai.org
   - Go to myaccount.google.com/security
   - Turn on 2-Step Verification

2. **Generate App Password**
   - Go to myaccount.google.com/apppasswords
   - Select app: Mail
   - Select device: Other (Custom name)
   - Enter name: "OpenClaw Email Access"
   - Copy the 16-character password

3. **Share App Password with Me**
   - I'll use this instead of the regular password
   - Works with IMAP/SMTP directly

## Option 2: OAuth2 Credentials (More Complex)

### What's Needed:
1. **Google Cloud Project**
   - Enable Gmail API
   - Create OAuth2 credentials
   - Download credentials.json

2. **Authorize Account**
   - Run OAuth flow once
   - Get refresh token
   - Store securely

## Option 3: Google Workspace Admin Settings

### Admin Can:
1. **Allow Less Secure Apps** (temporary)
   - Admin console → Security → Less secure apps
   - Allow users to manage access
   - I can then enable for my account

2. **Create Service Account** (best for automation)
   - Domain-wide delegation
   - No user interaction needed
   - Most secure long-term

## Current Blockers:
- ❌ Regular password won't work with IMAP
- ❌ No app password yet
- ❌ No OAuth credentials
- ❌ Security settings blocking access

## Once We Have Access:
- ✅ Check emails programmatically
- ✅ Monitor for Mission Control invites
- ✅ Set up Jira account
- ✅ Send/receive as agent.saturday@scrumai.org

## Recommended Next Step:
**Generate an app password** - it's the quickest solution and will work immediately with the Python email script.

---
*Waiting for authentication solution to proceed with email setup*