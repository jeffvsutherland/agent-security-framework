# ASF-44: Agent Fix Prompt Generator

## Overview

Automated system to generate prompts that agents can use to apply security fixes based on scan results.

## Clawdbot-Moltbot-Open-Claw Integration

| Failing Component | Example Problem | Generated Fix Prompt Focus | Ties To ASF Story |
|-------------------------|------------------------------------------|---------------------------------------------|-------------------|
| Clawdbot WhatsApp bridge | Exposed localhost port | Enforce nftables rule + localhost-only | ASF-35 / ASF-2 |
| Moltbot PC-control | Unsafe capability granted | --cap-drop ALL + no-new-privs | ASF-42 / ASF-41 |
| Open-Claw skills dir | Low-trust skill detected | Quarantine + re-scan after YARA update | ASF-38 / ASF-5 |
| Supervisor anomalies | Syscall violation in container | Restart container + log to Discord | ASF-40 / ASF-42 |

## Usage

```bash
# Generate fix prompts from CIO report
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md

# Dry run first
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --dry-run

# Auto-apply with supervisor gate
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate

# Verify fixes
asf-openclaw-scanner.py --verify-fixes
```

## Recommended Secure Workflow

```bash
# Step 1: Generate prompts
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md --dry-run

# Step 2: Review FIX-PROMPTS.md manually

# Step 3: Apply with supervisor gate (trust >= 95)
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate

# Step 4: Verify fixes
asf-openclaw-scanner.py --verify-fixes
```

## Acceptance Criteria

- [x] Reads CIO report
- [x] Generates prompts for each failing component
- [x] Includes verification steps
- [x] No secrets leaked in generated FIX-PROMPTS.md
- [x] Prompts tested on .openclaw (dry-run first)
- [x] Auto-apply gated by ASF-40 supervisor (trust >= 95)
- [x] Verification commands succeed and update AGENT-COMMUNICATION_LOG.md
- [x] --dry-run and --supervisor-gate flags supported in script
