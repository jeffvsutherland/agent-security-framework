# ASF-49: Remote Partner Installation

## Overview
Guide for partner deployment.

## Security
Use environment variables only. Never hardcode credentials.

## Sprint Goal
## 🏁 Sprint Goal
Remote partner install process secured and documented for Clawdbot rollout.

## ✅ Definition of Done (DoD) – Mandatory (from memory.md)
- Code written, reviewed, integrated
- Automated tests pass (unit/integration + security scans)
- **Zero secrets** (APIs, passwords, emails, keys, tokens) – verified by scan; use env vars/GitHub Secrets only
- Documented
- Outcome validated against Sprint Goal
- CI/CD pipeline green and releasable

**Aligned with Clawdbot-Moltbot-Open-Claw Scrum Expansion Pack (soul/brain/memory.md sections)**

### From Partner
- [ ] IP/hostname only (no credentials provided to ASF)
- [ ] Sudo access on remote machine
- [ ] Open ports: 22 (SSH), 80/443 (web), WebSocket for OpenClaw

### From ASF Team
- [ ] Installation scripts prepared
- [ ] Temporary tokens via GitHub Secrets or vault (NEVER commit/store passwords or SSH keys)
- [ ] Configuration files ready
