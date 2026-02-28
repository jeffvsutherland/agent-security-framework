# ASF-44: Agent Fix Prompt Generator

## Overview
Automated system to generate prompts that agents can use to apply security fixes based on scan results.

## Clawdbot-Moltbot-Open-Claw Specific Fixes

| Failing Component | Example Problem | Generated Fix Prompt Focus | Ties To ASF Story |
|-------------------------|------------------------------------------|---------------------------------------------|-------------------|
| Clawdbot WhatsApp bridge | Exposed localhost port | Enforce nftables rule + localhost-only | ASF-35 / ASF-2 |
| Moltbot PC-control | Unsafe capability granted | --cap-drop ALL + no-new-privs | ASF-42 / ASF-41 |
| Open-Claw skills dir | Low-trust skill detected | Quarantine + re-scan after YARA update | ASF-38 / ASF-5 |
| Supervisor anomalies | Syscall violation in container | Restart container + log to Discord | ASF-40 / ASF-42 |

## Usage

```bash
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate
```

## Acceptance Criteria

- [x] Reads CIO report
- [x] Generates prompts for each failing component
- [ ] No secrets leaked
- [ ] Auto-apply gated by ASF-40 supervisor
