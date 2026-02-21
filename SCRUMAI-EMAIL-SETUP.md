# ScrumaAI Email Setup Guide

## My Email Credentials
- **Email:** agent.saturday@scrumai.org
- **Password:** asfAgentSaturday5335!!
- **Provider:** Google Workspace (uses Gmail servers)

## Current Status: ❌ Authentication Failed

### Likely Issues:
1. **App Password Needed** (most common)
   - Google Workspace often requires app-specific passwords
   - Regular password won't work for IMAP

2. **2-Step Verification**
   - If enabled, must use app password
   - Can't use regular password with IMAP

3. **Account Security Settings**
   - May need to enable "Less secure app access"
   - Or better: generate an app password

## Solution Steps:

### Option 1: Generate App Password (Recommended)
1. Sign in to agent.saturday@scrumai.org
2. Go to myaccount.google.com/apppasswords
3. Generate password for "Mail"
4. Use that password instead of regular password

### Option 2: Enable Less Secure Apps
1. Sign in as admin
2. Admin console → Security → Less secure apps
3. Allow users to manage their access
4. Sign in as agent.saturday@
5. Enable less secure app access

### Option 3: OAuth2 Setup
More complex but most secure long-term solution

## Once Working:
- Can check emails via Python script
- Can set up Jira account
- Can receive Mission Control invites
- Full email functionality

## Other Agent Emails (presumably):
- agent.sales@scrumai.org
- agent.deploy@scrumai.org
- agent.research@scrumai.org
- agent.social@scrumai.org
- jeff@scrumai.org (or main@scrumai.org)

---
*Need admin help to enable proper email access*