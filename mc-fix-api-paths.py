#!/usr/bin/env python3
"""Fix mc-api script with correct API paths and update gateway config."""
import subprocess, json, os

OUTFILE = "/Users/jeffsutherland/clawd/mc-fix-final.txt"
results = []
def log(msg):
    results.append(msg)

TOKEN = "HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
BOARD_ID = "24394a90-a74e-479c-95e8-e5d24c7b4a40"
GATEWAY_ID = "c3ff9d87-8e4d-47a8-b162-ef7b2285fb91"

log("=== Fix MC API + Config ===\n")

# 1. Write corrected mc-api script
# Correct paths: /api/v1/agent/boards, /api/v1/agent/boards/{id}/tasks
script = f"""#!/bin/sh
MC_TOKEN="{TOKEN}"
MC_URL="http://host.docker.internal:8001"
BOARD_ID="{BOARD_ID}"

case "$1" in
  health)
    curl -s -m 10 "$MC_URL/health"
    ;;
  boards)
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/agent/boards"
    ;;
  tasks|cards)
    BID="${{2:-$BOARD_ID}}"
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/agent/boards/$BID/tasks"
    ;;
  create-task|create-card)
    BID="${{2:-$BOARD_ID}}"
    curl -s -m 10 -X POST -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/agent/boards/$BID/tasks"
    ;;
  update-task|update-card)
    curl -s -m 10 -X PATCH -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/agent/boards/$BOARD_ID/tasks/$2"
    ;;
  comments)
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/agent/boards/$BOARD_ID/tasks/$2/comments"
    ;;
  add-comment)
    curl -s -m 10 -X POST -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/agent/boards/$BOARD_ID/tasks/$2/comments"
    ;;
  tags)
    BID="${{2:-$BOARD_ID}}"
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/agent/boards/$BID/tags"
    ;;
  memory)
    BID="${{2:-$BOARD_ID}}"
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/agent/boards/$BID/memory"
    ;;
  agents)
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/agent/agents"
    ;;
  heartbeat)
    curl -s -m 10 -X POST -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$2" "$MC_URL/api/v1/agent/heartbeat"
    ;;
  *)
    M="${{1:-GET}}"; E="$2"; B="$3"
    if [ -n "$B" ]; then
      curl -s -m 10 -X "$M" -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$B" "$MC_URL$E"
    else
      curl -s -m 10 -X "$M" -H "Authorization: Bearer $MC_TOKEN" "$MC_URL$E"
    fi
    ;;
esac
"""

# Write to temp file and docker cp
tmp = "/tmp/mc-api-v2.sh"
with open(tmp, "w") as f:
    f.write(script)

r = subprocess.run(["docker", "cp", tmp, "openclaw-gateway:/usr/local/bin/mc-api"],
                    capture_output=True, text=True, timeout=10)
log(f"docker cp mc-api: rc={r.returncode}")

r = subprocess.run(["docker", "exec", "-u", "0", "openclaw-gateway", "chmod", "+x", "/usr/local/bin/mc-api"],
                    capture_output=True, text=True, timeout=5)
log(f"chmod: rc={r.returncode}")

# Also copy to workspaces
for d in ["/workspace/agents/product-owner", "/workspace/workspace-mc-3634c19a-9174-4f23-b03a-0d451f5de6be", "/workspace"]:
    subprocess.run(["docker", "exec", "-u", "0", "openclaw-gateway", "cp", "/usr/local/bin/mc-api", f"{d}/mc-api.sh"],
                    capture_output=True, text=True, timeout=5)
    subprocess.run(["docker", "exec", "-u", "0", "openclaw-gateway", "chmod", "+x", f"{d}/mc-api.sh"],
                    capture_output=True, text=True, timeout=5)
log("Copied to all workspaces")

os.remove(tmp)

# 2. Test the fixed mc-api
log("\n--- Testing fixed mc-api ---")
r = subprocess.run(["docker", "exec", "-u", "1000", "openclaw-gateway", "mc-api", "health"],
                    capture_output=True, text=True, timeout=10)
log(f"health: {r.stdout.strip()}")

r = subprocess.run(["docker", "exec", "-u", "1000", "openclaw-gateway", "mc-api", "boards"],
                    capture_output=True, text=True, timeout=10)
try:
    boards = json.loads(r.stdout)
    for b in boards.get("items", boards) if isinstance(boards, dict) else boards:
        if isinstance(b, dict):
            log(f"board: {b.get('name')} (id={b.get('id')[:12]}...)")
except:
    log(f"boards: {r.stdout.strip()[:200]}")

r = subprocess.run(["docker", "exec", "-u", "1000", "openclaw-gateway", "mc-api", "tasks"],
                    capture_output=True, text=True, timeout=10)
try:
    tasks = json.loads(r.stdout)
    items = tasks.get("items", tasks) if isinstance(tasks, dict) else tasks
    if isinstance(items, list):
        log(f"\ntasks ({len(items)} found):")
        for t in items[:5]:
            log(f"  [{t.get('status','?')}] {t.get('title','?')}")
    else:
        log(f"tasks: {str(items)[:300]}")
except:
    log(f"tasks raw: {r.stdout.strip()[:300]}")

r = subprocess.run(["docker", "exec", "-u", "1000", "openclaw-gateway", "mc-api", "agents"],
                    capture_output=True, text=True, timeout=10)
log(f"\nagents: {r.stdout.strip()[:300]}")

# 3. Update HEARTBEAT.md with correct commands
heartbeat = f"""# HEARTBEAT - Raven (Product Owner)

## CRITICAL: You are INSIDE Docker
- Do NOT run `docker exec` — you are already inside
- Do NOT run `docker` — not available

## Mission Control API

`mc-api` is in your PATH. Use it for ALL MC operations.

### Pre-flight:
```
mc-api health
mc-api boards
mc-api tasks
```

### Commands:
```
mc-api health                         # Health check
mc-api boards                         # List boards
mc-api tasks                          # List tasks on ASF board
mc-api tasks BOARD_ID                 # Tasks on specific board
mc-api create-task '{{\"title\":\"New task\",\"description\":\"Details\"}}'
mc-api update-task TASK_ID '{{\"status\":\"done\"}}'
mc-api comments TASK_ID               # Get comments on task
mc-api add-comment TASK_ID '{{\"body\":\"My comment\"}}'
mc-api tags                           # List tags
mc-api memory                         # Board memory
mc-api agents                         # List agents
mc-api GET /api/v1/agent/boards       # Raw GET
```

### NEVER use curl with Authorization headers manually.
### ALWAYS use `mc-api`.

## Board ID: {BOARD_ID}
## If pre-flight succeeds, proceed with tasks. If fails, report to Jeff.
"""

for ws in ["/workspace/agents/product-owner", "/workspace/workspace-mc-3634c19a-9174-4f23-b03a-0d451f5de6be"]:
    r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
                         f"cat > {ws}/HEARTBEAT.md << 'EOF'\n{heartbeat}\nEOF"],
                        capture_output=True, text=True, timeout=5)
    log(f"\nHEARTBEAT {ws}: rc={r.returncode}")

with open(OUTFILE, "w") as f:
    f.write("\n".join(results) + "\n")
print(f"Results: {OUTFILE}")

