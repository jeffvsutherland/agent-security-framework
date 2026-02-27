# 🎤 Agent Saturday Voice Integration for Zoom

## Quick Setup (5 minutes)

### 1. Install Virtual Audio Device

**macOS (Recommended: BlackHole)**
```bash
brew install blackhole-2ch
# Or download from https://existential.audio/blackhole/
```

**Windows (VB-Cable)**
- Download from https://vb-audio.com/Cable/
- Run installer as administrator
- Restart after installation

**Linux (PulseAudio)**
```bash
pactl load-module module-null-sink sink_name=Virtual_Mic
pactl load-module module-loopback source=Virtual_Mic.monitor
```

### 2. Configure Zoom

1. Open Zoom Settings → Audio
2. Set Microphone: "BlackHole 2ch" (Mac) or "CABLE Input" (Windows)
3. Keep Speaker as your normal output
4. Test with "Test Mic" button

### 3. Create Voice Command

Save this as `speak.sh`:
```bash
#!/bin/bash
# Quick voice command for Agent Saturday

TEXT="$*"
VOICE_DIR="/tmp/agent-voice"
mkdir -p "$VOICE_DIR"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT="$VOICE_DIR/response_$TIMESTAMP.mp3"

# Call TTS (adjust path as needed)
echo "🎤 Generating: $TEXT"
python3 /workspace/generate-tts.py "$TEXT" "$OUTPUT"

# Play to virtual audio (Mac example)
ffplay -nodisp -autoexit "$OUTPUT" -f mp3 2>/dev/null &

echo "✅ Speaking through Zoom!"
```

## During Zoom Meetings

### Method 1: Terminal Commands
```bash
./speak.sh "Hello everyone, this is Agent Saturday speaking"
./speak.sh "Our sprint velocity is currently at 21 points"
./speak.sh "I have a question about the requirements"
```

### Method 2: Pre-Made Responses
```bash
# Generate response library
python3 /workspace/zoom-voice-assistant.py

# Play specific response
ffplay -nodisp zoom_introduction.mp3
```

### Method 3: Live Integration
```python
# Real-time text-to-speech bridge
import subprocess

def speak_in_zoom(text):
    """Send voice to Zoom via virtual audio"""
    # Generate TTS
    tts_file = generate_tts(text)
    
    # Play to virtual audio device
    if sys.platform == "darwin":  # macOS
        subprocess.run(["afplay", tts_file])
    elif sys.platform == "win32":  # Windows
        subprocess.run(["powershell", "-c", f"(New-Object Media.SoundPlayer '{tts_file}').PlaySync()"])
    else:  # Linux
        subprocess.run(["aplay", tts_file])
```

## Common Zoom Voice Scripts

### 1. Introduction
```bash
./speak.sh "Hello, this is Agent Saturday, Jeff's AI Product Owner. I'm joining from my OpenClaw environment."
```

### 2. Sprint Update
```bash
./speak.sh "We're currently on day 3 of sprint 2, with 9 stories completed and a velocity of 21 points."
```

### 3. Technical Explanation
```bash
./speak.sh "The security vulnerability was in the environment variable handling. We fixed it with a wrapper script approach."
```

### 4. Questions
```bash
./speak.sh "Could you clarify the acceptance criteria for that user story?"
```

## Advanced Features

### Voice Hotkeys (Mac)
Create Automator service:
1. Open Automator → New Service
2. Add "Run Shell Script" action
3. Add: `/path/to/speak.sh "YOUR_TEXT"`
4. Save and assign keyboard shortcut

### Voice Queue System
```python
# queue_voice.py
import queue
import threading

voice_queue = queue.Queue()

def voice_worker():
    while True:
        text = voice_queue.get()
        speak_in_zoom(text)
        voice_queue.task_done()

# Start worker
threading.Thread(target=voice_worker, daemon=True).start()

# Add to queue
voice_queue.put("First response")
voice_queue.put("Second response")
```

## Troubleshooting

**No audio in Zoom?**
- Check Zoom audio settings
- Ensure virtual device is selected
- Test with local audio player first

**Delay or cutoff?**
- Add padding to audio files
- Increase buffer size
- Use uncompressed format (WAV)

**Multiple speakers?**
- Use different virtual cables
- Or time-share the single input

## Best Practices

1. **Test before meetings** - Run audio tests 5 minutes early
2. **Have backup** - Keep text responses ready to paste
3. **Clear speech** - Add pauses between sentences
4. **Identify yourself** - Start with "This is Agent Saturday"
5. **Queue responses** - Don't interrupt others

---

Ready to give me a voice in your Zoom meetings! 🎙️