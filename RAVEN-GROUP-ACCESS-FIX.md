# Telegram Group Access - Technical Explanation for Raven

**Date:** February 18, 2026  
**Issue:** Cannot read ASF group messages directly

---

## 🔍 The Problem

You (Raven/@AgentSaturdayASFBot) cannot see messages from the Agent Security Framework Telegram group because of **Telegram Bot Privacy Mode**.

### What You CAN Do:
- ✅ Send messages to the group (using chat ID -4991492317)
- ✅ Receive messages sent directly to you in DMs
- ✅ Receive messages where you are @mentioned in the group
- ✅ Process forwarded messages

### What You CANNOT Do:
- ❌ Read all group message history
- ❌ See messages in real-time that don't @mention you
- ❌ Access Telegram's full chat history

---

## 🔧 The Solution: Disable Bot Privacy Mode

Telegram bots have "Privacy Mode" enabled by default. This means they only receive:
- Commands (messages starting with `/`)
- Messages that @mention the bot
- Replies to the bot's messages

**To receive ALL group messages, the bot admin must disable Privacy Mode.**

### How to Disable Privacy Mode:

1. **Open Telegram** and message **@BotFather**

2. **Send:** `/mybots`

3. **Select:** `@AgentSaturdayASFBot`

4. **Select:** `Bot Settings`

5. **Select:** `Group Privacy`

6. **Select:** `Turn off`

7. **Important:** After disabling privacy mode, **remove and re-add the bot** to the group for the change to take effect.

---

## 📋 Steps for Dr. Sutherland

Please run these steps to enable full group access for Raven:

### Step 1: Disable Privacy Mode in BotFather
```
1. Open Telegram → @BotFather
2. /mybots → @AgentSaturdayASFBot → Bot Settings → Group Privacy → Turn off
```

### Step 2: Re-add Bot to Group
```
1. Go to "Agent Security Framework" group
2. Remove @AgentSaturdayASFBot from the group
3. Add @AgentSaturdayASFBot back to the group
4. Make the bot an admin (optional but recommended)
```

### Step 3: Update OpenClaw Config (if needed)
Add the ASF group to the product-owner account config:

```bash
docker exec openclaw-gateway node /app/openclaw.mjs config set 'channels.telegram.accounts.product-owner.groups.-4991492317.enabled' true
```

### Step 4: Restart Gateway
```bash
cd ~/clawd/ASF-15-docker
docker-compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

---

## 🤔 Alternative: Use Main Bot as Group Monitor

If you prefer to keep Privacy Mode enabled for security, you can:

1. Keep `@jeffsutherlandbot` (main agent) as the group monitor
2. Have main agent forward relevant messages to Raven
3. Use Raven for direct coordination via DM

Example workflow:
```
Group message → @jeffsutherlandbot receives it → forwards to Raven
Raven processes → responds via DM or mentions in group
```

---

## 📊 Current Configuration Status

| Bot | Privacy Mode | Group Access |
|-----|--------------|--------------|
| @jeffsutherlandbot | ? (check BotFather) | Group -4991492317 configured |
| @AgentSaturdayASFBot | Likely ON (default) | Not configured for groups |
| @ASFSalesBot | Likely ON (default) | Not configured for groups |
| @ASFDeployBot | Likely ON (default) | Not configured for groups |
| @ASFSocialBot | Likely ON (default) | Not configured for groups |
| @ASFResearchBot | Likely ON (default) | Not configured for groups |

---

## 🎯 Recommended Action

**For Raven to monitor the ASF group:**

1. Disable privacy mode for @AgentSaturdayASFBot via BotFather
2. Remove and re-add the bot to the group
3. Add group config to product-owner account
4. Restart gateway

This will allow Raven to see all messages in the group, not just mentions.

---

*Document created by Copilot on February 18, 2026*

