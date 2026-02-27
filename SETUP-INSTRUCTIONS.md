# ASF Multi-Agent Team Setup Instructions

## Current Status
✅ **5 Specialized ASF Telegram Bots Created:**
- **Product Owner:** Agent Saturday: `8319192848:AAFMgnWa0ozOu0YC0EEcDHkRxAHlhIpEveo`
- **Research Agent:** `8371607764:AAEsQCxbZLi-gcDfcrc4otTg7Tj5wtVTI74`
- **Social Agent:** `8363670185:AAF87g3nBTkhsQ4O1TIEq1lxiRRQ7_G1BQ4` 
- **Deploy Agent:** `8562304149:AAGG8z9voTN0UO8zfI1AjKX5z7K7mQp21ok`
- **Sales Agent:** `8049864989:AAHdP9iDsSpQWiQ5sKFZGJD060WLbmG5aAM`

✅ **SOUL.md Files Created:** 
- `asf-product-owner-agent-saturday-SOUL.md` (Product Owner)
- `asf-research-agent-SOUL.md`
- `asf-social-agent-SOUL.md` 
- `asf-deploy-agent-SOUL.md`
- `asf-sales-agent-SOUL.md`

## Config Update Needed

The automated config update failed validation. You'll need to manually update your Clawdbot config.

### Option 1: Manual Config Edit

1. **Edit:** `~/.clawdbot/clawdbot.json`
2. **Find the telegram section** (currently single-bot format)
3. **Replace it with** the multi-account format shown in `asf-complete-telegram-patch.json`

### Option 2: Use Clawdbot Control UI

1. Go to **http://localhost:18789** (your gateway)
2. Navigate to **Config > Messaging Channels > Telegram**
3. Enable **Multi-Account Mode**
4. Add the 4 new bot accounts

### Option 3: CLI Command

```bash
# Apply the config patch manually
clawdbot gateway config apply --merge asf-complete-telegram-patch.json
```

## After Config Update

1. **Restart Clawdbot:** `clawdbot gateway restart`
2. **Test Bots:** Message each new bot in Telegram to initialize them
3. **Set Agent Personas:** Each bot should adopt its specialized role

## Expected Result

You'll have 6 separate Telegram chats:
- **Main Bot** (existing) - General Clawdbot 
- **@ASFProductOwnerBot** 📋 - Agent Saturday (Product Owner, Sprint Master)
- **@ASFResearchBot** 🔍 - Market intelligence specialist
- **@ASFSocialBot** 🌐 - Community engagement expert
- **@ASFDeployBot** ⚙️ - Infrastructure and DevOps specialist  
- **@ASFSalesBot** 💼 - Enterprise sales and revenue expert

Each will have the appropriate SOUL.md personality and focus on their ASF-20 Enterprise Integration Package responsibilities.