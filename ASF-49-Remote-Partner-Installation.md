# ASF-49: Remote Partner Installation Guide

**Created:** 2026-03-04
**Status:** Review

## Overview

This guide provides step-by-step instructions for deploying Clawdbot, OpenClaw, and ASF on a remote partner machine via SSH.

**Security Note:** This guide uses environment variables only. Never include real credentials.

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
