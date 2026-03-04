# ASF-45: Security Fix Automation Prompts

**Created:** 2026-03-04
**Status:** Ready for Review

## 🎯 Sprint Goal
**"Agents can self-heal 80% of security vulnerabilities using generated prompts within 30 minutes of detection."**

---

## 🎯 Objective
Create automation prompts that agents can use to automatically fix security issues found in scans.

## ✅ INVEST Criteria
- **Independent:** Each prompt works standalone
- **Negotiable:** Commands can be adapted per environment
- **Valuable:** Reduces manual security fix time by 80%
- **Estimable:** ~5 hours effort
- **Small:** Each fix prompt is a discrete unit
- **Testable:** Run scan → generate prompt → apply → verify fixed

## ✅ Definition of Done (DoD) Checklist
- [ ] VPN fix prompt complete with Tailscale
- [ ] Firewall fix prompt complete with UFW
- [ ] DNS fix prompt complete (Cloudflare/Quad9)
- [ ] Antivirus fix prompt complete (ClamAV)
- [ ] All commands use environment variables (no hardcoded IPs/ports)
- [ ] Each prompt has "Review before execution" warning
- [ ] Security validation step added to each prompt
- [ ] Test script validates each fix

## ✅ Security Acceptance Criteria
- [ ] No hardcoded credentials in any prompt
- [ ] No hardcoded IP addresses
- [ ] No hardcoded ports
- [ ] All sensitive values reference environment variables
- [ ] Each prompt includes "Review before execution" step

---

## Prompt Template (SECURE)

```bash
#!/bin/bash
# SECURITY FIX: ${FIX_NAME}
# IMPORTANT: Review before execution!

# Step 1: Verify environment variables are set
if [ -z "$${REQUIRED_VAR}" ]; then
  echo "ERROR: Required environment variable REQUIRED_VAR not set"
  exit 1
fi

# Step 2: Review - human approval required
echo "Review this fix before execution:"
echo "  - Target: $${TARGET_SYSTEM}"
echo "  - Action: ${ACTION_DESCRIPTION}"
read -p "Proceed? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Aborted."
  exit 0
fi

# Step 3: Apply fix using env vars only
$${COMMAND_USING_ENV_VARS}
```

---

## 1. VPN Fix (Tailscale)

**Security:** Uses auth key from environment variable only.

```bash
#!/bin/bash
# VPN Enable via Tailscale
# Env vars: TAILSCALE_AUTH_KEY, TAILSCALE_HOST

# Validate
[ -z "$TAILSCALE_AUTH_KEY" ] && echo "Set TAILSCALE_AUTH_KEY" && exit 1

# Install
curl -fsSL https://tailscale.com/install.sh | env TAILSCALE_AUTH_KEY="$TAILSCALE_AUTH_KEY" sh

# Verify
tailscale status
```

---

## 2. Firewall Fix (UFW)

**Security:** Uses default deny, allows only configured ports via env.

```bash
#!/bin/bash
# Firewall Configuration (UFW)
# Env vars: ALLOWED_PORTS (comma-separated)

# Default deny
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow configured ports only
for port in ${ALLOWED_PORTS//,/ }; do
  sudo ufw allow $port/tcp
done

sudo ufw enable
sudo ufw status numbered
```

---

## 3. DNS Security Fix

**Security:** Uses resolvers from environment, no hardcoded IPs.

```bash
#!/bin/bash
# DNS Security Configuration
# Env vars: DNS_RESOLVER (e.g., 1.1.1.1, 9.9.9.9)

[ -z "$DNS_RESOLVER" ] && echo "Set DNS_RESOLVER" && exit 1

echo "nameserver $DNS_RESOLVER" | sudo tee /etc/resolv.conf
```

---

## 4. Antivirus Fix (ClamAV)

**Security:** Install only, uses system package manager.

```bash
#!/bin/bash
# ClamAV Installation
# No credentials needed - uses system packages

sudo apt update
sudo apt install -y clamav clamav-freshclam
sudo systemctl start clamav-freshclam
clamscan --version
```

---

## Testing Instructions

```bash
# Test VPN prompt (dry run)
export TAILSCALE_AUTH_KEY="test_key"
# Review output before actual execution

# Test Firewall prompt
export ALLOWED_PORTS="22,80,443"
# Review rules before applying

# Run security validation
./validate-secure-prompts.sh
```

---

*Status: Ready for security scan + review*

---
**Aligned with Clawdbot-Moltbot-Open-Claw Scrum Expansion Pack (soul/brain/memory.md)**


## 🏁 Sprint Goal
Agents can self-heal 80% of security vulnerabilities using generated prompts within 10 minutes of detection.

## ✅ Definition of Done (DoD) – Mandatory (from memory.md)
- Code written, reviewed, integrated
- Automated tests pass (unit/integration + security scans)
- **Zero secrets** (APIs, passwords, emails, keys, tokens) – verified by scan; use env vars/GitHub Secrets only
- Documented
- Outcome validated against Sprint Goal
- CI/CD pipeline green and releasable

**Aligned with Clawdbot-Moltbot-Open-Claw Scrum Expansion Pack (soul/brain/memory.md sections)**
