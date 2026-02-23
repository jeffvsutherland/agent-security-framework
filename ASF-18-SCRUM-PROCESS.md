# ASF-18: Code Review Process for Agent Security

> **All code touching Clawdbot-Moltbot-Open-Claw MUST pass the security table below before merge.**

## Code Review Gate

Every ASF story must pass these security checks before moving to Done:

| Review Item | Tool/Command in ASF | Pass Criteria for Clawdbot/Moltbot/Open-Claw |
|------------------------------|--------------------------------------|---------------------------------------------|
| Least-privilege Docker run | `docker_setup_agentfriday.py --cap-drop` | No host mounts except /tmp/scratch; read-only rootfs |
| Network isolation | `port-scan-detector.sh` + nftables | Only 443 outbound + localhost WhatsApp bridge |
| Capability & seccomp | `infrastructure-security-check.sh` | `--security-opt apparmor + no-new-privs` |
| Fake-skill / prompt injection | `fake-agent-detector.sh` | Scan every skill JSON before load |
| Secret leakage | trufflehog / gitleaks in CI | Zero hard-coded keys in .openclaw |

## Automated Review in Scrum Loop

Add to hourly sprint check:
```bash
./security-tools/infrastructure-security-check.sh --target ../.openclaw && \
echo "✅ ASF-18 Code Review gate passed" >> AGENT-COMMUNIZATION_LOG.md
```

## Definition of Done (Extended)

1. Code/deliverables written and complete
2. Self-review minimum; peer review preferred
3. Documentation updated
4. Increment deployable/usable
5. **Security gate passed** (table above)
6. Public-facing: Grok Heavy audit complete
7. Product Owner (Raven) accepted
8. Committed to workspace
9. Status updated to review → done

---

**Story:** ASF-18  
**Status:** Ready for Review  
**Version:** 1.0.0
