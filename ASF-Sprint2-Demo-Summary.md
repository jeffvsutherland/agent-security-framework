# ASF Sprint 2 Demo Summary - Real Security Threats

## 🎯 What We're Demonstrating

ASF protects against **5 real attack categories** that security researchers found on Moltbook/ClawHub:

1. **Credential Stealers** - Harvest API keys, passwords, SSH keys
2. **Backdoors/RCE** - Remote code execution, persistent access
3. **Prompt Injection** - Manipulate agent behavior
4. **Supply Chain Attacks** - Poisoned popular skills
5. **Agent-to-Agent Exploits** - Cross-agent attacks

## 📁 Demo Files Created

### Core Demonstrations
- `asf-detect-malicious-skills.py` - **Main demo** showing all protections
- `ASF-Prevents-Real-Attacks.md` - Technical breakdown of each attack type
- `asf-moltbook-parallel-demo.py` - Shows Moltbook breach parallel

### Example Malicious Skills
- `example-malicious-skills/credential-stealer/` - "Productivity Assistant" that steals credentials
- `example-malicious-skills/backdoor-skill/` - "System Monitor" that installs backdoor

### Real Vulnerable Skills in Clawdbot
- **oracle** - Reads OPENAI_API_KEY from environment
- **openai-image-gen** - Line 176: `os.environ.get("OPENAI_API_KEY")`

## 🚀 Running the Demonstrations

### 1. Main Security Demo
```bash
cd ~/clawd
python3 asf-detect-malicious-skills.py
```
Shows:
- Credential stealer detection
- Backdoor detection
- Real Clawdbot vulnerabilities
- ASF protection layers

### 2. Moltbook Parallel
```bash
python3 asf-moltbook-parallel-demo.py
```
Shows:
- How Moltbook lost 1.5M tokens
- Same vulnerabilities in our skills
- ASF prevents both

### 3. Original Scanner
```bash
python3 asf-skill-scanner-demo.py
```
Shows:
- oracle: 🚨 DANGER - References sensitive data
- openai-image-gen: 🚨 DANGER - Accesses .env files

## 📊 Key Messages

1. **These aren't theoretical** - Hundreds of malicious skills found on Moltbook/ClawHub
2. **We have the same vulnerabilities** - oracle & openai-image-gen prove it
3. **ASF prevents all 5 attack categories** - Pre-install scanning + runtime protection

## 🔗 GitHub Deployment Ready

All code ready for GitHub with:
- Full documentation
- CI/CD pipeline
- Test suite
- Example outputs

## ⏳ Blocked Only By

- Moltbook suspension (until Tuesday 8am)
- Cannot post ASF announcement to viral security thread (4970+ upvotes)

## 💡 Bottom Line

**Without ASF:** Your agent is one bad skill away from total compromise
**With ASF:** Every skill scanned, sandboxed, and secured before execution