# iOS Shortcut for Ray-Ban Meta → Clawdbot

## Setup Instructions

### 1. Install Shortcuts

Create these shortcuts on your iPhone:

### Shortcut 1: "Send to Clawdbot"

```
1. Get Latest Photos (1)
2. Get Contents of URL
   - URL: http://your-mac.local:8180/api/upload
   - Method: POST
   - Headers: 
     - Authorization: Bearer [your-token]
   - Request Body: File
3. Get Contents from Input
4. Speak Text (reads Clawdbot's response)
```

### Shortcut 2: "Auto-Monitor Glasses"

```
1. Repeat with Each (Photos from Last 5 Minutes)
2. If (Photo source = "Meta View")
   - Run Shortcut "Send to Clawdbot"
3. Wait (5 seconds)
4. Run Shortcut "Auto-Monitor Glasses" (loops)
```

### 2. Automation Setup

In Shortcuts app → Automation:

**Trigger**: When App Opens (Meta View)
**Action**: Run "Auto-Monitor Glasses"

### 3. Voice Integration

In Meta View app settings:
- Enable voice commands
- Say "Hey Meta, send to assistant" 
- This triggers screenshot → gallery → our automation

### 4. Background Processing

For continuous monitoring:
1. Use "Shortcuts" personal automation
2. Time-based trigger every 5 minutes
3. Check for new Meta View photos
4. Process automatically

## Quick Actions

### Taking a Photo
1. "Hey Meta, take a photo"
2. Auto-syncs to phone
3. Shortcut detects and sends to Clawdbot
4. Response spoken through phone

### Recording Video  
1. "Hey Meta, record video"
2. Stop recording
3. Processes when saved to gallery
4. Summary returned via TTS

## Privacy Note

- Photos only sent to YOUR Clawdbot
- Processed locally on your gateway
- No cloud storage unless you configure it