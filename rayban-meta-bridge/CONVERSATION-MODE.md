# 🕶️ Ray-Ban Meta × Clawdbot Conversation Mode

Yes! You can have full conversations with Clawdbot through your glasses.

## How It Works

```
Your Voice → Glasses Mic → Phone (Bluetooth) → Bridge App → Clawdbot → AgentSaturday
                ↑                                                           ↓
            Glasses Speaker ← Phone TTS ← Bridge App ← Response ← Analysis
```

## Quick Start

### Option 1: Voice Conversation (Recommended)
```bash
# On phone with Python
python3 conversation-mode.py

# Or with Node.js
node conversation-simple.js
```

### Option 2: iOS Shortcuts
- Use `conversation-shortcut.md` to create Siri shortcut
- Say "Hey Siri, talk to Clawdbot"
- Conversation starts automatically

## Example Conversation

**You:** "Hey, what's my schedule today?"  
**Clawdbot:** "You have 3 meetings: 10am standup, 2pm design review, and 4pm with Sarah."

**You:** "What's the design review about?"  
**Clawdbot:** "The 2pm design review is about the new dashboard mockups with the UX team."

**You:** "Take a photo of this whiteboard"  
**Clawdbot:** "Taking a photo... I see a system architecture diagram with microservices layout."

**You:** "Remember the main API endpoint is /v2/users"  
**Clawdbot:** "I'll remember: the main API endpoint is /v2/users"

**You:** "Goodbye"  
**Clawdbot:** "Goodbye! Ending conversation mode."

## Features

### 🎤 Natural Dialogue
- Continuous conversation without repeating wake words
- Context maintained across messages
- Interruption handling

### 📸 Visual Integration  
- "Take a photo" - Captures through glasses
- "What do you see?" - Analyzes current view
- "Describe this" - Real-time scene analysis

### 🧠 Memory & Context
- "Remember..." - Saves to Clawdbot memory
- Maintains conversation context
- Access to your full Clawdbot knowledge

### 🔧 Commands
- "Louder/Quieter" - Adjust volume
- "Repeat that" - Replay response
- "Send to email" - Email conversation log

## Technical Details

### Architecture
1. **Voice Input**: Glasses mic → Phone via Bluetooth
2. **Processing**: Speech-to-text on phone
3. **Bridge**: Sends to Clawdbot gateway
4. **AI Response**: AgentSaturday processes
5. **Voice Output**: TTS on phone → Glasses speakers

### Requirements
- Ray-Ban Meta glasses (paired to phone)
- Phone with Clawdbot bridge app
- WiFi connection to Clawdbot gateway
- Bluetooth audio enabled

### Privacy & Security
- Only active when you start conversation
- Not always listening (no wake word monitoring)
- All processing through your Clawdbot instance
- Conversations stay private

## Advanced Usage

### Custom Wake Phrases
Edit `conversation-mode.py`:
```python
WAKE_PHRASES = ["hey clawdbot", "okay assistant", "computer"]
```

### Continuous Mode
Keep conversation active between uses:
```bash
python3 conversation-mode.py --continuous
```

### Multi-Modal Responses
Combine voice with visual:
- Voice response through glasses
- Detailed info sent to phone screen
- Images displayed in companion app

## Troubleshooting

**Can't hear responses?**
- Check Bluetooth connected
- Verify glasses volume
- Ensure phone not muted

**Speech not recognized?**
- Speak clearly toward phone
- Reduce background noise
- Check microphone permissions

**Delays in response?**
- Check WiFi strength
- Verify gateway running
- First response slower (model loading)

## Demo Commands

Try these to test:
- "What time is it?"
- "What's the weather?"
- "Take a photo and describe it"
- "Remember I parked in section B4"
- "What did I ask you to remember?"
- "Calculate 15% tip on $84"

## The Future

This is just the beginning. Imagine:
- Real-time translation overlay
- Navigation with voice guidance
- Live sports/event commentary
- Cooking instructions while you cook
- Instant fact-checking in conversations

Your AI assistant, always accessible through your glasses! 🚀