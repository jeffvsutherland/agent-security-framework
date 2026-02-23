# ASF-18: Scrum Process for Agent Security Framework

> **All code touching Clawdbot-Moltbot-Open-Claw MUST pass the security table below before merge.**

## Overview

This document defines the Scrum process for the Agent Security Framework, including code review gates and security checklists that must be passed before any story is considered complete.

## Hybrid Human-AI Scrum Cadence

- **Hourly Sprint Checks**: ASF-Hourly-Sprint-Check-*.md pattern for rapid agent hardening
- **Daily Standups**: Via SCRUM command in supergroup
- **Definition of Done**: Includes YARA validation and security checklist

## Code Review Gate

All code changes must pass the following security review before being merged:

### Security Checklist for Clawdbot/Moltbot/Open-Claw

| Review Item | Tool/Command in ASF | Pass Criteria for Clawdbot/Moltbot/Open-Claw |
|------------------------------|--------------------------------------|---------------------------------------------|
| Least-privilege Docker run | docker_setup_agentfriday.py + --cap-drop | No host mounts except /tmp/scratch; read-only rootfs |
| Network isolation | port-scan-detector.sh + nftables | Only 443 outbound + localhost WhatsApp bridge |
| Capability & seccomp | infrastructure-security-check.sh | --security-opt apparmor + no-new-privs |
| Fake-skill / prompt injection | fake-agent-detector.sh | Scan every skill JSON before load |
| Secret leakage | trufflehog / gitleaks in CI | Zero hard-coded keys in .openclaw |
| YARA malware scan | yara -r docs/asf-5-yara-rules/ | No critical YARA hits on skill code |

## Automated Security Review

Add to hourly sprint check:

```bash
# Run infrastructure security check
./security-tools/infrastructure-security-check.sh --target ../.openclaw && \
echo "✅ ASF-18 Code Review gate passed for Open-Claw" >> AGENT-COMMUNICATION-LOG.md

# Run YARA scan on new skills
yara -r docs/asf-5-yara-rules/openclaw_malicious_skill.yar $SKILL_PATH || { echo "BLOCKED: YARA hit"; exit 1; }
```

## Integration with Definition of Done

Before moving any story to Done, verify:
- [ ] Security checklist complete
- [ ] YARA scan passed (for code/skills)
- [ ] No hardcoded secrets
- [ ] Docker run uses least privilege
- [ ] Network isolation verified

## Discord Bot Integration

The ASF-18 Discord bot provides secure communications for Moltbot alerts. Deploy via ASF-18-DISCORD-BOT-DEPLOYMENT.md.

## References

- ASF-5-YARA-RESPONSE.md - YARA response procedures
- docs/asf-5-yara-rules/ - Detection rules
- security-tools/ - Infrastructure security tools
- docker-templates/ - Secure Docker templates
