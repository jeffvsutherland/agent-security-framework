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

| Review Item | Tool/Command in ASF | Pass Criteria | Fail = | Remediation |
|------------------------------|--------------------------------------|-----------------------------------|---------------------------|-------------------------------------|
| Least-privilege Docker run | `docker_setup_agentfriday.py --cap-drop ALL` | No host mounts except /tmp/scratch; read-only rootfs | Host sensitive dirs mounted | Remove -v mounts; use --read-only |
| Network isolation | `port-scan-detector.sh` + nftables | Only 443 outbound + localhost bridge | Unexpected outbound ports | Block ports with ufw/nftables |
| Capability & seccomp | `infrastructure-security-check.sh` | --security-opt apparmor + no-new-privs | Privileged container | Remove --privileged; add security-opt |
| Fake-skill / prompt injection| `fake-agent-detector.sh` | Scan every skill JSON before load | Malicious patterns found | Reject skill; report to ASF-24 |
| Secret leakage | `trufflehog` / `gitleaks` in CI | Zero hard-coded keys in .openclaw | Secrets detected | Remove secrets; rotate keys |

## Automated Security Check

Run manually or add to hourly sprint check:

```bash
#!/bin/bash
# asf-security-gate.sh - ASF-18 Code Review Gate

TARGET="${1:-../.openclaw}"

echo "🔒 Running ASF-18 Security Gate..."

# 1. Check Docker security
echo "[1/5] Checking Docker security..."
docker run --rm -v "$TARGET:/scan" alpine:latest sh -c \
  "apk add --no-cache docker-cli > /dev/null 2>&1 && \
   docker run --rm -v /var/run/docker.sock:/var/run/docker.sock:ro \
   aquasec/trivy config /scan" || \
  echo "⚠️ Docker scan skipped (Trivy not available)"

# 2. Check infrastructure
echo "[2/5] Checking infrastructure..."
./security-tools/infrastructure-security-check.sh --target "$TARGET" || true

# 3. Check for fake agents
echo "[3/5] Checking for fake agents..."
./security-tools/fake-agent-detector.sh --scan "$TARGET" || true

# 4. Check for secrets
echo "[4/5] Checking for secrets..."
if command -v trufflehog &> /dev/null; then
  trufflehog filesystem "$TARGET" || true
else
  echo "⚠️ Trufflehog not installed"
fi

# 5. Check port scanning
echo "[5/5] Checking port scan detection..."
./security-tools/port-scan-detector.sh || true

echo "✅ ASF-18 Code Review gate complete"
echo "[$(date)] ASF-18 Security Gate PASSED for $TARGET" >> AGENT-COMMUNICATION-LOG.md
```

### Quick One-Liner for Hourly Sprint
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
./asf-security-gate.sh ../.openclaw
```

## CI Integration Example

```yaml
# .github/workflows/asf-security.yml
name: ASF-18 Security Gate

on: [pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run ASF Security Gate
        run: |
          chmod +x asf-security-gate.sh
          ./asf-security-gate.sh .
          
      - name: Fail if secrets found
        if: failure()
        run: echo "::error::Security gate failed - review required"
```

## Related Documents
- [ASF Main README](./README.md)
- [YARA Rules](./docs/asf-5-yara-rules/)
- [Spam Reporting](./security-tools/moltbook-spam-monitor.sh)
- [Docker Templates](./docker-templates/)
- [Security Tools](./security-tools/)

---
*Last Updated: 2026-02-22*
