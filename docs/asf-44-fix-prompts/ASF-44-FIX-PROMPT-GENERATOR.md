# ASF-44: Fix Prompt Generator

## Overview

ASF-44 generates automated fix prompts from security scan results. Integrates with ASF-44 bootup scan.

## Open-Claw / Clawdbot / Moltbot Integration

| Failing Component | Example Problem | Generated Fix Prompt Focus | Ties To ASF Story |
|-------------------------|------------------------------------------|---------------------------------------------|-------------------|
| Clawdbot WhatsApp bridge | Exposed localhost port | Enforce nftables rule + localhost-only | ASF-35 / ASF-2 |
| Moltbot PC-control | Unsafe capability granted | --cap-drop ALL + no-new-privs | ASF-42 / ASF-41 |
| Open-Claw skills dir | Low-trust skill detected | Quarantine + re-scan after YARA update | ASF-38 / ASF-5 |
| Supervisor anomalies | Syscall violation in container | Restart container + log to Discord | ASF-40 / ASF-42 |

## Usage

```bash
# Basic usage
python3 asf-fix-prompt-generator.py --input CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md

# Dry run (recommended first)
python3 asf-fix-prompt-generator.py --input CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md --dry-run

# Auto-apply with supervisor gate
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate
```

## One-Command Secure Workflow

```bash
# Full secure flow for Clawdbot-Moltbot-Open-Claw
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md --dry-run
# Review FIX-PROMPTS.md
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate
asf-openclaw-scanner.py --verify-fixes
```

## Acceptance Criteria

- [ ] Integrates with ASF-44 bootup scan
- [ ] Generates prompts for all 10 security layers
- [ ] Outputs human-readable fix prompts
- [ ] No secrets leaked in generated FIX-PROMPTS.md
- [ ] Prompts tested on .openclaw (dry-run first)
- [ ] Auto-apply gated by ASF-40 supervisor (trust ≥ 95)
- [ ] Verification commands succeed and update AGENT-COMMUNICATION-LOG.md
- [ ] --dry-run and --supervisor-gate flags supported in script
