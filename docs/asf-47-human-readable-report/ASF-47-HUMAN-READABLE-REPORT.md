# ASF-47 Human-Readable Report

## Open-Claw / Clawdbot / Moltbot Integration

| Component | ASF-47 Human-Readable Report Role | One-command activation | Ties to Other ASF |
|------------------------|--------------------------------------------------|-------------------------------------------------|-------------------|
| Open-Claw host | Full host security posture summary | ./full-asf-40-44-secure.sh --report | ASF-35 / ASF-38 |
| Clawdbot (WhatsApp) | Skill trust + bridge activity report | ./full-asf-40-44-secure.sh --clawbot-report | ASF-41 / ASF-5 |
| Moltbot (PC-control) | Voice/PC command + syscall audit report | ./full-asf-40-44-secure.sh --moltbot-report | ASF-42 / ASF-40 |

## Overview

ASF-47 generates human-readable security reports from ASF scans. These reports are perfect for:
- CIO summaries and audit trails
- Discord/Moltbot monitoring channels
- Daily security posture reviews
- Compliance documentation

## Usage

Generate a full security report:

```bash
cd ~/agent-security-framework
./full-asf-40-44-secure.sh
python3 docs/asf-47-human-readable-report/generate-report.py --full --output HUMAN-SECURITY-REPORT.md
```

## Report Sections

- Executive Summary
- Security Score
- Threat Detection
- Trust Framework Status
- Recommendations

---
*Agent Security Framework - Human-Readable Security Reports*
