# Raven's Telegram Agent Team Guide

**Updated: 2026-02-25**

---

## Agent Team Overview

The ASF (Agent Scrum Framework) team runs as a set of specialized AI agents, each with its own Telegram bot and role. They communicate via a Telegram Supergroup.

---

## Agent Roster

| Agent ID | Name | Telegram Bot | Role |
|---|---|---|---|
| `main` | jeffsutherlandbot | @jeffsutherlandbot | Main gateway agent |
| `product-owner` | Raven (Product Owner) | @AgentSaturdayASFBot | Product Owner — backlog, priorities, Morning Report |
| `deploy` | Deploy Agent | @ASFDeployBot | DevOps, Docker, infrastructure |
| `research` | Research Agent | @ASFResearchBot | Market research, competitor analysis |
| `social` | Social Agent | @ASFSocialBot | Social media, Moltbook, community engagement |
| `sales` | Sales Agent | @ASFSalesBot | Customer outreach, pilots, partnerships |

---

## Communication Channels

### Telegram Supergroup
- Primary team communication channel
- All agents can see messages in the group
- Use `SCRUM` command to trigger standup-style updates

### Mission Control (Web UI)
- URL: `http://localhost:3001`
- Board-based project management (Kanban)
- Agents self-assign tasks from the board

### Moltbook
- AI social network at https://www.moltbook.com
- Our account: AgentSaturday
- Used for public-facing community engagement

---

## Agent Configuration

All agents use the same OpenClaw gateway container (`openclaw-gateway`).

### OpenClaw Config
- Config file: `/home/node/.openclaw/openclaw.json`
- Host mirror: `/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/openclaw.json`
- Current default model: `minimax/MiniMax-M2.5`
- All agents use the default model (no per-agent overrides currently)

### Auth Profiles
Each agent has its own auth profile at:
```
/home/node/.openclaw/agents/<agent-id>/agent/auth-profiles.json
```

Host mirror:
```
/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/agents/<agent-id>/agent/auth-profiles.json
```

---

## How to Talk to Other Agents

From Raven's perspective, to delegate work:

1. **Via Telegram Supergroup** — post a message mentioning the task and target agent
2. **Via Mission Control** — assign a task card to the appropriate agent
3. **Via subagent skill** — use the `subagent-driven-development` skill to spawn sub-tasks

---

## Email Accounts

| Account | Email | Has App Password |
|---|---|---|
| Agent Saturday | agent.saturday@scrumai.org | ✅ Yes |
| Jeff Sutherland | jeff.sutherland@scrumai.org | ✅ Yes |
| ASF Deploy | asf.deploy@scrumai.org | ❌ Not yet |
| ASF Research | asf.research@scrumai.org | ❌ Not yet |
| ASF Social | asf.social@scrumai.org | ❌ Not yet |
| ASF Sales | asf.sales@scrumai.org | ❌ Not yet |

---

## Gateway Management

### Check status:
```bash
docker ps | grep openclaw-gateway
```

### View logs:
```bash
docker logs --tail=30 openclaw-gateway
```

### Restart gateway:
```bash
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

