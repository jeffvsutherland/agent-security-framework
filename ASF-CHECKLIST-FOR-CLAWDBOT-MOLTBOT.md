# ASF Checklist for Clawdbot-Moltbot-Open-Claw

## Quick Start

Deploy a fully secured Clawdbot-Moltbot-Open-Claw stack in minutes:

```bash
# 1. Clone and setup
git clone https://github.com/jeffvsutherland/agent-security-framework
cd agent-security-framework

# 2. Quick install (ASF-4)
bash deployment-guide/asf-quick-setup.sh

# 3. One-command secure deploy
bash openclaw-secure-deploy.sh
```

---

## Component Mapping

### Clawdbot (WhatsApp Bridge)

| Security Layer | ASF Story/Tool | Status |
|--------------|----------------|--------|
| Docker hardening | ASF-2 docker-templates | ✅ |
| Port scan detection | security-tools/port-scan-detector.sh | ✅ |
| Fake agent detection | security-tools/fake-agent-detector.sh | ✅ |
| Spam monitoring | ASF-22 + security-tools/moltbook-spam-monitor.sh | ✅ |
| Credential protection | ASF-5 YARA response | ✅ |

**Deploy:** `docker-templates/python/` or `docker-templates/bash/`

---

### Moltbot (PC Control)

| Security Layer | ASF Story/Tool | Status |
|--------------|----------------|--------|
| Voice/REST isolation | ASF-4 deployment-guide | ✅ |
| Network lockdown | port-scan-detector.sh | ✅ |
| Prompt injection detection | fake-agent-detector.sh | ✅ |
| Infrastructure checks | infrastructure-security-check.sh | ✅ |
| Privacy mode | check-bot-privacy.py | ✅ |

**Deploy:** `deployment-guide/spawn-asf-agents.sh --moltbot`

---

### Open-Claw (Host Isolation)

| Security Layer | ASF Story/Tool | Status |
|--------------|----------------|--------|
| Docker least-privilege | ASF-2 (cap-drop, no-new-privs) | ✅ |
| YARA scanning | ASF-5 + security-tools/ | ✅ |
| Gateway integration | GATEWAY-INTEGRATION.md | ✅ |
| Code review process | ASF-18 + asf-18-code-review.sh | ✅ |
| Mission Control | ASF-23 + MISSION-CONTROL-GUIDE.md | ✅ |

**Deploy:** `openclaw-secure-deploy.sh`

---

## Security Checklist

### Pre-Deployment
- [ ] Git clone completed
- [ ] ASF quick setup run
- [ ] Docker installed
- [ ] Network firewall configured

### Deployment
- [ ] Docker templates applied (non-root, cap-drop)
- [ ] Network isolation configured (443 outbound only)
- [ ] Secrets managed (not in code)
- [ ] Evidence directories created with 700 permissions

### Post-Deployment
- [ ] Port scan detection running
- [ ] Fake agent detection active
- [ ] Spam monitoring enabled
- [ ] Gateway log monitoring active
- [ ] Hourly Scrum checks configured
- [ ] YARA rules in place

### Monitoring
- [ ] Access logs being collected
- [ ] Slack/Discord webhooks configured
- [ ] Incident response playbooks ready

---

## Stories Reference

| ASF | Description | URL |
|------|------------|-----|
| ASF-2 | Docker templates | `/docker-templates` |
| ASF-4 | Deployment guide | `/deployment-guide` |
| ASF-5 | YARA response | `ASF-5-YARA-RESPONSE.md` |
| ASF-18 | Code review process | `ASF-18-SCRUM-PROCESS.md` |
| ASF-20 | Enterprise integration | `ASF-ENTERPRISE-INTEGRATION-GUIDE.md` |
| ASF-22 | Spam monitoring | `ASF-22-SPAM-MONITORING.md` |
| ASF-23 | Mission Control | `MISSION-CONTROL-GUIDE.md` |
| ASF-24 | Spam reporting | `/spam-reporting-infrastructure` |
| ASF-26 | Website security | `ASF-26-WEBSITE-SECURITY.md` |

---

## Commands

### Daily Security Check
```bash
./security-tools/infrastructure-security-check.sh --target ../.openclaw
```

### Hourly Scrum Check
```bash
./asf-18-code-review.sh --target ../.openclaw
```

### YARA Scan
```bash
yara -r security-tools/*.yar .openclaw/skills/
```

### Spam Monitor
```bash
./security-tools/moltbook-spam-monitor.sh scan
```

---

## Emergency Contacts

- **Security Incidents:** #security-incidents (Slack)
- **On-call:** Rotate via Scrum standup
- **Documentation:** ASF-5-YARA-RESPONSE.md

---

**Last Updated:** 2026-02-23  
**Version:** 1.0.0
