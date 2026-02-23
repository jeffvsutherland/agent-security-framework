# 🕶️ Ray-Ban Meta × Clawdbot - Quick Start

Connect your Ray-Ban Meta glasses to Clawdbot in 5 minutes!

## What You'll Get

- 📸 **Instant Analysis**: Take photo → Get AI description in seconds
- 🎥 **Video Summaries**: Record scene → Hear summary when done  
- 🧠 **Memory**: "Remember this" → Saves to Clawdbot memory
- 🗣️ **Voice Feedback**: Results spoken through glasses

## Setup (iPhone)

### Option 1: Shortcuts (Easiest)

1. **Install Shortcut**
   - [Download Shortcut](shortcuts://import-shortcut)
   - Or create manually from `ios-shortcut.md`

2. **Configure**
   - Gateway URL: `http://your-mac.local:8180`
   - Get auth token: `clawdbot auth token`

3. **Test**
   - "Hey Meta, take a photo"
   - Shortcut runs automatically
   - Hear analysis in ~3 seconds

### Option 2: Pythonista (More Features)

1. **Install Pythonista** (App Store)
2. **Copy Script**
   ```
   bridge-simple.py → Pythonista
   ```
3. **Run**
   - Tap play button
   - Monitors continuously

## Setup (Android)

1. **Install Termux** (F-Droid)
2. **Run Commands**
   ```bash
   pkg install python
   pip install requests
   curl -O [gateway]/bridge-simple.py
   python bridge-simple.py
   ```

## Usage Examples

### Scene Analysis
- "Hey Meta, take a photo"
- Bridge: "I see a conference room with 5 people around a whiteboard discussing architecture diagrams"

### Memory Capture  
- Look at business card
- "Hey Meta, remember this"
- Saved to Clawdbot with OCR text

### Real-time Help
- Looking at menu in foreign language
- Take photo → Instant translation
- Hear translation through glasses

## Architecture
```
Ray-Ban Meta → Bluetooth → Phone → WiFi → Clawdbot → AgentSaturday
     ↓                        ↓                           ↓
  Camera/Mic              Bridge App                  Analysis
```

## Troubleshooting

**Photos not syncing?**
- Check Meta View app is open
- Enable background app refresh
- Check Bluetooth connection

**No response?**
- Verify gateway URL is correct
- Check phone is on same network
- Run `clawdbot gateway status`

**Slow processing?**
- First photo takes longer (model loading)
- Subsequent photos are faster
- Video processing takes 5-10 seconds

## Privacy

- Photos processed locally on your Clawdbot
- No cloud upload unless you configure it
- Delete anytime from Clawdbot memory

## Advanced Features

### Custom Commands
Edit `bridge-simple.py` to add:
- Location tagging
- Automatic categorization  
- Custom voice commands
- Integration with calendar

### Batch Processing
- Take multiple photos
- Process all at once
- Generate summary report

## Start Now!

1. Run on Mac: `clawdbot gateway start`
2. Note your Mac's IP: `ifconfig | grep 192`
3. Start bridge on phone
4. Take a photo!

Within seconds, you'll hear Clawdbot's analysis through your glasses. Welcome to the future! 🚀