# ASF-18: ASF Scrum Process & Protocol

> **Important:** All code touching Clawdbot-Moltbot-Open-Claw MUST pass the security table below before merge.

## Overview
This document outlines the Scrum process and protocols for ASF development.

## Current Protocol Documents

The complete ASF protocol is maintained in:

| Document | Description |
|----------|-------------|
| [MISSION-CONTROL-GUIDE.md](./MISSION-CONTROL-GUIDE.md) | Full guide for Mission Control board usage |
| [OPENCLAW-AGENT-PROTOCOL.md](./OPENCLAW-AGENT-PROTOCOL.md) | Core Scrum protocol for autonomous teams |

## Quick Reference

### Roles
- **Product Owner:** Raven (@AgentSaturdayASFBot)
- **Scrum Master:** Jeff Sutherland
- **Developers:** All other agents (Sales, Deploy, Social, Research, Main)

### Ceremonies
- **Daily SCRUM:** Triggered by typing "SCRUM" in supergroup
- **Hourly Heartbeat:** Every 60 minutes, post update in supergroup

### Definition of Done
- Code/deliverables written and complete
- Documentation updated
- Increment deployable/usable
- Deliverables committed to workspace
- Story status updated to review
- Code review completed by Grok Heavy in review column
- Product Owner (Raven) acceptance

## Code Review Gate - Open-Claw Security Checklist

All code touching Clawdbot-Moltbot-Open-Claw MUST pass this security table before merge:

| Review Item | Tool/Command in ASF | Pass Criteria for Clawdbot/Moltbot/Open-Claw |
|------------------------------|--------------------------------------|---------------------------------------------|
| Least-privilege Docker run | docker_setup_agentfriday.py + --cap-drop | No host mounts except /tmp/scratch; read-only rootfs |
| Network isolation | port-scan-detector.sh + nftables | Only 443 outbound + localhost WhatsApp bridge |
| Capability & seccomp | infrastructure-security-check.sh | --security-opt apparmor + no-new-privs |
| Fake-skill / prompt injection| fake-agent-detector.sh | Scan every skill JSON before load |
| Secret leakage | trufflehog / gitleaks in CI | Zero hard-coded keys in .openclaw |

## Automated Security Check

Add to hourly sprint check:

```bash
./security-tools/infrastructure-security-check.sh --target ../.openclaw && \
echo "✅ ASF-18 Code Review gate passed for Open-Claw" >> AGENT-COMMUNICATION-LOG.md
```

## Quick Start Commands

```bash
# 1. Clone fresh
git clone https://github.com/jeffvsutherland/agent-security-framework.git
cd agent-security-framework

# 2. Run full ASF Docker template on Open-Claw
cd docker-templates
python3 docker_setup_agentfriday.py --target ../.openclaw --secure-mode

# 3. Fire code-review gate
./10am-compliance-check.sh --claw
```

## Related Documents
- [ASF Main README](./README.md)
- [YARA Rules](./docs/asf-5-yara-rules/)
- [Spam Reporting](./security-tools/moltbook-spam-monitor.sh)
- [Docker Templates](./docker-templates/)
- [Security Tools](./security-tools/)

---
*Last Updated: 2026-02-22*
