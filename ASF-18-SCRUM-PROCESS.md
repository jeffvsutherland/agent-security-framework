# ASF-18: Code Review Process for Agent Security

> **All code touching Clawdbot-Moltbot-Open-Claw MUST pass the security table below before merge.**

## Code Review Gate

Every ASF story must pass these security checks before moving to Done:

| Review Item | Tool/Command in ASF | Pass Criteria for Clawdbot/Moltbot/Open-Claw |
|------------------------------|--------------------------------------|---------------------------------------------|
| Least-privilege Docker run | `docker_setup_agentfriday.py --cap-drop` | No host mounts except /tmp/scratch; read-only rootfs |
| Network isolation | `port-scan-detector.sh` | Only 443 outbound + localhost WhatsApp bridge |
| Capability & seccomp | `infrastructure-security-check.sh` | `--security-opt apparmor + no-new-privs` |
| Fake-skill / prompt injection | `fake-agent-detector.sh` | Scan every skill JSON before load |
| Secret leakage | trufflehog / gitleaks in CI | Zero hard-coded keys in .openclaw |
| YARA malware scan | `yara -r *.yar skills/` | No malicious patterns detected |

## Unified Open-Claw Security Table

| Component | ASF-2 Docker | ASF-5 YARA Scan | ASF-4 Deployment Command | Pass Criteria |
|-----------|---------------|------------------|--------------------------|---------------|
| Clawdbot | --secure-mode | credential-theft.yar | spawn-asf-agents.sh --claw | No host FS except /tmp |
| Moltbot | cap-drop ALL | prompt-injection.yar | check-bot-privacy.py | localhost WhatsApp only |
| Open-Claw host | AppArmor | fake-agent.yar | asf-openclaw-scanner.py | Zero secrets, read-only rootfs |

## Automated Review in Scrum Loop

Add to hourly sprint check:
```bash
./security-tools/infrastructure-security-check.sh --target ../.openclaw && \
echo "✅ ASF-18 Code Review gate passed" >> AGENT-COMMUNICATION_LOG.md

# YARA scan (ASF-5)
yara -r docs/asf-5-yara-rules/*.yar .openclaw/skills/ && echo "YARA clean" >> hourly-log.md
```

One-command full secure deploy:
```bash
bash openclaw-secure-deploy.sh
```

## Definition of Done (Extended)

1. Code/deliverables written and complete
2. Self-review minimum; peer review preferred
3. Documentation updated
4. Increment deployable/usable
5. **Security gate passed** (table above)
6. **YARA scan passed** (no malicious patterns)
7. Public-facing: Grok Heavy audit complete
8. Product Owner (Raven) accepted
9. Committed to workspace
10. Status updated to review → done

---

**Story:** ASF-18  
**Status:** Ready for Review  
**Version:** 1.0.1
