# ASF Checklist for Clawdbot-Moltbot-Open-Claw

## Quick Start: Secure Your Stack in 5 Minutes

```bash
# 1. Clone the repo
git clone https://github.com/jeffvsutherland/agent-security-framework.git
cd agent-security-framework

# 2. Run quick setup
./deployment-guide/asf-quick-setup.sh

# 3. Secure deploy
./openclaw-secure-deploy.sh
```

## Component Mapping

### Clawdbot (WhatsApp Bridge)
| Risk | ASF Story/Tool | Status |
|------|----------------|--------|
| WhatsApp API keys exposed | ASF-2 Docker | ✅ |
| Unauthorized access | ASF-5 YARA | 📋 |
| Fake agent injection | fake-agent-detector.sh | ✅ |
| Port scanning | port-scan-detector.sh | ✅ |
| Secret leakage | trufflehog in CI | 📋 |

### Moltbot (PC Control)
| Risk | ASF Story/Tool | Status |
|------|----------------|--------|
| Voice stack security | ASF-2 Docker | ✅ |
| Spam from bot | ASF-22 Spam Monitor | ✅ |
| Malicious skills | ASF-5 YARA | 📋 |
| Discord/Telegram leaks | infrastructure-security-check.sh | ✅ |
| Unauthorized execution | fake-agent-detector.sh | ✅ |

### Open-Claw (Host)
| Risk | ASF Story/Tool | Status |
|------|----------------|--------|
| Host compromise | ASF-2 Docker | ✅ |
| Network isolation | port-scan-detector.sh | ✅ |
| Privilege escalation | ASF-18 Code Review | ✅ |
| Configuration drift | asf-quick-setup.sh | ✅ |
| Credential theft | ASF-5 YARA | 📋 |

## Deployment Order

### Phase 1: Foundation (Day 1)
1. ✅ ASF-2: Docker templates deployed
2. ✅ ASF-4: Quick setup tested
3. ✅ ASF-18: Code review process in place

### Phase 2: Protection (Day 2)
1. 📋 ASF-5: YARA rules implemented
2. ✅ ASF-22: Spam monitoring active
3. ✅ ASF-24: Bad actor database running

### Phase 3: Hardening (Day 3)
1. 📋 ASF-26: Website security configured
2. ✅ ASF-20: Enterprise integration ready
3. 🔄 Testing & validation

## Security Checklist

### Pre-Deploy
- [ ] GitHub tokens rotated
- [ ] Docker secrets configured
- [ ] Network isolation verified
- [ ] Backup tested

### Post-Deploy
- [ ] All services healthy
- [ ] Logging to central system
- [ ] Alerts configured
- [ ] Run asf-openclaw-scanner.py

### Daily Operations
- [ ] Hourly security check (via ASF-18)
- [ ] YARA scan of new skills
- [ ] Review spam reports
- [ ] Check infrastructure logs

### Weekly
- [ ] Update Docker images
- [ ] Rotate credentials
- [ ] Review false positives
- [ ] Update YARA rules

## One-Command Operations

### Full Security Scan
```bash
./security-tools/infrastructure-security-check.sh
```

### YARA Scan
```bash
yara -r docs/asf-5-yara-rules/*.yar ~/.asf/skills/
```

### Spam Detection
```bash
./security-tools/moltbook-spam-monitor.sh
```

### Agent Health
```bash
python3 deployment-guide/asf-openclaw-scanner.py
```

## Emergency Response

### If Compromised
1. Isolate container: `docker network disconnect`
2. Preserve evidence: `cp -r ~/.asf ~/asf-backup-$(date)`
3. Rotate all credentials
4. Review logs: `~/asf-backup-*/logs/`
5. Notify via configured webhooks

### Contact
- Security issues: See RESPONSIBLE_DISCLOSURE.md
- Enterprise support: ASF-20 integration docs

## Related Documentation

| Document | Purpose |
|----------|---------|
| ASF-SCRUM-PROTOCOL.md | Team process |
| deployment-guide/README.md | Deployment |
| ASF-18-SCRUM-PROCESS.md | Code review |
| ASF-ENTERPRISE-INTEGRATION-GUIDE.md | Enterprise |

---
**Last Updated:** February 2026
**Version:** 1.0.0
