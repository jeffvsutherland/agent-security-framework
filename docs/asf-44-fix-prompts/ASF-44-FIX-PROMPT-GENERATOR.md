# ASF-44/45: Automated Security Fix Prompt Generator

## Overview

ASF-44 runs the bootup scan, ASF-45 integrates with it to automatically generate fix prompts for any security issues found.

## Integration

This ties into the full ASF stack:
- ASF-38: Trust framework (verify fixes before re-trust)
- ASF-40: Supervisor (orchestrate auto-apply safely)
- ASF-41: Guardrail
- ASF-42: Syscall monitoring
- ASF-35: OpenClaw scanner

## Clawdbot-Moltbot-Open-Claw Specific

| Failing Component | Example Problem | Generated Fix Prompt Focus | Ties To ASF Story |
|-------------------------|------------------------------------------|---------------------------------------------|-------------------|
| Clawdbot WhatsApp bridge | Exposed localhost port | Enforce nftables rule + localhost-only | ASF-35 / ASF-2 |
| Moltbot PC-control | Unsafe capability granted | --cap-drop ALL + no-new-privs | ASF-42 / ASF-41 |
| Open-Claw skills dir | Low-trust skill detected | Quarantine + re-scan after YARA update | ASF-38 / ASF-5 |
| Supervisor anomalies | Syscall violation in container | Restart container + log to Discord | ASF-40 / ASF-42 |

## Usage

```bash
# Run bootup scan
./asf-bootup-scan.sh --generate-fixes

# Generate fix prompts from CIO report
python3 asf-fix-prompt-generator.py --input CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md

# Dry run first (recommended)
python3 asf-fix-prompt-generator.py --input CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md --dry-run

# Auto-apply with supervisor gate (trust ≥ 95)
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate
asf-openclaw-scanner.py --verify-fixes
```

## Recommended Secure Workflow

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
