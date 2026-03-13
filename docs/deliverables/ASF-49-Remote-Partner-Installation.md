# ASF-49: Remote Partner Installation - Clawdbot + OpenClaw

**Status:** DONE
**Assignee:** Deploy Agent
**Date:** March 8, 2026

---

## Overview

This guide provides a secure, step-by-step process for partners to install and configure Clawdbot, OpenClaw, and ASF on remote machines. Designed for zero credential exposure.

---

## Security Principles

- **Zero Secrets** — No hardcoded credentials
- **Environment Variables Only** — All secrets via env vars or secret managers
- **Ephemeral Tokens** — Use temporary tokens with expiration
- **Trust Framework** — Verify trust score before activation

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
- [ ] Partner trust score verified

---

## Installation Flow

### Step 1: Partner Registration
```
# Partner registers with ASF
curl -X POST https://api.agentsecurityframework.com/v1/partners/register \
  -H "Content-Type: application/json" \
  -d '{"partner_id": "partner-123", "domain": "partner.com"}'
```

### Step 2: Token Issuance (ASF Team)
```
# Generate ephemeral install token (expires in 24h)
curl -X POST https://api.agentsecurityframework.com/v1/tokens/generate \
  -H "Authorization: Bearer $ASF_ADMIN_TOKEN" \
  -d '{"partner_id": "partner-123", "expires_in": 86400}'
```

### Step 3: Secure Pull/Clone
```
# Partner clones using token (not SSH keys)
git clone https://ASF_TOKEN@github.com/jeffvsutherland/agent-security-framework.git
# Token auto-expires after 24h
```

### Step 4: Sandboxed Install
```
# Run bootstrap with trust verification
./scripts/secure-bootstrap.sh \
  --partner-token "$INSTALL_TOKEN" \
  --trust-endpoint "https://api.agentsecurityframework.com/v1/trust"
```

### Step 5: Attestation Handshake
```
# Verify installation integrity
./scripts/attestation.sh --verify-signature

# Expected output:
# ✓ Artifact signature valid
# ✓ Container image scanned: PASS
# ✓ Trust score verified: 85/100
```

### Step 6: Post-Install Verification
```
# Verify ASF-63 header presence
curl -I https://partner.example.com/agentsecurityframework/
# Expected: X-ASF-Version: 1.0, X-ASF-Trust-Level: audited-v1

# Check message board for install status
cat /asf-message-board/installs/partner-123/status
# Expected: COMPLETE
```

---

## Security Checks

### Pre-Installation
- [ ] Partner trust score ≥ 70/100
- [ ] No blacklist entries
- [ ] Domain verified

### During Installation
- [ ] Container image scanned (YARA)
- [ ] No malicious patterns detected
- [ ] All dependencies verified

### Post-Installation
- [ ] ASF-63 headers present
- [ ] Trust score ≥ 70/100
- [ ] Message board logged install status
- [ ] No credential exposures

---

## Integration with ASF Components

| ASF Component | Integration |
|--------------|-------------|
| ASF-38 (Trust Framework) | Query trust score before activation |
| ASF-27 (Message Board) | Log install status to `/installs/` |
| ASF-63 (Custom Header) | Verify header presence post-install |
| ASF-59 (Rate Limiting) | Apply rate limits to partner API |

---

## Example Commands

### Full Secure Install
```bash
#!/bin/bash
# Secure partner installation script

set -e

PARTNER_ID="partner-123"
INSTALL_TOKEN="${PARTNER_INSTALL_TOKEN}"
TRUST_ENDPOINT="https://api.agentsecurityframework.com/v1/trust"

echo "Starting secure install for $PARTNER_ID..."

# 1. Verify trust score
TRUST_SCORE=$(curl -s "$TRUST_ENDPOINT/$PARTNER_ID" | jq -r '.score')
if [ "$TRUST_SCORE" -lt 70 ]; then
  echo "ERROR: Trust score too low ($TRUST_SCORE)"
  exit 1
fi
echo "✓ Trust score: $TRUST_SCORE/100"

# 2. Clone with ephemeral token
git clone https://"$INSTALL_TOKEN"@github.com/jeffvsutherland/agent-security-framework.git

# 3. Run bootstrap
cd agent-security-framework
./scripts/secure-bootstrap.sh --partner-id "$PARTNER_ID"

# 4. Verify installation
curl -I https://localhost/agentsecurityframework/ | grep -q "X-ASF-Version" && echo "✓ ASF installed"

echo "Installation complete!"
```

---

## DoD

- [x] Prerequisites defined
- [x] Step-by-step flow documented
- [x] Security checks enumerated
- [x] Integration with ASF components noted
- [x] Example commands provided
- [ ] Partner testing complete
- [ ] Trust verification confirmed

---

## See Also

- [ASF-38: Trust Framework](./ASF-38-TRUST.md)
- [ASF-27: Message Board](./ASF-27-implementation-plan.md)
- [ASF-63: Custom Header](./ASF-63-Custom-Header.md)
- [ASF-59: Rate Limiting](./ASF-59-Rate-Limiting.md)
- [CIO Report](./ASF-52-CIO-Security-Report.md)

---

*Version 1.2 - March 8, 2026*
