# ASF-5 YARA Rules Response & Implementation Guide

## Purpose
This document provides the detection-to-alert workflow, incident response procedures, and integration guidance for ASF-5 YARA rules in the OpenClaw ecosystem.

---

## 1. Detection → Alert Workflow

### Architecture
```
[Skill Install] → [YARA Scan] → [Quarantine] → [Notify] → [Log]
      ↓              ↓             ↓           ↓          ↓
  Gateway      yara scanner   Isolate    Telegram    Incident
  Event        Rules ASF-5    Container   Slack      DB
```

### Integration Snippet: Pre-Install Hook
```bash
#!/bin/bash
# Pre-install hook: scan skill before acceptance
# Save as: /usr/local/bin/openclaw-scan-skill.sh

YARA_RULES="/home/node/.openclaw/yara/asf5"
SKILL_PATH="$1"

if [ -z "$SKILL_PATH" ]; then
    echo "Usage: $0 <skill-directory>"
    exit 1
fi

# Run YARA scan
SCAN_RESULT=$(yara -r "$YARA_RULES" "$SKILL_PATH" 2>/dev/null)

if [ -n "$SCAN_RESULT" ]; then
    echo "🚨 YARA DETECTION: $SCAN_RESULT"
    
    # Quarantine the skill
    mv "$SKILL_PATH" "/home/node/.openclaw/quarantine/$(basename $SKILL_PATH)_$(date +%s)"
    
    # Notify via webhook
    curl -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"text\": \"🚨 YARA ALERT: Malicious skill detected: $SCAN_RESULT\"}"
    
    exit 1  # Block installation
fi

echo "✅ YARA scan passed for $SKILL_PATH"
exit 0
```

### Gateway Configuration
```yaml
# docker-compose.yml snippet
services:
  openclaw-gateway:
    volumes:
      - ./yara/asf5:/home/node/.openclaw/yara/asf5:ro
      - ./quarantine:/home/node/.openclaw/quarantine
    environment:
      - SKILL_SCAN_HOOK=/usr/local/bin/openclaw-scan-skill.sh
```

---

## 2. Incident Response Steps

### Immediate Actions (0-5 minutes)
| Step | Action | Command |
|------|--------|---------|
| 1 | Isolate container | `docker stop <container_id>` |
| 2 | Preserve evidence | `docker commit <container_id> forensic-image-$(date +%s)` |
| 3 | Rotate tokens | `openclaw token rotate --all` |
| 4 | Notify team | Send alert to #security-incidents |
| 5 | Block network | `iptables -A INPUT -s <container_ip> -j DROP` |

### Short-term (5-30 minutes)
| Step | Action |
|------|--------|
| 1 | Review YARA hit details |
| 2 | Analyze skill code for IOCs |
| 3 | Check for lateral movement |
| 4 | Revoke any compromised API keys |
| 5 | Document incident in #incident-reports |

### Long-term (30+ minutes)
| Step | Action |
|------|--------|
| 1 | Update YARA rules with new IOCs |
| 2 | Conduct root cause analysis |
| 3 | Implement additional hardening |
| 4 | Update runbook documentation |
| 5 | Schedule post-incident review |

---

## 3. False Positive Tuning Guide

### Common False Positives
- Legitimate monitoring tools (e.g., `requests` + `os.environ`)
- Dev debugging code
- Base64-encoded configuration

### Tuning Steps
```bash
# 1. Identify false positive
yara -r rules.yar skill.py | grep -v "false_positive_pattern"

# 2. Add exclusion to rule
rule safe_requests {
    strings:
        $safe = "requests.post" nocase
    condition:
        not any of them
}

# 3. Test exclusion
yara -r rules.yar skill.py
```

### Best Practices
- Use `nocase` sparingly
- Add `filepath` conditions for path-specific rules
- Include `tags` for categorization
- Document exclusions in `RULE_EXCEPTIONS.md`

---

## 4. Integration Examples

### Mission Control Backend
```python
# mc-backend/yara_scanner.py
import subprocess
import json

def scan_skill(skill_path: str) -> dict:
    result = subprocess.run(
        ["yara", "-r", "/app/yara/asf5/", skill_path],
        capture_output=True,
        text=True
    )
    
    return {
        "clean": result.returncode == 0,
        "matches": result.stdout.splitlines(),
        "errors": result.stderr
    }
```

### Gateway Pre-Install
```python
# gateway/skill_manager.py
async def install_skill(skill_url: str):
    # Download skill
    skill_path = await download_skill(skill_url)
    
    # Scan before install
    scan_result = yara_scan(skill_path)
    
    if not scan_result["clean"]:
        await notify_security_team(scan_result["matches"])
        raise SecurityError("Skill blocked by YARA rules")
    
    # Proceed with install
    await continue_install(skill_path)
```

### Telegram Alert Bot
```python
# alerts/telegram_notifier.py
def alert_yara_hit(matches: list, skill_name: str):
    message = f"🚨 *YARA Alert*\n\n"
    message += f"*Skill:* `{skill_name}`\n"
    message += f"*Detections:*\n"
    for match in matches:
        message += f"• `{match}`\n"
    
    bot.send_message(chat_id=INCIDENT_CHAT_ID, text=message, parse_mode="Markdown")
```

---

## 5. Threat Response Matrix

| Threat Category | YARA Rule | Immediate Action | Long-term Mitigation |
|----------------|-----------|------------------|---------------------|
| Credential Exfil | `asf5_credential_exfil` | Rotate all tokens | Restrict env var access |
| RCE Attempt | `asf5_rce_pattern` | Kill container | Disable eval/exec |
| Crypto Miner | `asf5_crypto_miner` | Network block | Monitor CPU usage |
| Data Exfiltration | `asf5_exfil_network` | Isolate host | Firewall rules |
| Typosquatting | `asf5_typosquat` | Remove skill | Name verification |

---

## 6. Quick Reference Commands

```bash
# Scan a skill
yara -r /path/to/rules/ /path/to/skill/

# Scan with JSON output
yara -r -j /path/to/rules/ /path/to/skill/ > scan-results.json

# Compile rules for performance
yarc -c rules.yar -o compiled.yarc rules/

# Test single rule
yara -t openclaw_malicious_skill skill.py

# List all rules
yarac -l compiled.yarc
```

---

## 7. Rule Categories (Planned)

| Category | Filename | Status |
|----------|-----------|--------|
| Malicious Skill | `openclaw_malicious_skill.yar` | Planned |
| RCE Patterns | `openclaw_rce_pattern.yar` | Planned |
| InfoStealer | `clawbot_infostealer.yar` | Planned |
| AI Anomalies | `asf5_generic_ai_agent.yar` | Planned |
| Typosquatting | `openclaw_typosquat.yar` | Planned |
| CVE Signatures | `openclaw_cve_*.yar` | Planned |
| Proxy Bypass | `asf5_proxy_bypass.yar` | Planned |
| High-Entropy | `asf5_high_entropy.yar` | Planned |

---

## 8. Security Hardening for Rules

- ✅ Git ignore test samples
- ✅ Weekly rotation schedule
- ✅ Run scans as non-root
- 🔲 Sign rules (YARA signature)
- 🔲 Hash verification

---

**Document Status:** Active  
**Last Updated:** 2026-02-23  
**Owner:** ASF Security Team  
**Priority:** High
