# MiniMax Stability Guide

**How to Prevent MiniMax Configuration Failures**

---

## 🚨 The Problem

MiniMax configuration has failed twice today with error:
```
⚠️ Agent failed before reply: Unknown model: minimax/MiniMax-M2.5
```

**Root Causes:**
1. MiniMax model definitions get removed from `openclaw.json`
2. Auth profiles have wrong provider type (`minimax` instead of `anthropic`)
3. Invalid keys (`provider`, `baseUrl`) added to model config by install scripts
4. Config changes during upgrades or manual edits

---

## ✅ Prevention Tools (Now Installed)

### 1. Health Check Script
**Location:** `~/clawd/ASF-15-docker/scripts/minimax-health-check.sh`

**What it checks:**
- ✓ Primary model set to `minimax/MiniMax-M2.5`
- ✓ MiniMax model definitions exist
- ✓ No invalid keys in model config
- ✓ Auth profiles use `anthropic` provider
- ✓ Docker environment variables correct

**When to run:**
```bash
# Check health anytime
cd ~/clawd/ASF-15-docker
bash scripts/minimax-health-check.sh

# Auto-fix if issues found (it will prompt)
```

### 2. Golden Config Backup/Restore
**Saved:** `/Users/jeffsutherland/clawd/ASF-15-docker/golden-configs/`

**Current working config saved as of:** Feb 23, 2026 10:06 AM

**To restore if broken:**
```bash
cd ~/clawd/ASF-15-docker
bash scripts/restore-golden-config.sh
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

### 3. Pre-Start Validation
**Location:** `~/clawd/ASF-15-docker/scripts/validate-before-start.sh`

**Use before starting OpenClaw:**
```bash
cd ~/clawd/ASF-15-docker

# Validate first
bash scripts/validate-before-start.sh

# Then start if validation passes
docker compose -f docker-compose.yml -f docker-compose.security.yml up -d
```

### 4. Auto-Fix Script
**Location:** `~/clawd/ASF-15-docker/scripts/fix-minimax-auth.sh`

**Fixes all common issues:**
```bash
cd ~/clawd/ASF-15-docker
bash scripts/fix-minimax-auth.sh
```

---

## 📋 Daily Operations Checklist

### Every Morning (or after any restart)
```bash
cd ~/clawd/ASF-15-docker

# 1. Run health check
bash scripts/minimax-health-check.sh

# 2. If issues found, auto-fix
bash scripts/fix-minimax-auth.sh

# 3. Test with Telegram
# Send a message to any agent - should respond without errors
```

### After Any Config Changes
```bash
# 1. Validate changes
bash scripts/minimax-health-check.sh

# 2. Save new golden config if all is working
bash scripts/save-golden-config.sh
```

### If Agents Stop Responding
```bash
# Quick recovery (2 minutes):
cd ~/clawd/ASF-15-docker
bash scripts/restore-golden-config.sh
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
clawdbot gateway restart
```

---

## 🔧 Understanding the MiniMax Setup

### Why It's Complex

MiniMax uses an **Anthropic-compatible API** but OpenClaw doesn't natively support custom provider URLs. We use a workaround:

1. **Environment Variable:** `ANTHROPIC_BASE_URL=https://api.minimax.io/anthropic`
   - Tells OpenClaw SDK to point Anthropic requests to MiniMax

2. **Auth Profiles:** Must use `"provider": "anthropic"` (not `"minimax"`)
   - Even though it's MiniMax, the SDK needs to think it's Anthropic

3. **Model Config:** Must NOT have `provider` or `baseUrl` keys
   - Those keys are invalid in OpenClaw 2026.2.19
   - Configuration happens via environment variable instead

### Correct Configuration

**openclaw.json models section:**
```json
"models": {
  "minimax/MiniMax-M2.5": {
    "params": {
      "max_tokens": 8192
    }
  }
}
```
✅ Simple, no provider/baseUrl keys

**Auth profile:**
```json
{
  "profiles": {
    "minimax:default": {
      "type": "api_key",
      "provider": "anthropic",     ← Must be "anthropic"
      "key": "sk-cp-..."
    }
  }
}
```

**docker-compose.yml:**
```yaml
environment:
  - ANTHROPIC_API_KEY=sk-cp-...
  - ANTHROPIC_BASE_URL=https://api.minimax.io/anthropic
```

---

## 🛡️ What Breaks MiniMax

### ❌ Common Mistakes

