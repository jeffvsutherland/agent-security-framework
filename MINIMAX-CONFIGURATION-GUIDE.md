# Minimax Configuration Guide

**Last Updated:** 2026-02-22
**Purpose:** Ensure Minimax configuration persists across reboots

## Overview

Both **OpenClaw** (Docker) and **clawdbot** (local Mac) are configured to use Minimax as the primary AI provider. This guide documents the configuration and how to maintain it.

---

## Configuration Files

### OpenClaw (Docker)

**Config Location (on host):** `/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/`

This directory is mounted as a Docker volume to `/home/node/.openclaw` in the container.

**Key Files:**
- `openclaw.json` - Main configuration
  - Sets `agents.defaults.model.primary: "minimax/MiniMax-M2.5"`
- `auth-profiles/minimax:default.json` - Minimax API credentials
- `agents/*/agent/auth-profiles.json` - Per-agent auth profiles
- `agents/*/agent/models.json` - Model definitions

### clawdbot (Local Mac)

**Config Location:** `/Users/jeffsutherland/.clawdbot/`

**Key Files:**
- `clawdbot.json` - Main configuration
  - Sets `agents.defaults.model.primary: "minimax/MiniMax-M2.5"`
- `agents/main/agent/auth-profiles.json` - Auth credentials for main agent
- `agents/main/agent/models.json` - Model definitions for main agent
- `agents/{research,social,deploy,sales,product-owner}/agent/auth-profiles.json` - Per-agent auth
- `agents/{research,social,deploy,sales,product-owner}/agent/models.json` - Per-agent models

---

## Why Configuration Persists

### OpenClaw (Docker)
✅ **Persists automatically** - The openclaw-state directory is bind-mounted from the host filesystem, so all changes inside the container are saved on the Mac.

### clawdbot (Local Mac)
✅ **Persists automatically** - Configuration files are stored directly on the Mac filesystem in `~/.clawdbot/`

---

## Critical Configuration Points

### 1. Primary Model Setting

Both systems must have:
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "minimax/MiniMax-M2.5"
      }
    }
  }
}
```

### 2. Auth Profiles

Each agent must have `auth-profiles.json` with:
```json
{
  "version": 1,
  "profiles": {
    "minimax:default": {
      "type": "api_key",
      "provider": "minimax",
      "key": "sk-cp-XxgKSU-NF_4Hut66fKFInC-Rn-BNAYt1K5Qy-sfexE0TVOk12ofFDNaHEX11ZWtfEAeBOFzUJEJLZ8G0BHwZXoxqtu8XMSZJ3HL9wFW2D1yJ4t08bcObcQo"
    }
  },
  "lastGood": {
    "minimax": "minimax:default"
  }
}
```

### 3. Models Registry

Each agent must have `models.json` defining the Minimax models (copied from OpenClaw).

---

## Post-Reboot Verification

After a reboot, verify configuration:

### Check OpenClaw
```bash
# Check gateway is using Minimax
docker logs openclaw-gateway 2>&1 | grep "agent model"
# Should show: [gateway] agent model: minimax/MiniMax-M2.5

# Check config
docker exec openclaw-gateway cat /home/node/.openclaw/openclaw.json | jq '.agents.defaults.model.primary'
# Should show: "minimax/MiniMax-M2.5"
```

### Check clawdbot
```bash
# Check gateway is using Minimax
tail -50 ~/.clawdbot/logs/gateway.log | grep "agent model"
# Should show: [gateway] agent model: minimax/MiniMax-M2.5

# Check config
jq '.agents.defaults.model.primary' ~/.clawdbot/clawdbot.json
# Should show: "minimax/MiniMax-M2.5"
```

---

## Backup & Restore

### Create Backup
```bash
cd ~/clawd
./backup-minimax-config.sh
```

This creates timestamped backups in `~/clawd/config-backups/`

### Restore from Backup
```bash
cd ~/clawd
# Restore latest
./restore-minimax-config.sh

# Restore specific timestamp
./restore-minimax-config.sh 20260222-142021
```

---

## Troubleshooting

### Error: "No API key found for provider 'anthropic'"
**Cause:** System reverted to Anthropic as primary model
**Fix:**
1. Check primary model in config files
2. Verify auth-profiles.json has `minimax:default` profile
3. Restart services

### Error: "Unknown model: minimax/MiniMax-M2.5"
**Cause:** Missing models.json file
**Fix:**
```bash
# Extract from OpenClaw
docker exec openclaw-gateway cat /home/node/.openclaw/agents/main/agent/models.json > /tmp/models.json

# Copy to all clawdbot agents
for agent in main research social deploy sales product-owner; do
  cp /tmp/models.json ~/.clawdbot/agents/$agent/agent/models.json
done

# Restart
pkill -f clawdbot
```

### Telegram Agents Not Responding
**Cause:** Multiple instances polling same bot (409 Conflict)
**Fix:** This is expected and will resolve automatically. Only one instance gets messages.

---

## Manual Configuration Steps (if needed)

### 1. Update clawdbot to Minimax
```bash
# Edit main config
jq '.agents.defaults.model.primary = "minimax/MiniMax-M2.5"' ~/.clawdbot/clawdbot.json > /tmp/config.json
mv /tmp/config.json ~/.clawdbot/clawdbot.json

# Update auth for all agents
for agent in main research social deploy sales product-owner; do
  cat > ~/.clawdbot/agents/$agent/agent/auth-profiles.json <<'EOF'
{
  "version": 1,
  "profiles": {
    "minimax:default": {
      "type": "api_key",
      "provider": "minimax",
      "key": "sk-cp-XxgKSU-NF_4Hut66fKFInC-Rn-BNAYt1K5Qy-sfexE0TVOk12ofFDNaHEX11ZWtfEAeBOFzUJEJLZ8G0BHwZXoxqtu8XMSZJ3HL9wFW2D1yJ4t08bcObcQo"
    }
  },
  "lastGood": {
    "minimax": "minimax:default"
  }
}
EOF
done

# Copy models.json
docker exec openclaw-gateway cat /home/node/.openclaw/agents/main/agent/models.json > /tmp/models.json
for agent in main research social deploy sales product-owner; do
  cp /tmp/models.json ~/.clawdbot/agents/$agent/agent/models.json
done

# Restart
pkill -f clawdbot
```

### 2. Update OpenClaw to Minimax
```bash
cd ~/clawd/ASF-15-docker
./scripts/apply-mc-patches.sh

cd ~/clawd/openclaw-mission-control
docker compose build --no-cache backend
docker compose up -d
```

---

## Current Status

✅ **OpenClaw:** Configured with Minimax
✅ **clawdbot:** Configured with Minimax
✅ **All agents:** Have auth-profiles.json with Minimax credentials
✅ **All agents:** Have models.json with Minimax model definitions
✅ **Backups:** Initial backup created at `~/clawd/config-backups/`

**Last Verified:** 2026-02-22 14:20:21
