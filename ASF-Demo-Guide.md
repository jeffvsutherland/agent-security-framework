# ASF Demo Guide - Show Real Security in Action

## 🎯 Purpose

These demos show ASF detecting and fixing the SAME vulnerabilities that exposed 1.5M tokens at Moltbook.

## 📁 Demo Scripts

### 1. **asf-live-demo.sh** (Bash Version)
- Simple, straightforward shell script
- Good for technical audiences
- Shows actual command outputs
- Runs real scanner and installer

### 2. **asf-live-demo.py** (Python Version)
- Polished presentation version
- Typewriter effects and colors
- Simulated outputs for consistency
- Perfect for videos or live presentations

### 3. **asf-detect-malicious-skills.py**
- Shows all 5 attack categories
- Demonstrates broader threat landscape
- Includes example malicious skills

## 🎬 Running the Demo

### Quick Demo (5 minutes)
```bash
cd ~/clawd
./asf-live-demo.sh
```

### Presentation Demo (8-10 minutes)
```bash
cd ~/clawd
python3 asf-live-demo.py
```

### Full Security Demo (15 minutes)
```bash
cd ~/clawd
python3 asf-detect-malicious-skills.py
```

## 📊 Demo Flow

1. **Show the Problem** 🔴
   - Scanner finds oracle & openai-image-gen vulnerabilities
   - Same pattern as Moltbook breach

2. **Examine the Code** 🔍
   - Line 176: `api_key = os.environ.get("OPENAI_API_KEY")`
   - Explain how any code can steal this

3. **Apply the Fix** 🔧
   - Run `install-secure-skills.sh`
   - Backs up old, installs secure versions

4. **Show the Solution** ✅
   - Secure credential function
   - Encrypted storage
   - Access control

5. **Verify Success** 🎯
   - Scanner now shows skills are secure
   - Attack simulation shows protection

## 🗣️ Key Talking Points

### Opening
"Today I'll show you how ASF prevents the exact vulnerabilities that led to Moltbook's massive breach..."

### The Problem
"These two skills in Clawdbot - oracle and openai-image-gen - have the SAME vulnerability that exposed 1.5M tokens at Moltbook. Watch what happens when we scan them..."

### The Fix
"ASF doesn't just find problems - it fixes them. Let me show you how we secure these skills..."

### The Result
"Now when an attacker tries to steal credentials, every attempt is blocked. The Moltbook breach could never happen with ASF."

## 💡 Demo Tips

1. **For Technical Audience**: Use `asf-live-demo.sh` and show real code
2. **For Business Audience**: Use `asf-live-demo.py` with visual effects
3. **For Security Teams**: Include attack simulation section
4. **For Quick Pitch**: Just show before/after scanner results

## 🚀 Post-Demo Actions

After the demo, mention:
- GitHub deployment coming (Sprint 2)
- Discord bot for easy adoption
- Enterprise pilot program
- Community engagement on Moltbook

## 📝 Customization

To customize for specific audiences:
- Edit typewriter text in Python version
- Add company-specific examples
- Adjust timing with sleep values
- Add more attack scenarios

## 🎥 Recording Tips

For video demos:
1. Use Python version for consistency
2. Set terminal to 100x30 for best display
3. Use dark theme with good contrast
4. Record at 1920x1080 minimum

This demo proves ASF works - by fixing real vulnerabilities in our own tools!