1. **Installing MiniMax via scripts that add invalid keys**
   ```json
   // WRONG - causes "Config invalid" error
   "minimax/MiniMax-M2.5": {
     "provider": "anthropic",        ← Invalid key
     "baseUrl": "https://...",       ← Invalid key
     "params": { "max_tokens": 8192 }
   }
   ```

2. **Auth profiles with wrong provider**
   ```json
   // WRONG - causes "Unknown model" error
   "minimax:default": {
     "provider": "minimax"   ← Should be "anthropic"
   }
   ```

3. **Missing model definitions**
   - Primary set to `minimax/MiniMax-M2.5` but model not defined in `models` section

4. **OpenClaw upgrades**
   - New versions may not support custom providers
   - Always validate after upgrading

---

## 🔄 Recovery Procedures

### Scenario 1: "Unknown model" Error
```bash
# Quick fix
cd ~/clawd/ASF-15-docker
bash scripts/fix-minimax-auth.sh
```

### Scenario 2: "Config invalid" Error
```bash
# Restore golden config
cd ~/clawd/ASF-15-docker
bash scripts/restore-golden-config.sh
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

### Scenario 3: Total Failure
```bash
# Nuclear option - restore everything
cd ~/clawd/ASF-15-docker

# 1. Restore config
bash scripts/restore-golden-config.sh

# 2. Restart all services
docker compose -f docker-compose.yml -f docker-compose.security.yml down
docker compose -f docker-compose.yml -f docker-compose.security.yml up -d

# 3. Restart clawdbot
clawdbot gateway restart

# 4. Wait 10 seconds
sleep 10

# 5. Verify
bash scripts/minimax-health-check.sh
```

---

## 📊 Monitoring

### Check Logs for MiniMax Errors
```bash
# OpenClaw logs
docker compose logs openclaw --tail 50 | grep -i "minimax\|unknown model"

# Clawdbot logs
clawdbot logs --follow | grep -i "minimax\|unknown model"
```

### Verify Model is Working
```bash
# Check model status
clawdbot models list | grep minimax

# Expected: Should NOT show "missing"
# If shows "missing", run fix-minimax-auth.sh
```

---

## 🔐 Files to Never Edit Manually

**High Risk (always use scripts):**
- `openclaw-state/openclaw.json` - Use scripts or backups
- `openclaw-state/agents/*/agent/auth-profiles.json` - Use fix-minimax-auth.sh

**Safe to Edit:**
- `docker-compose.yml` - But validate after changes
- Scripts in `scripts/` directory

---

## 💾 Backup Strategy

### Automatic Backups
- Health check creates backup before any changes
- Located: `openclaw-state/backups/openclaw.json.TIMESTAMP`

### Golden Config
- Last known working config
- Updated when everything is verified working
- Use `save-golden-config.sh` after confirming stability

### Manual Backup
```bash
cp ~/clawd/ASF-15-docker/openclaw-state/openclaw.json \
   ~/clawd/ASF-15-docker/openclaw-state/openclaw.json.manual.$(date +%Y%m%d)
```

---

## 🚀 Best Practices

1. **Always validate before starting:**
   ```bash
   bash scripts/validate-before-start.sh
   ```

2. **Save golden config when stable:**
   ```bash
   bash scripts/save-golden-config.sh
   ```

3. **Run health check after any change:**
   ```bash
   bash scripts/minimax-health-check.sh
   ```

4. **Never edit configs during operation:**
   - Stop OpenClaw first
   - Make changes
   - Validate
   - Then start

5. **Test after every restart:**
   - Send test message to agent via Telegram
   - Check for "Unknown model" error
   - If error, run fix script immediately

---

## 📞 Quick Reference

```bash
# Check health
bash ~/clawd/ASF-15-docker/scripts/minimax-health-check.sh

# Fix issues
bash ~/clawd/ASF-15-docker/scripts/fix-minimax-auth.sh

# Restore working config
bash ~/clawd/ASF-15-docker/scripts/restore-golden-config.sh

# Save current as golden
bash ~/clawd/ASF-15-docker/scripts/save-golden-config.sh

# Full restart
cd ~/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
clawdbot gateway restart
```

---

## 📝 Change Log

**2026-02-23:**
- Created stability framework
- Added health check, validation, and auto-fix scripts
- Saved first golden config
- Documented root causes and prevention

---

**Last Updated:** February 23, 2026
**Status:** ✅ MiniMax Stable with Automated Protection
