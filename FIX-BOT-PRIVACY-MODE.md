# 🔧 Fix: Disable Telegram Bot Privacy Mode for All ASF Bots

## Date: February 21, 2026

## Problem
When Jeff sends "SCRUM" in the ASF supergroup, only `@jeffsutherlandbot` (main) and `@AgentSaturdayASFBot` (Raven/product-owner) respond. The other 4 bots (Sales, Research, Social, Deploy) never see the message.

## Root Cause
Telegram bots have **Privacy Mode** enabled by default. With privacy mode ON, bots in groups only receive:
- Messages starting with `/` (commands)
- Messages that @mention the bot
- Replies to the bot's messages
- Service messages (member added/removed, etc.)

The main bot and Raven's bot had privacy mode turned off previously. The other 4 bots still have it ON.

## Fix: Open BotFather in Telegram and do this for EACH bot:

### Bots that need privacy mode disabled:
1. **@ASFResearchBot** (Research Agent)
2. **@ASFSocialBot** (Social Agent)  
3. **@ASFDeployBot** (Deploy Agent)
4. **@ASFSalesBot** (Sales Agent)

### Steps (repeat for each bot above):
1. Open Telegram
2. Go to @BotFather
3. Send: `/mybots`
4. Select the bot (e.g., @ASFResearchBot)
5. Tap **Bot Settings**
6. Tap **Group Privacy**
7. Tap **Turn off**
8. BotFather will confirm: "Privacy mode is disabled for @ASFResearchBot"

### IMPORTANT: After disabling privacy mode
Each bot must be **removed from the group and re-added** for the change to take effect:
1. Remove the bot from the "Agent Security Framework" supergroup
2. Wait 5 seconds
3. Re-add the bot to the group

### Then restart the gateway:
```bash
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

## Verification
After the fix, send "SCRUM" in the supergroup. You should see responses from ALL 6 bots within 30-60 seconds.

Check logs to confirm all agents were triggered:
```bash
docker logs --since 2m openclaw-gateway 2>&1 | grep "lane enqueue.*group:-1003887253177"
```

Expected output should show 6 lanes:
- `session:agent:main:telegram:group:-1003887253177`
- `session:agent:product-owner:telegram:group:-1003887253177`
- `session:agent:research:telegram:group:-1003887253177`
- `session:agent:sales:telegram:group:-1003887253177`
- `session:agent:social:telegram:group:-1003887253177`
- `session:agent:deploy:telegram:group:-1003887253177`

## What Was Already Fixed (by Copilot today):
1. ✅ Removed invalid group IDs from `allowFrom` (only user IDs allowed)
2. ✅ Added `bindings` to route each Telegram account to its agent
3. ✅ Set `requireMention: false` on the supergroup for all accounts
4. ✅ Increased `maxConcurrent` from 4 to 8 (to handle all 6 agents at once)
5. ✅ Deployed communication guide to all agent workspaces
6. ✅ Verified all agents have API keys configured
7. ✅ All bots confirmed as members of the supergroup

## Config Summary (what's in openclaw.json now):
```json
{
  "bindings": [
    {"agentId": "main",          "match": {"channel": "telegram", "accountId": "default"}},
    {"agentId": "research",      "match": {"channel": "telegram", "accountId": "research"}},
    {"agentId": "social",        "match": {"channel": "telegram", "accountId": "social"}},
    {"agentId": "deploy",        "match": {"channel": "telegram", "accountId": "deploy"}},
    {"agentId": "sales",         "match": {"channel": "telegram", "accountId": "sales"}},
    {"agentId": "product-owner", "match": {"channel": "telegram", "accountId": "product-owner"}}
  ],
  "agents": {
    "defaults": {
      "maxConcurrent": 8,
      "subagents": { "maxConcurrent": 12 }
    }
  }
}
```
Each Telegram account has the supergroup configured with `requireMention: false`.

