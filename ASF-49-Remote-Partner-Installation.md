# ASF-49: Remote Partner Installation Guide

**Created:** 2026-03-04
**Status:** Ready for Review

## 🎯 Sprint Goal
**"Partner Clawdbot instance deployed and verified secure within 4 hours of SSH access, with zero credential exposure."**

---

## 🎯 Objective
Deploy Clawdbot, OpenClaw, and ASF on remote partner machine via SSH.

## ✅ SECURITY MANDATE (CRITICAL)
> **NEVER commit credentials. Use GitHub Secrets + temporary tokens only.**

- ❌ NO: `ssh user@host` with password in code
- ❌ NO: `export API_KEY="sk-xxx"` in scripts
- ❌ NO: `git commit` with `.env` files
- ✅ YES: GitHub Secrets + `os.getenv()` + temporary tokens
- ✅ YES: `.env.example` template (no real values)
- ✅ YES: 1-time SSH keys with expiration

## ✅ INVEST Criteria
- **Independent:** Can run standalone
- **Negotiable:** Adapts to partner environment
- **Valuable:** Enables partner deployment
- **Estimable:** ~4 hours
- **Small:** Single deployment package
- **Testable:** Verify all services running

## ✅ Definition of Done (DoD) Checklist
- [ ] SSH key-based auth (no passwords)
- [ ] Docker installed and verified
- [ ] OpenClaw deployed
- [ ] ASF security scan passed
- [ ] All services running
- [ ] Zero credentials in logs
- [ ] Partner verification received

## ✅ Security Acceptance Criteria
- [ ] No passwords in any file
- [ ] No API keys in any file
- [ ] No SSH credentials in any file
- [ ] Uses `.env.example` template only
- [ ] GitHub Secrets referenced
- [ ] Temporary tokens with expiration

---

## Prerequisites

- SSH access to remote server
- Root/sudo privileges
- Internet connection

---

## Installation Steps

### 1. Connect via SSH

```bash
ssh partner@$REMOTE_HOST
```

### 2. Install Docker

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker partner
```

### 3. Clone OpenClaw

```bash
git clone https://github.com/openclaw/openclaw.git
cd openclaw
```

### 4. Configure Environment

```bash
cp .env.example .env
# Edit .env with your API keys - use environment variables only
```

### 5. Deploy ASF

```bash
./deploy.sh
```

### 6. Verify Installation

```bash
docker ps
curl http://localhost:18789/health
```

---

## Security Checklist

- [ ] Use environment variables, not hardcoded secrets
- [ ] Enable firewall (UFW)
- [ ] Configure fail2ban
- [ ] Enable automatic security updates
- [ ] Set up backup rotation

---

*Full proposal: /workspace/proposals/REMOTE-PARTNER-INSTALLATION.md*

---
**Aligned with Clawdbot-Moltbot-Open-Claw Scrum Expansion Pack (soul/brain/memory.md)**
