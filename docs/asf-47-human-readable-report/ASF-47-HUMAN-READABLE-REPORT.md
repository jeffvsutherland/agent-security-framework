# ASF-47: Human-Readable Security Report

## Open-Claw / Clawdbot / Moltbot Integration

| Component | ASF-47 Human-Readable Report Role | One-command activation | Ties to Other ASF |
|------------------------|--------------------------------------------------|-------------------------------------------------|-------------------|
| Open-Claw host | Full host security posture summary | ./full-asf-40-44-secure.sh --report | ASF-35 / ASF-38 |
| Clawdbot (WhatsApp) | Skill trust + bridge activity report | ./full-asf-40-44-secure.sh --clawbot-report | ASF-41 / ASF-5 |
| Moltbot (PC-control) | Voice/PC command + syscall audit report | ./full-asf-40-44-secure.sh --moltbot-report | ASF-42 / ASF-40 |

---

## Overview

ASF-47 generates beautiful, human-readable security reports from ASF scans. Perfect for CIOs, Discord summaries, and monitoring Clawdbot-Moltbot-Open-Claw on your New Jersey box.

## Features

- Executive summary for stakeholders
- Security score with breakdown
- Actionable recommendations
- Discord/Moltbot compatible formatting
- Compliance status (SOC2, HIPAA)

## Usage

```bash
# Generate human-readable report for Clawdbot-Moltbot-Open-Claw
cd ~/agent-security-framework
./full-asf-40-44-secure.sh
python3 docs/asf-47-human-readable-report/generate-report.py --full --output HUMAN-SECURITY-REPORT.md
```

## Report Sections

1. Executive Summary
2. Security Score (0-100)
3. Component Status
4. Threats Detected
5. Recommendations
6. Compliance Status

---

## Acceptance Criteria

- [x] Integration table added
- [x] Report generator script created
- [x] Discord-compatible output
- [x] CIO-friendly formatting

---

*ASF-47 - Human-Readable Report Generator*
