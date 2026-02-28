# ASF-44: Fix Prompt Generator

**Story:** Generate corrective prompts for OpenClaw to auto-remediate vulnerabilities

## Description
Implement the self-healing security architecture that generates corrective prompts back to OpenClaw when vulnerabilities are detected. This closes the loop from detection → intervention → remediation.

---

## Integration Table: Clawdbot-Moltbot-Open-Claw

| Failing Component | Example Problem | Generated Fix Prompt Focus | Ties To ASF Story |
|-------------------------|------------------------------------------|---------------------------------------------|-------------------|
| Clawdbot WhatsApp bridge| Exposed localhost port | Enforce nftables rule + localhost-only | ASF-35 / ASF-2 |
| Moltbot PC-control | Unsafe capability granted | --cap-drop ALL + no-new-privs | ASF-42 / ASF-41 |
| Open-Claw skills dir | Low-trust skill detected | Quarantine + re-scan after YARA update | ASF-38 / ASF-5 |
| Supervisor anomalies | Syscall violation in container | Restart container + log to Discord | ASF-40 / ASF-42 |

---

## Deliverables
1. **Prompt Generator Script** - `asf-fix-prompt-generator.py`
   - Analyzes scan results from YARA, trust scoring, syscall monitoring
   - Generates human-readable corrective prompts for OpenClaw
   - Maps vulnerabilities to specific fix actions

2. **Integration with Bootup Scan**
   - Run prompt generation after every boot scan
   - Output prompts to `/var/log/asf/healing-prompts/`

3. **Auto-Remediation Hooks**
   - Option to auto-apply safe fixes (config changes, skill removal)
   - Guardrail confirmation before destructive actions

---

## Acceptance Criteria
- [ ] Scans detect vulnerability → generates fix prompt within 30 seconds
- [ ] Prompts are in language non-technical staff can execute
- [ ] Integration with existing ASF-35, ASF-38, ASF-42 tools
- [ ] Test cases: malicious skill detection → prompt → remediation
- [ ] **No secrets leaked in generated FIX-PROMPTS.md**
- [ ] **Prompts tested on .openclaw (dry-run first)**
- [ ] **Auto-apply gated by ASF-40 supervisor (trust ≥ 95)**
- [ ] **Verification commands succeed and update AGENT-COMMUNICATION-LOG.md**

---

## One-Command Secure Workflow

```bash
# Recommended secure flow for Clawdbot-Moltbot-Open-Claw
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md --dry-run

# Review FIX-PROMPTS.md
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate asf-openclaw-scanner.py --verify-fixes
```

---

## Example Prompt Output
```
⚠️ SECURITY ISSUE DETECTED: Malicious skill "oracle" found
---
RECOMMENDED ACTION:
1. Delete /path/to/.openclaw/skills/oracle/skill.md
2. Run: openclaw gateway restart
3. Verify: bash asf-trust-check.py

To execute automatically, reply: AUTO-FIX
```

---

## Usage Examples

```bash
# Generate prompts from CIO report
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --output FIX-PROMPTS.md

# Dry-run mode (no changes)
python3 asf-fix-prompt-generator.py --input ASF-CIO-SECURITY-REPORT.md --dry-run

# Auto-apply with supervisor gate
python3 asf-fix-prompt-generator.py --auto-apply --supervisor-gate --verify-fixes

# Scan specific directory
python3 asf-fix-prompt-generator.py --scan ~/agent-security-framework --output FIX-PROMPTS.md
```

---

## Priority
HIGH - Critical for closed-loop security architecture

---
*Generated from ASF-43 White Paper v4 requirements*
*Reviewed by Grok Heavy - Score: 8.8/10*
