# ASF-44: Security Fix Prompt Generator

## Overview
Generate agent-executable prompts from security scan findings.

## Integration

| Failing Component | Example Problem | Generated Fix Prompt Focus | Ties To ASF Story |
|-----------------|-----------------|------------------|-------------------|
| VPN Protection | Not enabled | tailscale up --operator=jeff | ASF-41 |
| Firewall | Not configured | ufw enable + default deny | ASF-42 |
| DNS Security | ISP DNS vulnerable | 1.1.1.1 configuration | ASF-35 |
| Antivirus | Not installed | clamav install + freshclam | ASF-38 |

## Open-Claw / Clawdbot / Moltbot Integration

| Failing Component | Example Problem | Generated Fix Prompt Focus | Ties To ASF Story |
|-------------------------|------------------------------------------|---------------------------------------------|-------------------|
| Clawdbot WhatsApp bridge | Exposed localhost port | Enforce nftables rule + localhost-only | ASF-35 / ASF-2 |
| Moltbot PC-control | Unsafe capability granted | --cap-drop ALL + no-new-privs | ASF-42 / ASF-41 |
| Open-Claw skills dir | Low-trust skill detected | Quarantine + re-scan after YARA update | ASF-38 / ASF-5 |
| Supervisor anomalies | Syscall violation in container | Restart container + log to Discord | ASF-40 / ASF-42 |

## Acceptance Criteria

- [x] Reads CIO report and extracts failing components
- [x] Generates prompts for each failing component
- [x] Includes verification steps
- [x] No secrets leaked in generated FIX-PROMPTS.md
- [x] Prompts tested on .openclaw (dry-run first)
- [x] Auto-apply gated by ASF-40 supervisor (trust ≥ 95)
- [x] --dry-run and --supervisor-gate flags supported
- [x] Verification commands succeed and update AGENT-COMMUNICATION-LOG.md

## Usage

### One-Command Secure Workflow

```bash
# Recommended secure flow for Clawdbot-Moltbot-Open-Claw

# 1. Generate fix prompts (dry-run first)
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md --dry-run

# 2. Review FIX-PROMPTS.md
cat FIX-PROMPTS.md

# 3. Apply with supervisor gate
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate

# 4. Verify and log
asf-openclaw-scanner.py --verify-fixes
```

## Example Output

```markdown
# Fix: Enable VPN

Run these commands:
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --operator=jeff

Verify: tailscale status
```

---

**Story:** ASF-44  
**Status:** Ready for Review
