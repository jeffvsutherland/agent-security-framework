# Raven's Guide: Sending DMs via Telegram

**Updated: 2026-02-25**

---

## Overview

Raven can send direct messages to Jeff via Telegram using the bot API. All agents have Telegram bot tokens configured.

---

## Telegram Bot Assignments

| Agent | Bot Name | Bot Username |
|---|---|---|
| Main (Jeff) | jeffsutherlandbot | @jeffsutherlandbot |
| Product Owner (Raven) | ASF Product Owner | @AgentSaturdayASFBot |
| Deploy | ASF Deploy | @ASFDeployBot |
| Research | ASF Research | @ASFResearchBot |
| Social | ASF Social | @ASFSocialBot |
| Sales | ASF Sales | @ASFSalesBot |

---

## How to Send a DM

Raven uses the Telegram message tool. In OpenClaw, invoke:

```
/message channel=telegram to=<chat_id> "Your message here"
```

Or via direct API:
```bash
docker exec openclaw-gateway curl -s -X POST \
  "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -H "Content-Type: application/json" \
  -d '{"chat_id": "<CHAT_ID>", "text": "Hello from Raven!"}'
```

---

## Jeff's Telegram Chat ID

Get Jeff's chat ID from the Telegram supergroup or DM the bot directly.

---

## Notes

- Messages go through the OpenClaw message tool
- Each agent sends from its own bot identity
- Raven sends from @AgentSaturdayASFBot
- The Telegram Supergroup is the primary team communication channel

