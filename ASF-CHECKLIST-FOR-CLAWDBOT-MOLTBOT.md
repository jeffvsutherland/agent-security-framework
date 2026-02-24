# ASF Checklist for Clawdbot-Moltbot-Open-Claw

## Quick Start - Secure Your Stack in 5 Minutes

```bash
# One-command full secure deploy
git clone https://github.com/jeffvsutherland/agent-security-framework.git
cd agent-security-framework
./deployment-guide/openclaw-secure-deploy.sh
```

## Component Mapping

| Clawdbot/Moltbot/Open-Claw Component | ASF Story | Tool/Script | Priority |
|--------------------------------------|-----------|-------------|----------|
| **Docker Containers** | ASF-2 | `docker-templates/` | 🔴 Critical |
| **Spam Detection** | ASF-22 | `security-tools/moltbook-spam-monitor.sh` | 🔴 Critical |
| **Fake Agent Detection** | ASF-12 | `security-tools/fake-agent-detector.sh` | 🔴 Critical |
| **Website (scrumai.org)** | ASF-26 | `docs/asf-26-website/` | 🟠 High |
| **Enterprise Integration** | ASF-20 | `ASF-ENTERPRISE-*.md` | 🟡 Medium |
| **YARA Security Scanning** | ASF-5 | `docs/asf-5-yara-rules/` | 🔴 Critical |
| **Port Scan Protection** | ASF-9 | `security-tools/port-scan-detector.sh` | 🟠 High |
| **Infrastructure Security** | ASF-11 | `security-tools/infrastructure-security-check.sh` | 🟠 High |

## Deployment Order (Recommended)

### Phase 1: Core Security (Day 1)
1. **Docker Hardening** - Run secure Docker templates
   ```bash
   cd docker-templates
   python3 docker_setup_agentfriday.py --secure-mode
   ```

2. **Fake Agent Detection** - Block impersonators
   ```bash
   ./security-tools/fake-agent-detector.sh --scan .
   ```

3. **YARA Scanning** - Detect malicious skills
   ```bash
   yara -r docs/asf-5-yara-rules/*.yar .
   ```

### Phase 2: Monitoring (Day 2)
4. **Spam Monitoring** - Real-time detection
   ```bash
   ./security-tools/moltbook-spam-monitor.sh &
   ```

5. **Port Scan Protection** - Block reconnaissance
   ```bash
   ./security-tools/port-scan-detector.sh
   ```

### Phase 3: Enterprise (Day 3+)
6. **Website Hardening** - Secure public-facing site
   - See `docs/asf-26-website/SECURITY-HARDENING.md`

7. **Enterprise Integration** - SSO, RBAC, logging
   - See `ASF-ENTERPRISE-INTEGRATION-GUIDE.md`

## Security Checklist

- [ ] Docker containers run as non-root
- [ ] Containers have `--cap-drop ALL`
- [ ] Read-only root filesystem enabled
- [ ] No privileged containers
- [ ] YARA rules scan all new skills
- [ ] Spam monitoring active
- [ ] Fake agent detection running
- [ ] Port scan protection enabled
- [ ] Secrets managed via Vault or Docker secrets
- [ ] Logs forwarded to central logging
- [ ] HTTPS enforced on all web interfaces
- [ ] RBAC configured for admin access

## Quick Verification

```bash
# Run full security gate
./asf-security-gate.sh .

# Check Docker security
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy config .

# Verify no secrets
trufflehog filesystem .
```

## Related Documents

| Document | Description |
|----------|-------------|
| [deployment-guide/README.md](./deployment-guide/README.md) | Full deployment guide |
| [ASF-18-SCRUM-PROCESS.md](./ASF-18-SCRUM-PROCESS.md) | Security review process |
| [docs/asf-5-yara-rules/](./docs/asf-5-yara-rules/) | YARA detection rules |
| [spam-reporting-infrastructure/](./spam-reporting-infrastructure/) | Spam/bad actor tracking |

---
*Last Updated: 2026-02-23*
*For Clawdbot-Moltbot-Open-Claw deployment*
