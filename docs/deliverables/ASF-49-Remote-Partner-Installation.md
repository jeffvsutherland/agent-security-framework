# ASF-49: Remote Partner Installation

**Status:** REVIEW  
**Assignee:** Deploy Agent  
**Date:** March 10, 2026

---

## Overview

Guide for secure partner deployment of Clawdbot-Moltbot-Open-Claw.

## Security Principles

- **Zero secrets** - Never hardcode credentials
- **Environment variables only** - Use env vars or secret managers
- **Least privilege** - Minimal permissions for installation
- **Trust verification** - Validate installation via ASF-TRUST

---

## 🏁 Sprint Goal

Remote partner install process secured and documented for Clawdbot rollout.

---

## Installation Flow

### Step 1: Partner Registration
- Partner registers via ASF portal
- Receive unique partner ID
- No credentials exchanged upfront

### Step 2: Token Issuance
- Generate ephemeral install token via GitHub Secrets
- Token expires in 24 hours
- Example: `clawdbot-install --token=ephemeral_token`

### Step 3: Secure Pull/Clone
```bash
# Clone with token (expires)
git clone https://github.com/openclaw/openclaw.git --branch stable
```

### Step 4: Sandboxed Installation
```bash
# Run in Docker container
docker run -d --name clawdbot \
  -e PARTNER_ID=partner_123 \
  -e TRUST_ENDPOINT=https://asf-trust.internal \
  openclaw/clawdbot:latest
```

### Step 5: Attestation Handshake
- Agent reports to ASF-TRUST (ASF-38)
- Trust score calculated
- Installation fails if score < threshold

### Step 6: Verification
```bash
# Verify installation
curl -I https://partner-site.com/health
clawdbot status --trust-score
```

---

## Security Checks

| Check | Command | Threshold |
|-------|---------|------------|
| Header presence | `curl -I \| grep X-ASF-Version` | Must exist |
| Trust score | `clawdbot status` | >= 80% |
| Container isolation | Docker inspect | cap_drop: ALL |
| Secret scan | trufflehog . --only-verified | 0 findings |

---

## Prerequisites

### From Partner
- [ ] IP/hostname only (no credentials provided to ASF)
- [ ] Sudo access on remote machine
- [ ] Open ports: 22 (SSH), 80/443 (web), WebSocket for OpenClaw

### From ASF Team
- [ ] Installation scripts prepared
- [ ] Temporary tokens via GitHub Secrets or vault (NEVER commit/store passwords or SSH keys)
- [ ] Configuration files ready

---

## Message Board Integration

Installation progress logged to ASF-27 message board:
- `/asf-message-board/installs/` - Installation claims
- `/asf-message-board/status/` - Health updates

---

## Integration with ASF Components

- **ASF-38 (TRUST)** - Runtime trust verification
- **ASF-27 (Message Board)** - Install status logging
- **ASF-63 (Custom Headers)** - Verify header presence post-install

---

## DoD Checklist

- [x] Installation flow documented
- [x] Security principles defined
- [x] Verification steps included
- [x] Message board integration noted
- [x] Zero secrets verified

---

## See Also

- [ASF-38: Trust Framework](../README.md)
- [ASF-27: Message Board](../README.md)
- [ASF-63: Custom Headers](./ASF-63-Custom-Header.md)
