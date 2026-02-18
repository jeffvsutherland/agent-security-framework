# Inter-Agent Messaging Notes - Feb 18, 2026

## Issue Discovered
Cannot directly message other agents via OpenClaw tools:
- `message` tool requires specific Telegram chat IDs
- `sessions_send` blocked by visibility restrictions
- Error: "Session send visibility is restricted. Set tools.sessions.visibility=all to allow cross-agent access"

## Current Workaround
Need to ask Jeff (or main agent) to relay messages via Telegram directly.

## Configuration Needed
To enable inter-agent messaging, would need:
- `tools.sessions.visibility=all` in config
- Or proper Telegram chat IDs for each agent bot