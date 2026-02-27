# Raven (ASF Product Owner) - Operations Guide

**Last Updated:** February 27, 2026  
**Container:** `openclaw-gateway`  
**Image:** `openclaw-extended:2026.2.19`  
**Runs as:** `node` user (uid=1000, gid=1000)

---

## ⚠️ Terminal Protocol (for Copilot/AI Assistants)

When debugging Raven's tools, Copilot **cannot reliably see terminal output**. Always:
```bash
[command] > copilot_out.txt 2>&1
```
Then have Copilot read `copilot_out.txt`. See `.github/copilot-instructions.md` for full protocol.

---

## Quick Status Check

```bash
# Is the container running?
docker ps | grep openclaw-gateway

# Is Mission Control reachable?
docker exec openclaw-gateway /workspace/.mc-api-backup health

# Is Raven online in MC?
docker exec openclaw-gateway /workspace/.mc-api-backup agents | python3 -c "
import sys, json
data = json.load(sys.stdin)
for a in data['items']:
    if 'Raven' in a['name']:
        print(f\"Raven: {a['status']} (last seen: {a['last_seen_at']})\")"

# Generate morning report (from host)
docker exec openclaw-gateway python3 /workspace/generate-morning-report-raven.py

# Generate morning report (Raven runs this inside container)
# python3 /workspace/generate-morning-report-raven.py
```

---

## Morning Report

### What It Contains
1. **🤖 ASF Agent Status** — All agents, their assigned stories, Telegram bots
2. **📊 Market Update** — BTC, TSLA, MSTR, Silver prices
3. **🎯 Sprint Status** — Current sprint progress, velocity, priorities
4. **📅 Today's Schedule** — Google Calendar events
5. **📧 Email Status** — Urgent email scan
6. **⚠️ Key Alerts** — Critical issues, sprint blockers

### How to Generate

**From Mac host (recommended):**
```bash
~/clawd/generate-morning-report.sh              # Generate & save to ~/clawd/morning-reports/
~/clawd/generate-morning-report.sh --telegram   # Also send via Telegram
```

**Output:** `~/clawd/morning-reports/YYYYMMDD-MORNING-REPORT.md`

**From inside container (as Raven runs it):**
```bash
python3 /workspace/generate-morning-report-raven.py
```

⚠️ **Raven CANNOT run bash scripts** — the OpenClaw agent runtime does not support
direct bash script execution. She must use `generate-morning-report-raven.py` (Python).
She also cannot run `generate-morning-report.sh` which uses `docker exec` (not available
inside the container).

**From host via docker exec:**
```bash
docker exec openclaw-gateway python3 /workspace/generate-morning-report-raven.py
```

**Dependencies (all inside container):**
| Script | Purpose | Status |
|--------|---------|--------|
| `/workspace/generate-morning-report-raven.py` | **Raven's runner (use this inside container)** | ✅ Working |
| `/workspace/morning-report-template.py` | Main report generator | ✅ Working |
| `/workspace/get-prices.py` | Market data | ✅ Working |
| `/workspace/get-calendar-google.py` | Calendar events | ✅ Working |
| `/workspace/check-agent-status.py` | Agent status check | ✅ Working |
| `/workspace/get-email-ff.py` | Email scan | ✅ Working |
| `/workspace/memory/heartbeat-state.json` | Sprint state | ✅ Present |

### Troubleshooting Morning Report

**If "tools not working" inside OpenClaw agent runtime:**

The issue is likely the PTY allocation. The docker-compose.yml must have:
```yaml
openclaw:
  tty: true
  stdin_open: true
```

**Fix:**
```bash
cd ~/clawd/ASF-15-docker
docker stop openclaw-gateway && docker rm openclaw-gateway
docker compose up -d openclaw
```

**If Python scripts fail inside container:**
```bash
# Check Python and pytz
docker exec openclaw-gateway python3 --version
docker exec openclaw-gateway python3 -c "import pytz; print(pytz.__version__)"

# Test individual components
docker exec openclaw-gateway python3 /workspace/get-prices.py
docker exec openclaw-gateway python3 /workspace/get-calendar-google.py
docker exec openclaw-gateway python3 /workspace/check-agent-status.py
```

---

## Raven's Tools

### mc-api (Mission Control API)

**Location:** `/workspace/.mc-api-backup` (also at `/usr/local/bin/mc-api`)  
**Owned by:** `node:node` with `-rwxr-xr-x` — no permission issues

