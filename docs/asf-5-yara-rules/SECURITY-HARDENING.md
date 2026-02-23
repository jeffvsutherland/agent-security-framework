# ASF-5 YARA Rules - Security Hardening Guide

## Overview
This document outlines security hardening measures for the YARA rules themselves and integration best practices.

## 1. Protecting Test Samples

### Git Ignore
A `.gitignore` file is included to prevent committing:
- Real malicious samples
- Sensitive IOC data
- Compiled rule files

```bash
# Only use benign test files
# Never commit actual malware samples
```

## 2. Rule Signing & Versioning

### External Variables for Rule Validation
```yaml
# YARA supports external variables for rule versioning
# Example: yara -d version=1.0 rules.yar testfile
```

### Rule Versioning
- Each rule includes metadata: version, date, author
- Rules should be rotated/updated weekly
- Monitor sources: Kaspersky, BleepingComputer, ClawHavoc reports

## 3. Least Privilege Execution

### Container Scanning (Non-Root)
```bash
# Run YARA scans as non-root user
USER node
RUN yara ...

# Or use specific user for scanning
RUN useradd -m scanner && chown -R scanner:scanner /rules
```

### Docker Integration (Read-Only Mount)
```yaml
services:
  openclaw-gateway:
    volumes:
      - ./docs/asf-5-yara-rules:/home/node/.openclaw/yara/asf5:ro
  
  openclaw-mission-control-backend:
    volumes:
      - ./docs/asf-5-yara-rules:/app/yara/asf5:ro
```

## 4. Cron Scanning (Host-Level)

### macOS LaunchAgent
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <label>com.asf.yara-scanner</label>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/yara</string>
        <string>-r</string>
        <string>/path/to/asf-5-yara-rules/*.yar</string>
        <string>/Users/jeffsutherland/clawd/openclaw-state/</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
```

## 5. Skill Install Hook

### Pre-Install Validation
```bash
#!/bin/bash
# validate-skill.sh
SKILL_PATH=$1
RULES_DIR="/path/to/asf-5-yara-rules"

# Scan skill before installation
yara -r $RULES_DIR/*.yar $SKILL_PATH
if [ $? -eq 0 ]; then
    echo "WARNING: Skill triggered YARA rules!"
    exit 1
fi

# Continue with installation
echo "Skill validated - proceeding with install"
```

## 6. Weekly Update Schedule

| Day | Task |
|-----|------|
| Monday | Review IOC reports from previous week |
| Wednesday | Update rules with new patterns |
| Friday | Test against benign samples |
| Sunday | Full regression test |

## 7. Log-Based Detection (Sigma Integration)

### Example Sigma Rule
```yaml
title: Suspicious OpenClaw Skill Execution
id: asa-0001
status: stable
description: Detects suspicious execution patterns in skills
logsource:
  category: process_creation
  product: openclaw
detection:
  selection:
    CommandLine|contains:
      - 'eval('
      - 'exec('
      - 'os.system'
  condition: selection
level: high
```

## 8. Rule Categories

| Category | Description | Priority |
|----------|-------------|----------|
| credential-theft | Detection of credential access/exfil | Critical |
| code-execution | Suspicious code execution patterns | Critical |
| network-exfiltration | Unauthorized network calls | High |
| privilege-escalation | Proxy/Tailscale bypass | High |
| malware-indicators | Known malware patterns | Medium |
| obfuscation | Base64/encoding detection | Medium |
| social-engineering | Typosquatting/confusion | Low |

## 9. Validation Commands

### Syntax Check
```bash
# Install YARA: brew install yara
for rule in *.yar *.yara; do
    yara -c "$rule" && echo "[OK] $rule compiles" || echo "[FAIL] $rule has errors!"
done
```

### Test Against Samples
```bash
# Scan test directory
yara -r . /path/to/test-samples/

# Scan OpenClaw skills
yara -r . /path/to/openclaw-skills/
```

---

**Last Updated:** 2026-02-21  
**Based on Grok Heavy Review Recommendations**
