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

## Component Mapping & Status

| Component | ASF Story/Tool | Status | Next Action |
|-----------|----------------|--------|-------------|
| **Moltbook container** | ASF-22 Spam Monitoring | In Progress | Tune thresholds, add webhook alerts |
| **Web dashboard** | ASF-26 Website Security | Ready | Deploy nginx with headers + rate limit |
| **Agent registration** | ASF-2 Docker templates + fake-agent-detector | Deployed | Run daily scan |
| **Enterprise visibility** | ASF-20 + ASF-17 Dashboard | Planned | Add Prometheus exporter |
| **Code review** | ASF-18 + asf-18-code-review.sh | Deployed | Hourly checks active |
| **Spam reporting** | ASF-24 + spam-reporting-infrastructure | Deployed | Add to webhook |
| **Mission Control** | ASF-23 + MISSION-CONTROL-GUIDE.md | Deployed | Connect Gateway |

---

## Detailed Component Status

### Clawdbot (WhatsApp Bridge)

| Security Layer | ASF Story/Tool | Status |
|--------------|----------------|--------|
| Docker hardening | ASF-2 docker-templates | ✅ |
| Port scan detection | security-tools/port-scan-detector.sh | ✅ |
| Fake agent detection | security-tools/fake-agent-detector.sh | ✅ |
| Spam monitoring | ASF-22 + security-tools/moltbook-spam-monitor.sh | 🔲 |
| Credential protection | ASF-5 YARA response | ✅ |

**Deploy:** `docker-templates/python/` or `docker-templates/bash/`

**Test:** Attempt spam post → verify block + alert

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

**Test:** Run infrastructure-security-check.sh

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

**Test:** Run openclaw-secure-deploy.sh

---

## Deployment Sequence

### Phase 1: Foundation (Do First)
- [x] Docker templates (ASF-2)
- [x] Code review process (ASF-18)
- [ ] Test: Run asf-18-code-review.sh

### Phase 2: Runtime Security
- [x] Spam monitoring (ASF-22)
- [x] Gateway integration (ASF-24)
- [ ] Test: Attempt spam → verify detection + alert

### Phase 3: Perimeter
- [x] Website security (ASF-26)
- [ ] Test: nginx with headers + rate limiting

### Phase 4: Enterprise
- [ ] Enterprise dashboard (ASF-17)
- [ ] Prometheus metrics (ASF-20)
- [ ] Test: View spam/website metrics in dashboard

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

## Test/Validation Steps

### Spam Monitor Test
```bash
# Trigger test detection
echo "Free Bitcoin doubled!!! Act NOW" | ./security-tools/moltbook-spam-monitor.sh test

# Verify alert
curl -X POST "$WEBHOOK_URL" -d "{\"text\": \"Test spam alert\"}"
```

### Website Security Test
```bash
# Test rate limiting
for i in {1..15}; do curl -I https://example.com/api/; done

# Verify blocked (should get 429)
```

### Infrastructure Check
```bash
./security-tools/infrastructure-security-check.sh --target ../.openclaw
```

---

## Stories Reference

| ASF | Description | URL |
|------|------------|-----|
| ASF-2 | Docker templates | `/docker-templates` |
| ASF-4 | Deployment guide | `/deployment-guide` |
| ASF-5 | YARA response | `ASF-5-YARA-RESPONSE.md` |
| ASF-18 | Code review process | `ASF-18-SCRUM-PROCESS.md` |
| ASF-20 | Enterprise integration | `/docs/asf-20-enterprise-integration` |
| ASF-22 | Spam monitoring | `/docs/asf-22-spam-monitoring` |
| ASF-23 | Mission Control | `MISSION-CONTROL-GUIDE.md` |
| ASF-24 | Spam reporting | `/spam-reporting-infrastructure` |
| ASF-26 | Website security | `/docs/asf-26-website` |

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
**Version:** 1.0.1
