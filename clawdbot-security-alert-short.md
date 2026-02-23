# ⚠️ URGENT: Clawdbot Security Alert

**All Clawdbot users are running vulnerable code that exposes API keys.**

## The Problem
Clawdbot ships with skills (oracle, openai-image-gen) that store API keys in environment variables - the same vulnerability that caused the Moltbook breach (1.5M tokens stolen).

## Check Yourself
```bash
# Install ASF Scanner
git clone https://github.com/jeffvsutherland/asf-security-scanner
cd asf-security-scanner
python3 asf-skill-scanner-v1.py
```

If you see:
- oracle: 🚨 DANGER
- openai-image-gen: 🚨 DANGER

**You are vulnerable.**

## Fix Now
1. Download secure versions: https://github.com/jeffvsutherland/asf-security-scanner/tree/main/asf-secure-skills
2. Replace vulnerable skills in your skills directory
3. Use `clawdbot auth set` instead of environment variables

## Why This Matters
- Default Clawdbot installation = 0/100 security score
- Any malicious code can steal your API keys
- This is actively being exploited

**Protect yourself now. Don't wait for a patch.**

---
*Discovered by ASF (Agent Security Framework) - Protecting AI agents from supply chain attacks*