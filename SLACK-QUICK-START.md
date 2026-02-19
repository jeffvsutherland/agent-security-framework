# ASF Slack Setup - Quick Start Guide

## 🚀 Get Running in 30 Minutes

### Step 1: Create Slack Workspace (5 min)
1. Go to https://slack.com/create
2. Create workspace: `asf-team` or similar
3. Create channels:
   - `#general` (default)
   - `#mission-control`
   - `#jira-updates`
   - `#heartbeats`

### Step 2: Create Slack App (10 min)
1. Go to https://api.slack.com/apps
2. Click "Create New App"
3. Choose "From scratch"
4. Name: "OpenClaw ASF Bot"
5. Select your workspace

### Step 3: Configure Bot Permissions (5 min)
Add OAuth Scopes:
- `channels:history` - Read messages
- `channels:read` - List channels
- `chat:write` - Send messages
- `reactions:write` - Add reactions
- `pins:write` - Pin messages
- `users:read` - Get user info

### Step 4: Install App & Get Token (5 min)
1. Click "Install to Workspace"
2. Authorize permissions
3. Copy the Bot User OAuth Token (starts with `xoxb-`)

### Step 5: Update OpenClaw Config (5 min)
Edit each agent's config to enable Slack:

```json
"channels": {
  "slack": {
    "enabled": true,
    "mode": "socket",
    "botToken": "xoxb-YOUR-TOKEN-HERE",
    "groupPolicy": "allowlist",
    "groups": {
      "YOUR-CHANNEL-ID": {
        "enabled": true
      }
    }
  }
}
```

### Step 6: Get Channel IDs
In Slack:
1. Right-click channel name
2. View channel details
3. Copy Channel ID at bottom

### Step 7: Test It!
From any agent:
```json
slack action="sendMessage" to="channel:C123ABC" content="Agent Saturday reporting for duty! 🦅"
```

## 🎯 That's it! All agents can now communicate in Slack!

---
*Time to coordinate at machine speed!*