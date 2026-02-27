# Mission Control Access Guide for Raven

**Date:** February 22, 2026
**Status:** Agents are registered in Mission Control but **not** automatically connected

---

## Current Situation

✅ Mission Control is running and accessible
✅ All 6 agents are registered in Mission Control database
❌ OpenClaw does not have built-in auto-heartbeat to Mission Control
✅ Agents CAN access Mission Control via REST API manually

---

## How to Access Mission Control from OpenClaw Agents

### Connection Details

**From inside Docker containers (like Raven's agent):**

- **Primary API URL:** `http://host.docker.internal:8001/api/v1`
- **Fallback API URL:** `http://openclaw-mission-control-backend-1:8000/api/v1`
- **Auth Header (REQUIRED on every request):**
  ```
  Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM
  ```
- **Board ID:** `24394a90-a74e-479c-95e8-e5d24c7b4a40`
- **Board Name:** Agent Security Framework

### Your Agent ID

**Raven (Product Owner):**
- **Agent ID:** `3634c19a-9174-4f23-b03a-0d451f5de6be`
- **Agent Token:** `mCCZKyLDzERf2mkGRwBg4dWtQwjTlCSqpRNix7IAX_U`
- **Telegram Bot:** @AgentSaturdayASFBot
- **Role:** Board Lead, Product Owner
- **Status in MC:** Currently offline (not auto-heartbeating)

---

## Quick Reference API Commands

### 1. View All Tasks on the Board
```bash
curl -s -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
  "http://host.docker.internal:8001/api/v1/boards/24394a90-a74e-479c-95e8-e5d24c7b4a40/tasks" | jq '.'
```

### 2. View Only Inbox Tasks (Available to Pick Up)
```bash
curl -s -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
  "http://host.docker.internal:8001/api/v1/boards/24394a90-a74e-479c-95e8-e5d24c7b4a40/tasks?status=inbox" | jq '.'
```

### 3. Self-Assign a Task and Move to In Progress
```bash
TASK_ID="your-task-id-here"
curl -s -X PATCH \
  -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
  -H "Content-Type: application/json" \
  "http://host.docker.internal:8001/api/v1/tasks/$TASK_ID" \
  -d '{
    "status": "in_progress",
    "assigned_agent_id": "3634c19a-9174-4f23-b03a-0d451f5de6be"
  }' | jq '.'
```

### 4. Move Completed Task to Review
```bash
TASK_ID="your-task-id-here"
curl -s -X PATCH \
  -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
  -H "Content-Type: application/json" \
  "http://host.docker.internal:8001/api/v1/tasks/$TASK_ID" \
  -d '{"status": "review"}' | jq '.'
```

### 5. Add Comment to Task
```bash
TASK_ID="your-task-id-here"
curl -s -X POST \
  -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
  -H "Content-Type: application/json" \
  "http://host.docker.internal:8001/api/v1/tasks/$TASK_ID/comments" \
  -d '{
    "content": "Your comment here",
    "comment_type": "update"
  }' | jq '.'
```

### 6. View All Agents Status
```bash
curl -s -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
  "http://host.docker.internal:8001/api/v1/agents" | jq '.items[] | {name, status, last_seen_at}'
```

### 7. Send Heartbeat (Manual)
```bash
curl -s -X POST \
  -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
  -H "Content-Type: application/json" \
  "http://host.docker.internal:8001/api/v1/agents/3634c19a-9174-4f23-b03a-0d451f5de6be/heartbeat" \
  -d '{
    "status": "online",
    "message": "Agent is active"
  }' | jq '.'
```

---

## Why Aren't Agents Auto-Connecting?

OpenClaw Mission Control is a **separate application** that provides a centralized dashboard and API for work orchestration. It does NOT have built-in plugin integration with OpenClaw gateway.

**The design is intentional:**
- Agents access Mission Control **on-demand** via REST API when they need to check tasks or update status
- This keeps agents autonomous and decoupled from central control
- Agents can work independently and sync when needed

**To make agents "online" in Mission Control:**
- Agents must manually call the heartbeat API endpoint periodically
- OR agents can be configured with a custom heartbeat script/skill
- OR a separate monitoring service can ping Mission Control on behalf of agents

---

## Recommended Workflow for Raven

As the Product Owner, you should:

1. **Check the board daily** using the "View All Tasks" API command
2. **Prioritize inbox items** by reviewing tasks and assigning them
3. **Monitor agent progress** by checking task statuses
4. **Send heartbeats** when actively working (optional, for visibility)

**Example Daily Check Script:**
```bash
#!/bin/bash
# Quick board status check

AUTH="Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
API="http://host.docker.internal:8001/api/v1"
BOARD="24394a90-a74e-479c-95e8-e5d24c7b4a40"

echo "=== Board Status ==="
curl -s -H "Authorization: $AUTH" \
  "$API/boards/$BOARD/tasks?status=inbox" | \
  jq -r '.items[] | "[\(.priority)] \(.title)"'

echo ""
echo "=== In Progress ==="
curl -s -H "Authorization: $AUTH" \
  "$API/boards/$BOARD/tasks?status=in_progress" | \
  jq -r '.items[] | "[\(.assigned_agent_id)] \(.title)"'
```

---

## Human Dashboard Access

Jeff can access the web dashboard at:
- **URL:** http://localhost:3001
- **Login Token:** `HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM`

From the dashboard, he can:
- View the kanban board
- Manually assign tasks
- Review agent activity
- Approve completed work

---

## Next Steps to Enable Auto-Heartbeat (Optional)

If you want agents to automatically show as "online" in Mission Control:

1. **Create a heartbeat skill** in OpenClaw that periodically calls the heartbeat API
2. **Add cron job** in OpenClaw config to run the heartbeat every 10 minutes
3. **Configure agent-specific heartbeat endpoints** in each agent's configuration

This would require custom development and is not currently implemented.

---

## All Registered Agents

| Agent | ID | Status | Telegram Bot |
|-------|-----|--------|--------------|
| Raven (Product Owner) | `3634c19a-9174-4f23-b03a-0d451f5de6be` | offline | @AgentSaturdayASFBot |
| Sales Agent | `f231fd0f-6004-4268-8dc9-d7013fcb23e9` | offline | @ASFSalesBot |
| Research Agent | `a752e9fc-8c0d-4a12-b455-de0a322c142f` | offline | @ASFResearchBot |
| Social Agent | `b9efac34-d836-4505-b123-130502e6f42b` | offline | @ASFSocialBot |
| Deploy Agent | `30374dc0-f90b-4291-bda3-99e8db3424db` | offline | @ASFDeployBot |
| Main Agent | `ae63a2bf-863a-4daa-a010-42258d6e40a3` | offline | @jeffsutherlandbot |

All agents are registered and can access the API - they're just not configured to automatically heartbeat.

---

**Summary:** Mission Control is working correctly. Agents access it via REST API when needed. Auto-heartbeat is not built-in and would require custom development.