**Commands:**
```bash
# Health check
/workspace/.mc-api-backup health

# List boards
/workspace/.mc-api-backup boards

# List tasks/cards
/workspace/.mc-api-backup tasks

# Create a task
/workspace/.mc-api-backup create-task "" '{"title":"New Task","description":"Details","priority":"high"}'

# Update a task
/workspace/.mc-api-backup update-task <task-id> '{"status":"in_progress"}'

# List agents
/workspace/.mc-api-backup agents

# Send heartbeat
/workspace/.mc-api-backup heartbeat '{"status":"online"}'

# Get activity feed
/workspace/.mc-api-backup activity
```

### Agent Communication

| Agent | Telegram Bot | MC ID | Role |
|-------|-------------|-------|------|
| Raven (PO) | @AgentSaturdayASFBot | 3634c19a... | Product Owner |
| Deploy Agent | @ASFDeployBot | 30374dc0... | DevOps/Deploy |
| Research Agent | @ASFResearchBot | a752e9fc... | Research |
| Social Agent | @ASFSocialBot | b9efac34... | Social Media |
| Sales Agent | @ASFSalesBot | f231fd0f... | Sales |
| Main Agent | @jeffsutherlandbot | ae63a2bf... | Gateway |

### Board Info

- **Board:** Agent Security Framework
- **Board ID:** `24394a90-a74e-479c-95e8-e5d24c7b4a40`
- **Board Type:** goal
- **Org ID:** `d4605e8f-bddc-44ad-9472-537884b1a3b9`

---

## Container Environment

### Verified Working
- ✅ `ANTHROPIC_API_KEY` set (via minimax proxy)
- ✅ `ANTHROPIC_BASE_URL`: `https://api.minimax.io/anthropic`
- ✅ Python 3.11.2 with pytz 2025.2
- ✅ mc-api connects to `http://host.docker.internal:8001`
- ✅ `/workspace` volume mounted from `~/clawd`
- ✅ TTY allocated (`tty: true` in docker-compose.yml)
- ✅ Stdin open (`stdin_open: true` in docker-compose.yml)

### Key Paths Inside Container
```
/workspace/                          → ~/clawd (host)
/workspace/.mc-api-backup            → mc-api script
/workspace/morning-report-template.py → Morning report
/workspace/memory/                   → Agent memory files
/workspace/agents/                   → Per-agent workspaces
/home/node/.openclaw/                → OpenClaw state
/home/node/.clawdbot-host/           → Clawdbot config (read-only)
```

---

## Common Issues & Fixes

### Issue: "Tools not working" / Commands hang silently
**Cause:** PTY not allocated in Docker  
**Fix:** Ensure `tty: true` and `stdin_open: true` in docker-compose.yml, then recreate container.

### Issue: mc-api returns errors
**Cause:** Mission Control backend not running  
**Fix:**
```bash
docker ps | grep mission-control
cd ~/clawd/ASF-15-docker && docker compose up -d
```

### Issue: Morning report shows stale data
**Cause:** heartbeat-state.json not being updated  
**Fix:** Check cron jobs or manually trigger agent status check:
```bash
docker exec openclaw-gateway python3 /workspace/check-agent-status.py
```

### Issue: Container not starting
**Cause:** Name conflict from old container  
**Fix:**
```bash
docker stop openclaw-gateway 2>/dev/null
docker rm openclaw-gateway 2>/dev/null
cd ~/clawd/ASF-15-docker && docker compose up -d openclaw
```

### Issue: Raven shows "offline" in Mission Control
**Cause:** No heartbeat being sent  
**Fix:**
```bash
docker exec openclaw-gateway /workspace/.mc-api-backup heartbeat '{"status":"online","message":"Raven reporting in"}'
```

---

## File Locations on Host

| Purpose | Host Path |
|---------|-----------|
| Docker Compose | `~/clawd/ASF-15-docker/docker-compose.yml` |
| Morning Report Runner | `~/clawd/generate-morning-report.sh` |
| Morning Reports Dir | `~/clawd/morning-reports/YYYYMMDD-MORNING-REPORT.md` |
| This Documentation | `~/clawd/RAVEN-OPERATIONS-GUIDE.md` |
| Copilot Instructions | `F100 Run files/.github/copilot-instructions.md` |
| Troubleshooting | `F100 Run files/CLAWDBOT_TROUBLESHOOTING.md` |
| OpenClaw State | `~/clawd/ASF-15-docker/openclaw-state/` |
| Workspace | `~/clawd/` |

---

*Document created February 27, 2026 — Agent Security Framework*

