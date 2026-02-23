# Ray-Ban Meta → Clawdbot Bridge

## Overview

Use your phone as a bridge to connect Ray-Ban Meta glasses to Clawdbot. The glasses connect to your phone via Bluetooth/Meta View app, and your phone forwards the data to Clawdbot.

### Two Modes Available:

1. **Photo/Video Analysis** - Automatic processing of captures
2. **Conversation Mode** 🆕 - Full dialogue through glasses

## Architecture

```
Ray-Ban Meta Glasses
    ↓ (Bluetooth)
Phone (iOS/Android)
    ↓ (Clawdbot Node)
Clawdbot Gateway
    ↓
AgentSaturday Processing
```

## Setup Steps

### 1. Install Clawdbot Node on Phone

**iOS (via Shortcuts)**:
```bash
# On Mac, generate pairing code
clawdbot nodes pending

# On iPhone: Install Clawdbot Shortcuts
# Add gateway URL and pairing code
```

**Android (via Termux)**:
```bash
# Install Termux from F-Droid
# In Termux:
pkg install nodejs
npm install -g clawdbot-node
clawdbot-node pair <gateway-url> <pairing-code>
```

### 2. Create Bridge Script

The bridge monitors Meta View app storage and forwards to Clawdbot.

### 3. Voice Command Setup

Configure voice triggers:
- "Hey Meta, send to Clawdbot"
- "Hey Meta, analyze this"
- "Hey Meta, remember this"

## Features

### Real-Time Capture
- Photo capture → Instant analysis
- Video clips → Scene understanding
- Audio notes → Transcription

### Auto-Processing
- Gallery monitoring
- Automatic uploads
- Background sync

### Voice Feedback
- Results spoken through glasses
- Confirmation tones
- Status updates

## Conversation Mode 🎤

Have natural back-and-forth dialogue with Clawdbot through your glasses:

```bash
# Start conversation
python3 conversation-mode.py

# Or use simple version
node conversation-simple.js
```

### Example:
- You: "What's my schedule today?"
- Clawdbot: "You have 3 meetings: 10am standup, 2pm design review..."
- You: "What's the design review about?"
- Clawdbot: "It's about the new dashboard mockups with the UX team."

See `CONVERSATION-MODE.md` for full details.