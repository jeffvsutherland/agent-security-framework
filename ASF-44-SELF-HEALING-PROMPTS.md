# ASF-44: Self-Healing Prompt Generator

**Story:** Generate corrective prompts for OpenClaw to auto-remediate vulnerabilities

## Description
Implement the self-healing security architecture that generates corrective prompts back to OpenClaw when vulnerabilities are detected. This closes the loop from detection → intervention → remediation.

## Deliverables
1. **Prompt Generator Script** - `asf-self-healing-prompts.py`
   - Analyzes scan results from YARA, trust scoring, syscall monitoring
   - Generates human-readable corrective prompts for OpenClaw
   - Maps vulnerabilities to specific fix actions

2. **Integration with Bootup Scan**
   - Run prompt generation after every boot scan
   - Output prompts to `/var/log/asf/healing-prompts/`

3. **Auto-Remediation Hooks**
   - Option to auto-apply safe fixes (config changes, skill removal)
   - Guardrail confirmation before destructive actions

## Acceptance Criteria
- [ ] Scans detect vulnerability → generates fix prompt within 30 seconds
- [ ] Prompts are in language non-technical staff can execute
- [ ] Integration with existing ASF-35, ASF-38, ASF-42 tools
- [ ] Test cases: malicious skill detection → prompt → remediation

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

## Priority
HIGH - Critical for closed-loop security architecture

---
*Generated from ASF-43 White Paper v4 requirements*
