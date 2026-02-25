# OpenClaw ASF Platform — Complete Operations Guide

**Updated: 2026-02-25**
**Author: GitHub Copilot (for Jeff Sutherland / Agent Saturday team)**

---

## Table of Contents

1. [System Architecture](#1-system-architecture)
2. [Docker Infrastructure](#2-docker-infrastructure)
3. [OpenClaw Gateway Configuration](#3-openclaw-gateway-configuration)
4. [Model Configuration & History](#4-model-configuration--history)
5. [Agent Roster & IDs](#5-agent-roster--ids)
6. [Auth Profiles](#6-auth-profiles)
7. [Skills Inventory](#7-skills-inventory)
8. [Email Configuration](#8-email-configuration)
9. [Google Calendar Access](#9-google-calendar-access)
10. [Moltbook Integration](#10-moltbook-integration)
11. [Browser Automation](#11-browser-automation)
12. [Configuration Scripts](#12-configuration-scripts)
13. [Raven Guides Index](#13-raven-guides-index)
14. [Known Issues & Lessons Learned](#14-known-issues--lessons-learned)
15. [Troubleshooting Runbook](#15-troubleshooting-runbook)

---

## 1. System Architecture

The ASF platform runs on a Mac Studio (4196) with Docker Desktop. The core is an **OpenClaw gateway** container that hosts multiple AI agents, each accessible via Telegram bots. A separate **Mission Control** stack provides a Kanban-style web UI for project management.

```
┌──────────────────────────────────────────────────┐
│ Mac Studio (macOS) — Host                         │
│                                                    │
│  ┌─── OpenClaw Gateway ──────────────────────┐   │
│  │  Image: openclaw-extended:2026.2.19        │   │
│  │  Port: 18789                               │   │
│  │  Agents: main, product-owner, deploy,      │   │
│  │          research, social, sales + MC agents│   │
│  │  Skills: 13/57 ready                       │   │
│  │  Model: minimax/MiniMax-M2.5 (via MiniMax) │   │
│  │  State: /home/node/.openclaw/              │   │
│  │  Workspace: /workspace/                    │   │
│  └────────────────────────────────────────────┘   │
│                                                    │
│  ┌─── Mission Control ──────────────────────┐     │
│  │  Frontend: port 3001                      │     │
│  │  Backend:  port 8001                      │     │
│  │  Webhook Worker                           │     │
│  │  PostgreSQL 16: port 5433                 │     │
│  │  Redis 7: port 6380                       │     │
│  └───────────────────────────────────────────┘    │
│                                                    │
│  ┌─── ASF Dashboard / API ──────────────────┐    │
│  │  Dashboard: port 3000                     │    │
│  │  API: port 8080                           │    │
│  │  Webhook: port 8081                       │    │
│  │  PostgreSQL 15: port 5432                 │    │
│  │  Redis 7: port 6379                       │    │
│  └───────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```

### Host Paths

| Purpose | Path |
|---|---|
| Workspace root | `/Users/jeffsutherland/clawd` |
| Docker configs | `/Users/jeffsutherland/clawd/ASF-15-docker` |
| OpenClaw state (host mirror) | `/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/` |
| Config JSON | `openclaw-state/openclaw.json` |
| Agent auth profiles | `openclaw-state/agents/<id>/agent/auth-profiles.json` |
| Himalaya email config | `~/.config/himalaya/config.toml` |

### Container Paths

| Purpose | Path |
|---|---|
| OpenClaw state | `/home/node/.openclaw/` |
| Config JSON | `/home/node/.openclaw/openclaw.json` |
| Workspace | `/workspace/` |
| Agent skills | `/workspace/skills/` |
| Google Calendar token | `/home/node/.config/google/calendar_token.json` |
| Himalaya config | `/home/node/.config/himalaya/config.toml` |
| Moltbook creds | `/home/node/.openclaw/config/moltbook/credentials.json` |

---

## 2. Docker Infrastructure

### Container Inventory

| Container | Image | Port | Purpose |
|---|---|---|---|
| `openclaw-gateway` | openclaw-extended:2026.2.19 | 18789 | AI agent gateway |
| `openclaw-mission-control-frontend-1` | openclaw-mission-control-frontend | 3001 | MC Web UI |
| `openclaw-mission-control-backend-1` | openclaw-mission-control-backend | 8001 | MC API |
| `openclaw-mission-control-webhook-worker-1` | openclaw-mission-control-webhook-worker | (internal) | MC background jobs |
| `openclaw-mission-control-db-1` | postgres:16-alpine | 5433 | MC database |
| `openclaw-mission-control-redis-1` | redis:7-alpine | 6380 | MC cache |
| `asf-dashboard` | asf-15-docker-asf-dashboard | 3000 | ASF dashboard |
| `asf-api-service` | asf-15-docker-asf-api | 8080 | ASF API |
| `asf-webhook-service` | asf-15-docker-webhook-service | 8081 | ASF webhooks |
| `asf-postgres` | postgres:15-alpine | 5432 | ASF database |
| `asf-redis` | redis:7-alpine | 6379 | ASF cache |

### Common Commands

```bash
# Check all containers
docker ps -a

# Restart gateway only
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw

# View gateway logs
docker logs --tail=50 openclaw-gateway

# Execute command inside gateway
docker exec openclaw-gateway <command>

# Copy file to container
docker cp <local-path> openclaw-gateway:<container-path>

# Copy file from container
docker cp openclaw-gateway:<container-path> <local-path>
```

---

## 3. OpenClaw Gateway Configuration

### Config Location
- **Host**: `/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/openclaw.json`
- **Container**: `/home/node/.openclaw/openclaw.json`

### Key Config Sections

```json
{
  "gateway": {
    "bind": "loopback"
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "minimax/MiniMax-M2.5"
      },
      "models": {
        "anthropic/claude-opus-4-20250514": {"params": {"max_tokens": 8192}},
        "anthropic/claude-sonnet-4-20250514": {"params": {"max_tokens": 8192}},
        "minimax/MiniMax-M2.5": {"params": {"max_tokens": 8192}},
        "minimax/MiniMax-M2.5-highspeed": {"params": {"max_tokens": 8192}}
      }
    },
    "list": [
      {"id": "main", ...},
      {"id": "product-owner", ...},
      ...
    ]
  },
  "env": {
    "MINIMAX_API_KEY": "<key>"
  }
}
```

### ⚠️ Config Rules (Learned the Hard Way)

1. **NEVER add a `providers` key** under `agents.defaults` — it causes gateway crash loops
2. **Model configs go in `agents.defaults.models`** with `params` sub-key only
3. **Per-agent model overrides** go in the agent's entry in `agents.list[].model`
4. **API keys** go in both `env` section AND agent `auth-profiles.json`
5. **After editing config**, always copy to container AND restart gateway
6. **The gateway startup log** shows only the default model, not per-agent overrides

---

## 4. Model Configuration & History

### Current Configuration (2026-02-25)
- **Default (all agents)**: `minimax/MiniMax-M2.5`
- **API Key**: MiniMax Coding Plan key (`<MINIMAX_API_KEY>...`)
- **Auth method**: MiniMax uses Anthropic-compatible API format

### Model History

| Date | Primary | Notes |
|---|---|---|
| Feb 20-21 | anthropic/claude-sonnet-4 | Initial setup |
| Feb 22 | minimax/MiniMax-M2.5 | Switched to MiniMax (cost savings) |
| Feb 22 | ← MiniMax had balance issues | Old API key had insufficient balance |
| Feb 22 | anthropic/claude-sonnet-4 | Temporarily rolled back |
| Feb 22 | minimax/MiniMax-M2.5 | Fixed with Coding Plan key |
| Feb 24 | google/gemini-3.1-pro-preview | Attempted for Raven only |
| Feb 24 | ← FAILED: "Unknown model" | OpenClaw doesn't recognize gemini-3.1 yet |
| Feb 24 | google/gemini-3-pro-preview | Attempted fallback |
| Feb 24 | ← FAILED: rate limited | Free tier 5 RPM + massive context windows |
| Feb 24 | minimax/MiniMax-M2.5 | Rolled back to MiniMax for all agents |

### Gemini Setup — What Went Wrong (Feb 24, 2026)

**Problem**: OpenClaw v2026.2.19 has `gemini-3-pro-preview` and `gemini-3-flash-preview` in its internal model catalog, but NOT `gemini-3.1-pro-preview`. Even when we switched to `gemini-3-pro-preview` which IS in the catalog, Google's free tier rate limits (5 RPM, 250K TPM) were instantly exhausted by OpenClaw's tool/context stuffing.

**Gemini API Key**: `<GEMINI_API_KEY>` (verified working with `generativelanguage.googleapis.com`)

---

### 🔮 Future Gemini 3.1 Installation Guide (After Upgrade + Billing Fix)

Use this step-by-step procedure when ready to try Gemini again.

#### Prerequisites — Complete ALL Before Starting

- [ ] **1. Upgrade OpenClaw** to a version that includes `gemini-3.1-pro-preview` in its model catalog
  ```bash
  # Check current version
  docker exec openclaw-gateway cat /app/package.json | grep version
  # Check if new version knows gemini-3.1
  docker exec openclaw-gateway grep -r "gemini-3.1" /app/dist/config-*.js
  ```
  If the new OpenClaw version still doesn't include `gemini-3.1-pro-preview`, you MUST use the **Model Catalog Bypass** (see Step 2b below).

- [ ] **2. Fix Google Billing** — Attach a billing account in [Google AI Studio](https://aistudio.google.com/)
  - Free tier is **5 RPM / 250K TPM** — this is NOT enough for OpenClaw (which stuffs all tool schemas into each request)
  - Pay-as-you-go removes the RPM cap
  - Test billing is active:
    ```bash
    curl -s -m 15 "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-pro-preview:generateContent?key=<GEMINI_API_KEY>" \
      -H "Content-Type: application/json" \
      -d '{"contents":[{"parts":[{"text":"Say hello"}]}]}' | python3 -c "import sys,json; d=json.load(sys.stdin); print('OK' if 'candidates' in d else 'ERROR:', d)"
    ```

- [ ] **3. Verify API key still works** (key may expire if account was suspended)
  ```bash
  curl -s "https://generativelanguage.googleapis.com/v1beta/models?key=<GEMINI_API_KEY>" | python3 -c "
  import sys,json; d=json.load(sys.stdin); [print(m['name']) for m in d.get('models',[]) if 'gemini-3' in m['name']]"
  ```

#### Step 1: Run the Setup Script (Raven Only)

This configures ONLY Raven (Product Owner) to use Gemini. All other agents stay on MiniMax.

```bash
python3 /Users/jeffsutherland/clawd/setup-raven-gemini.py
```

**What the script does:**
1. Adds `google/gemini-3.1-pro-preview` and `google/gemini-3-flash-preview` to `agents.defaults.models`
2. Sets `GEMINI_API_KEY` in the `env` section
3. Sets both Raven agent entries (`product-owner` + `mc-3634c19a-...`) to `primary: google/gemini-3.1-pro-preview` with `fallbacks: [google/gemini-3-flash-preview]`
4. Creates `google:default` auth profiles for both Raven agents (keeps `minimax:default` as backup)

#### Step 2a: If OpenClaw Recognizes the Model — Deploy

```bash
# Copy config + auth profiles to container
docker cp /Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/openclaw.json openclaw-gateway:/home/node/.openclaw/openclaw.json
docker cp /Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/agents/product-owner/agent/auth-profiles.json openclaw-gateway:/home/node/.openclaw/agents/product-owner/agent/auth-profiles.json
docker cp /Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/agents/mc-3634c19a-9174-4f23-b03a-0d451f5de6be/agent/auth-profiles.json openclaw-gateway:/home/node/.openclaw/agents/mc-3634c19a-9174-4f23-b03a-0d451f5de6be/agent/auth-profiles.json

# Restart gateway
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw

# Verify (wait 20 seconds for startup)
sleep 20 && docker logs --tail=30 openclaw-gateway 2>&1 | grep -iE "error|model|gemini|google"
```

#### Step 2b: Model Catalog Bypass (If OpenClaw Still Says "Unknown model")

If the logs show `Unknown model: google/gemini-3.1-pro-preview`, add a provider-level model definition to `openclaw.json`. This forces OpenClaw to accept the model even if it's not in the built-in catalog.

Add this section to the **top level** of `openclaw.json` (NOT under `agents`):

```json
{
  "models": {
    "providers": {
      "google": {
        "models": {
          "gemini-3.1-pro-preview": {
            "contextWindow": 1048576,
            "maxTokens": 65536
          }
        }
      }
    }
  }
}
```

**⚠️ WARNING**: This is at the TOP LEVEL `models` key, NOT inside `agents.defaults.models`. The `agents.defaults.models` key configures params; this top-level `models.providers` key registers new model IDs with the catalog.

After adding, re-copy config and restart.

#### Step 3: Verify Raven Is Using Gemini

```bash
# Check logs for model errors
docker logs --tail=50 openclaw-gateway 2>&1 | grep -iE "gemini|google|error|model"

# Verify config in container
docker exec openclaw-gateway python3 -c "
import json
with open('/home/node/.openclaw/openclaw.json') as f:
    d = json.load(f)
print('Default:', d['agents']['defaults']['model']['primary'])
for a in d['agents']['list']:
    if 'product-owner' in a.get('id','') or 'Raven' in a.get('name',''):
        m = a.get('model', {})
        print(f'{a[\"id\"]}: primary={m.get(\"primary\",\"DEFAULT\")}, fallbacks={m.get(\"fallbacks\",\"NONE\")}')
for aid in ['product-owner', 'mc-3634c19a-9174-4f23-b03a-0d451f5de6be']:
    with open(f'/home/node/.openclaw/agents/{aid}/agent/auth-profiles.json') as f:
        auth = json.load(f)
    print(f'{aid} auth: {list(auth[\"profiles\"].keys())}')
"
```

**Expected output:**
```
Default: minimax/MiniMax-M2.5
product-owner: primary=google/gemini-3.1-pro-preview, fallbacks=['google/gemini-3-flash-preview']
mc-3634c19a-...: primary=google/gemini-3.1-pro-preview, fallbacks=['google/gemini-3-flash-preview']
product-owner auth: ['google:default', 'minimax:default']
mc-3634c19a-... auth: ['google:default', 'minimax:default']
```

Then send a test message to Raven via Telegram and check she responds.

#### Step 4: If It Fails — Instant Rollback

```bash
python3 /Users/jeffsutherland/clawd/rollback-raven-to-minimax.py
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

**What the rollback script does:**
1. Removes all `google/*` model configs from `agents.defaults.models`
2. Removes `GEMINI_API_KEY` from `env`
3. Deletes `model` override from both Raven agent entries (reverts to default MiniMax)
4. Restores auth profiles to minimax-only
5. Copies everything to container automatically

#### Reducing Rate Limit Risk (Even With Billing)

If Gemini still hits rate limits even after billing is enabled:
- **Reduce active skills** for Raven — each skill adds its JSON schema to every request
- **Use `gemini-3-flash-preview` as primary** (lower latency, higher rate limits than Pro)
- **Set `max_tokens` lower** (e.g., 4096 instead of 8192)
- **Consider using per-agent skill scoping** to limit which skills Raven loads

---

## 5. Agent Roster & IDs

| Index | Agent ID | Name | Telegram Bot | MC Agent |
|---|---|---|---|---|
| 0 | `main` | (default) | @jeffsutherlandbot | Main Agent (jeffsutherlandbot) |
| 1 | `research` | research | @ASFResearchBot | Research Agent |
| 2 | `social` | social | @ASFSocialBot | Social Agent |
| 3 | `deploy` | deploy | @ASFDeployBot | Deploy Agent |
| 4 | `sales` | sales | @ASFSalesBot | Sales Agent |
| 5 | `product-owner` | product-owner | @AgentSaturdayASFBot | — |
| 7 | `mc-3634c19a-...` | Raven (Product Owner) | — | Raven (Product Owner) |
| 6 | `mc-gateway-c3ff9d87-...` | Main Agent (jeffsutherlandbot) | — | MC gateway |
| 8-12 | `mc-*` | Sales/Research/Social/Deploy | — | MC agent mirrors |

**Note**: Raven has TWO agent entries — `product-owner` (Telegram) and `mc-3634c19a-...` (Mission Control). Both need the same config/auth when making changes.

---

## 6. Auth Profiles

Auth profiles live at:
```
/home/node/.openclaw/agents/<agent-id>/agent/auth-profiles.json
```

### Current format (MiniMax):
```json
{
  "version": 1,
  "profiles": {
    "minimax:default": {
      "type": "api_key",
      "provider": "anthropic",
      "key": "<MINIMAX_API_KEY>..."
    }
  },
  "lastGood": {
    "minimax": "minimax:default"
  }
}
```

### For Google/Gemini (future):
```json
{
  "version": 1,
  "profiles": {
    "google:default": {
      "type": "api_key",
      "provider": "google",
      "key": "<GEMINI_API_KEY>"
    },
    "minimax:default": {
      "type": "api_key",
      "provider": "anthropic",
      "key": "<MINIMAX_API_KEY>"
    }
  }
}
```

---

## 7. Skills Inventory

As of 2026-02-24, 13/57 skills are ready:

| Status | Skill | Source | Description |
|---|---|---|---|
| ✅ | find-skills | workspace | Discover/install skills |
| ✅ | healthcheck | bundled | Security audits |
| ✅ | himalaya | bundled | Email via IMAP/SMTP |
| ✅ | mcporter | workspace | MCP server management |
| ✅ | skill-creator | bundled | Create/update skills |
| ✅ | slack | bundled | Slack integration |
| ✅ | subagent-driven-development | workspace | Spawn sub-tasks |
| ✅ | using-superpowers | workspace | Skill discovery on startup |
| ✅ | weather | bundled | Weather forecasts |
| ✅ | Agent Browser | workspace | Web automation (v0.14.0) |
| ✅ | moltbook | workspace | Moltbook social network |
| ✅ | openai-image-gen-secure | workspace | Image generation |
| ✅ | oracle-secure | workspace | Secure oracle queries |

### Not installed but available:
- `apple-notes` — requires `memo` CLI on macOS (installed on host)
- `apple-reminders` — requires `remindctl` CLI (needs Xcode CLT update)
- `browser-use` — ClawHub rate-limited during install
- `discord`, `github`, `notion`, `obsidian`, `trello` — not configured

---

## 8. Email Configuration

### Himalaya Email Accounts

Config: `/home/node/.config/himalaya/config.toml`

| Account ID | Email | App Password | Status |
|---|---|---|---|
| `ff` (default) | drjeffsutherland@frequencyfoundation.com | ✅ configured | ✅ Working |
| `scrum` | jeff.sutherland@scruminc.com | ✅ configured | ✅ Working |
| `gmail` | jeff.sutherland@gmail.com | ✅ configured | ✅ Working |
| `drjeff` | drjeffsutherland@gmail.com | ✅ configured | ✅ Working |
| `saturday` | agent.saturday@scrumai.org | ✅ configured | ✅ Working |
| `scrumai` | jeff.sutherland@scrumai.org | ✅ configured | ✅ Working |

### Email Check Scripts

```bash
# Check all accounts
docker exec openclaw-gateway python3 /workspace/check-email.py

# Check specific account
docker exec openclaw-gateway python3 /workspace/check-email.py ff

# Check with custom count
docker exec openclaw-gateway python3 /workspace/check-email.py saturday --count 10
```

### Accounts WITHOUT App Passwords Yet
- asf.deploy@scrumai.org
- asf.research@scrumai.org
- asf.social@scrumai.org
- asf.sales@scrumai.org

---

## 9. Google Calendar Access

### Status: ✅ WORKING

| Item | Value |
|---|---|
| Token (container) | `/home/node/.config/google/calendar_token.json` |
| Token (host) | `openclaw-state/config/google/calendar_token.json` |
| Scope | `calendar.readonly` |
| Primary calendar | jeff.sutherland@gmail.com |
| Scrum Inc calendar | jeff.sutherland@scruminc.com |

### Scripts

```bash
# Today's schedule (for Morning Report)
docker exec openclaw-gateway python3 /workspace/today-schedule.py

# Weekly overview
docker exec openclaw-gateway python3 /workspace/check-calendar.py
```

See [RAVEN-CALENDAR-GUIDE.md](RAVEN-CALENDAR-GUIDE.md) for full details.

---

## 10. Moltbook Integration

### Status: ✅ WORKING

| Item | Value |
|---|---|
| API Key | `<MOLTBOOK_API_KEY>` |
| Agent Name | AgentSaturday |
| API URL | `https://www.moltbook.com/api/v1/` |
| Karma | 55 |
| Followers | 7 |

### Scripts

```bash
# Test connectivity
docker exec openclaw-gateway python3 /workspace/test-moltbook.py

# Read feed
docker exec openclaw-gateway python3 /workspace/moltbook-post.py read new 5

# Post
docker exec openclaw-gateway python3 /workspace/moltbook-post.py "Title" "Content" general
```

See [RAVEN-MOLTBOOK-PASSWORD-RESET.md](RAVEN-MOLTBOOK-PASSWORD-RESET.md) for access recovery.

---

## 11. Browser Automation

### Status: ✅ WORKING (Agent Browser v0.14.0 — Fixed Feb 25)

### Critical Docker Requirements

The browser **will not work** without these three Docker settings in `docker-compose.yml` and `docker-compose.security.yml`:

| Setting | Value | Why |
|---|---|---|
| `shm_size` | `512mb` | Chromium needs >64MB shared memory. Default 64MB causes `Page crashed` |
| `seccomp` | `unconfined` | Chromium sandbox requires syscalls blocked by default Docker seccomp profile |
| `AGENT_BROWSER_ARGS` | `--no-sandbox,--disable-dev-shm-usage,--disable-gpu` | Pass browser launch flags |
| `SYS_ADMIN` cap | Required | Chromium sandbox needs `clone()` with `CLONE_NEWUSER` |

**In `docker-compose.yml`** (openclaw service):
```yaml
shm_size: '512mb'
environment:
  - AGENT_BROWSER_ARGS=--no-sandbox,--disable-dev-shm-usage,--disable-gpu
```

**In `docker-compose.security.yml`** (openclaw service):
```yaml
security_opt:
  - no-new-privileges:true
  - seccomp:unconfined      # REQUIRED for Chromium/Playwright
cap_add:
  - SYS_ADMIN               # REQUIRED for Chromium browser sandbox
```

### If Browser Shows "Page crashed"

This almost always means one of the Docker settings above is missing. Diagnosis:
```bash
# Check shm size (must be >64M, ideally 512M)
docker exec openclaw-gateway df -h /dev/shm

# Check seccomp (must be 0 for unconfined)
docker exec openclaw-gateway cat /proc/1/status | grep Seccomp

# Check browser args
docker exec openclaw-gateway printenv AGENT_BROWSER_ARGS

# Check agent-browser is installed
docker exec openclaw-gateway agent-browser --version
```

If `agent-browser` is missing after a container rebuild:
```bash
docker exec -u root openclaw-gateway npm install -g agent-browser
```

### Chromium Inside Container

The container has Playwright's Chromium pre-installed:
- **Chromium binary**: `/opt/playwright/chromium-1208/chrome-linux/chrome` (v145.0.7632.0)
- **Headless shell**: `/opt/playwright/chromium_headless_shell-1208/chrome-linux/headless_shell`
- **Playwright**: v1.58.0 (`PLAYWRIGHT_BROWSERS_PATH=/opt/playwright`)

### Basic Usage

```bash
# Open a URL
docker exec openclaw-gateway agent-browser open https://example.com

# Take snapshot (get element refs)
docker exec openclaw-gateway agent-browser snapshot -i

# Click element
docker exec openclaw-gateway agent-browser click @e1

# Fill form field
docker exec openclaw-gateway agent-browser fill @e2 "text"

# Screenshot
docker exec openclaw-gateway agent-browser screenshot /tmp/screenshot.png

# Copy screenshot to host
docker cp openclaw-gateway:/tmp/screenshot.png /Users/jeffsutherland/clawd/screenshot.png
```

### 🔭 Interactive Live View — Pair-Program with Raven

**This is the most critical capability for hybrid human-agent Scrum teams.**

The Interactive Browser Live View runs on the Mac host (port 8083) and provides a SHARED, INTERACTIVE browser session. Both Jeff and Raven can see the same page and both can click, type, scroll, and navigate — enabling true pair-programming.

**Start the interactive live view:**
```bash
python3 /Users/jeffsutherland/clawd/browser-live-view.py
# Open http://localhost:8083 in your browser
```

**Jeff's interactive controls in the live view:**
| Control | What It Does |
|---|---|
| URL bar + Go | Navigate to any URL |
| ◀ ▶ ⟳ | Browser back, forward, reload |
| Click on screenshot | Clicks at that position in the real browser |
| 📸 Capture | Force immediate screenshot refresh |
| 🔴 Live / ⚪ Paused | Toggle 3-second auto-refresh |
| ⬆⬇ Scroll | Scroll page up/down 400px |
| ⌨️ Type Text | Type into the focused field |
| ↵ Enter / ⇥ Tab / Esc | Press keyboard keys |
| 📋 Elements panel | See and click interactive elements by ref |
| Command bar | Run raw agent-browser commands (e.g. `click @e1`) |
| Action Log tab | History of all interactions |

**Pair-programming workflow:**
1. Jeff starts the live view server in a terminal
2. Jeff opens http://localhost:8083 in Chrome/Safari
3. Raven (or Jeff) opens a page via the URL bar or `agent-browser open`
4. Both interact: Jeff clicks/types in the live view, Raven runs commands
5. Both see every change in real-time (3-second refresh cycle)

**Key use cases:**
- **Joint demos** — walk through websites together
- **Jeff logs in, Raven takes over** — Jeff enters credentials, Raven continues
- **Collaborative debugging** — both see error pages
- **Web research** — explore and discuss findings in real-time

**Architecture:**
```
Jeff's Browser ──► browser-live-view.py (port 8083) ──► Docker agent-browser ──► Chromium
   (click/type)        (Python on Mac)                    (in container)         (headless)
```

**Script:** `/Users/jeffsutherland/clawd/browser-live-view.py`
**Dependencies:** Python 3 stdlib only (no pip packages needed)

See [RAVEN-BROWSER-GUIDE.md](RAVEN-BROWSER-GUIDE.md) for full pair-programming documentation.

### Co-Viewing / Pair-Programming Approaches

| Method | Best For | Setup |
|---|---|---|
| **Interactive Live View** | Real-time pair-programming, joint demos, collaborative work | `python3 browser-live-view.py` → http://localhost:8083 |
| **One-off Screenshot** | Quick screenshots, async review | `agent-browser screenshot` + `docker cp` |
| **Annotated Screenshot** | Discussing which elements to click | `agent-browser screenshot --annotate` |

**Recommended workflow for hybrid Scrum teams:**
1. Start the Interactive Live View before any browser-based work
2. Keep it running in a browser tab throughout the session
3. Both human and agent communicate about what they see
4. Agent announces actions before executing them
5. Human can intervene at any point by clicking/typing in the live view

See [RAVEN-BROWSER-GUIDE.md](RAVEN-BROWSER-GUIDE.md) for full command reference.

---

## 12. Configuration Scripts

All scripts in `/Users/jeffsutherland/clawd/`:

### Model Management

| Script | Purpose |
|---|---|
| `switch-to-minimax.py` | Set primary model to MiniMax M2.5 |
| `fix-config-restore-sonnet.py` | Emergency fallback to Claude Sonnet |
| `fix-minimax-config.py` | Clean config, remove `providers` key |
| `setup-raven-gemini.py` | Configure Raven for Gemini 3.1 Pro |
| `rollback-raven-to-minimax.py` | Roll back Raven from Gemini to MiniMax |

### Service Scripts

| Script | Purpose |
|---|---|
| `check-calendar.py` | Weekly calendar overview |
| `today-schedule.py` | Today's schedule for Morning Report |
| `check-email-updated.py` | Check all email accounts (TLS proxy safe) |
| `moltbook-post.py` | Post to / read Moltbook |
| `test-moltbook.py` | Test Moltbook API connectivity |

### Usage Pattern

All scripts follow the same pattern:
```bash
# Run locally (config management scripts)
python3 /Users/jeffsutherland/clawd/<script>.py

# Run in container (service scripts)
docker exec openclaw-gateway python3 /workspace/<script>.py

# Copy script to container if missing
docker cp /Users/jeffsutherland/clawd/<script>.py openclaw-gateway:/workspace/<script>.py
```

### After Config Changes — Always:
```bash
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

---

## 13. Raven Guides Index

| Guide | Description |
|---|---|
| [RAVEN-CALENDAR-GUIDE.md](RAVEN-CALENDAR-GUIDE.md) | Google Calendar access, today-schedule, Morning Report format |
| [RAVEN-BROWSER-GUIDE.md](RAVEN-BROWSER-GUIDE.md) | Agent Browser skill — web automation reference |
| [RAVEN-MOLTBOOK-PASSWORD-RESET.md](RAVEN-MOLTBOOK-PASSWORD-RESET.md) | Moltbook credentials and access recovery |
| [RAVEN-TELEGRAM-AGENTS-GUIDE.md](RAVEN-TELEGRAM-AGENTS-GUIDE.md) | Agent team roster, Telegram bots, communication |
| [RAVEN-SEND-DM-GUIDE.md](RAVEN-SEND-DM-GUIDE.md) | How to send DMs via Telegram |
| [RAVEN-EMAIL-GUIDE.md](RAVEN-EMAIL-GUIDE.md) | Email accounts, Himalaya config (in container) |
| [RAVEN-MISSION-CONTROL-GUIDE.md](RAVEN-MISSION-CONTROL-GUIDE.md) | MC board, task management (in container) |
| [RAVEN-AGENT-TEAM-GUIDE.md](RAVEN-AGENT-TEAM-GUIDE.md) | Team structure, delegation (in container) |

---

## 14. Known Issues & Lessons Learned

### MiniMax API Issues (Feb 22)
- **Problem**: "No API key found for provider minimax" / "insufficient balance (1008)"
- **Root cause**: Wrong API key (original MiniMax key had no balance; needed Coding Plan key)
- **Fix**: Use Coding Plan key: `<MINIMAX_API_KEY>...`
- **Lesson**: MiniMax uses Anthropic-compatible API. The `provider` field in auth-profiles must be `"anthropic"`, and the API is at `https://api.minimax.io/anthropic`

### Config `providers` Key (Feb 22)
- **Problem**: Container in restart loop
- **Root cause**: Adding a `providers` key under `agents.defaults` causes config validation failure
- **Fix**: Remove the `providers` key entirely. Model configs only need `params` sub-key.
- **Lesson**: Never add `providers` under `agents.defaults`

### Gemini 3.1 "Unknown model" (Feb 24)
- **Problem**: `Error: Unknown model: google/gemini-3.1-pro-preview`
- **Root cause**: OpenClaw v2026.2.19 model catalog doesn't include `gemini-3.1-pro-preview`
- **Fix options**: (a) Upgrade OpenClaw, (b) Use `models.providers.google.models` config bypass, (c) Use `gemini-3-pro-preview` (which IS in catalog)
- **Lesson**: Check the OpenClaw model catalog before configuring a new model

### Gemini Rate Limits (Feb 24)
- **Problem**: Immediate 429 errors when using free-tier Gemini
- **Root cause**: OpenClaw stuffs all tool schemas + system prompts into each request. With 13 active skills, a single request can exceed 250K TPM limit.
- **Fix**: Attach Google billing for pay-as-you-go, or reduce active skills for Gemini agents
- **Lesson**: Free-tier Gemini is incompatible with multi-skill agents

### Empty Files After Terminal Issues (Feb 25)
- **Problem**: Several .py and .md files became 0 bytes
- **Root cause**: Terminal dquote/heredoc issues during concurrent editing
- **Fix**: Restore from container copies or recreate from documented specifications
- **Lesson**: Always verify file sizes after batch operations

### Agent Browser "Page crashed" (Feb 25)
- **Problem**: `agent-browser open` gives `✗ page.goto: Page crashed` for any URL
- **Root cause**: Docker container had only 64MB `/dev/shm` (shared memory) and seccomp filter level 2 (restricted). Chromium requires ≥128MB shm and unconfined seccomp.
- **Fix (all three required)**:
  1. Add `shm_size: '512mb'` to openclaw service in `docker-compose.yml`
  2. Add `seccomp:unconfined` to security_opt in `docker-compose.security.yml`
  3. Add `AGENT_BROWSER_ARGS=--no-sandbox,--disable-dev-shm-usage,--disable-gpu` env var
  4. Add `SYS_ADMIN` to cap_add
  5. Recreate container: `docker compose -f docker-compose.yml -f docker-compose.security.yml up -d openclaw`
- **Also**: `agent-browser` must be installed globally: `docker exec -u root openclaw-gateway npm install -g agent-browser`
- **Diagnosis**: Check `df -h /dev/shm` (should show 512M), `grep Seccomp /proc/1/status` (should show 0)
- **Lesson**: Chromium in Docker needs explicit shm, seccomp, and SYS_ADMIN capability overrides

---

## 15. Troubleshooting Runbook

### Gateway Won't Start / Crash Loop
```bash
# Check status
docker ps -a | grep openclaw-gateway
# If "Restarting", check logs:
docker logs --tail=50 openclaw-gateway
# Common fix: remove 'providers' key from config
python3 /Users/jeffsutherland/clawd/fix-minimax-config.py
# Restart
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

### "No API key found" Error
```bash
# Check auth profiles
cat /Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/agents/main/agent/auth-profiles.json
# Verify key is present and provider matches model
# For MiniMax: provider should be "anthropic"
# For Gemini: provider should be "google"
```

### Agent Not Responding on Telegram
```bash
# Check if gateway is running
docker ps | grep openclaw-gateway
# Check Telegram providers in logs
docker logs --tail=50 openclaw-gateway | grep telegram
# Verify bot tokens in config
```

### Calendar Token Expired
```bash
docker exec openclaw-gateway python3 -c "
from google.oauth2.credentials import Credentials
from google.auth.transport.requests import Request
creds = Credentials.from_authorized_user_file('/home/node/.config/google/calendar_token.json')
print('Valid:', creds.valid, 'Expired:', creds.expired)
if creds.expired and creds.refresh_token:
    creds.refresh(Request())
    with open('/home/node/.config/google/calendar_token.json', 'w') as f:
        f.write(creds.to_json())
    print('REFRESHED')
"
```

### Copy All Scripts to Container
```bash
for f in check-calendar.py today-schedule.py check-email-updated.py moltbook-post.py test-moltbook.py; do
  docker cp /Users/jeffsutherland/clawd/$f openclaw-gateway:/workspace/$f
  echo "Copied $f"
done
```

---

*This document should be kept at `/Users/jeffsutherland/clawd/OPENCLAW-OPERATIONS-GUIDE.md` and copied to the container at `/workspace/OPENCLAW-OPERATIONS-GUIDE.md` for agent reference.*

