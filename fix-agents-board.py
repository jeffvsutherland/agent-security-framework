#!/usr/bin/env python3
"""Fix agents: set active status, assign to board, set board lead, increase max_agents."""
import json
import urllib.request

MC = "http://localhost:8001"
AUTH = "Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
BOARD_ID = "24394a90-a74e-479c-95e8-e5d24c7b4a40"
OUT = "/Users/jeffsutherland/clawd/fix-agents-result.txt"

lines = []
def log(msg):
    lines.append(msg)
    print(msg)

def api(method, path, data=None):
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(f"{MC}{path}", data=body, method=method,
        headers={"Authorization": AUTH, "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        err = e.read().decode()
        log(f"  ERROR {e.code}: {err[:300]}")
        return None

# Step 1: Increase board max_agents from 1 to 10
log("=== Step 1: Update board max_agents to 10 ===")
result = api("PATCH", f"/api/v1/boards/{BOARD_ID}", {
    "max_agents": 10,
    "name": "Agent Security Framework"
})
if result:
    log(f"  Board updated: max_agents={result.get('max_agents')}, name={result.get('name')}")
else:
    log("  Board update FAILED")

# Step 2: Get all agents
log("\n=== Step 2: Get all agents ===")
agents = api("GET", "/api/v1/agents")
if not agents:
    log("  FAILED to get agents")
    with open(OUT, "w") as f: f.write("\n".join(lines))
    exit(1)

for a in agents["items"]:
    log(f"  {a['name']}: status={a['status']}, board={a.get('board_id')}, lead={a.get('is_board_lead')}")

# Step 3: Update each agent to active + on board
log("\n=== Step 3: Set all agents to active + on board ===")
for a in agents["items"]:
    aid = a["id"]
    name = a["name"]
    updates = {}

    # Set status to active if not already
    if a["status"] != "active" and a["status"] != "online":
        updates["status"] = "active"

    # Assign to board if not assigned
    if not a.get("board_id"):
        updates["board_id"] = BOARD_ID

    # Set Raven as board lead
    if "Product Owner" in name or "Raven" in name:
        updates["is_board_lead"] = True  # Try this field

    if updates:
        log(f"\n  Updating {name}: {updates}")
        result = api("PATCH", f"/api/v1/agents/{aid}", updates)
        if result:
            log(f"    OK: status={result.get('status')}, board={result.get('board_id')}, lead={result.get('is_board_lead')}")
        else:
            log(f"    FAILED")
    else:
        log(f"\n  {name}: no changes needed")

# Step 4: Final verification
log("\n=== Step 4: Final verification ===")
final = api("GET", "/api/v1/agents")
if final:
    for a in final["items"]:
        log(f"  {a['name']}: status={a['status']}, board={a.get('board_id','NONE')}, lead={a.get('is_board_lead')}, seen={a.get('last_seen_at')}")
    log(f"\nTotal agents: {final['total']}")

# Check board
log("\n=== Board status ===")
board = api("GET", f"/api/v1/boards/{BOARD_ID}")
if board:
    log(f"  Name: {board['name']}")
    log(f"  max_agents: {board['max_agents']}")
    log(f"  gateway: {board.get('gateway_id')}")

with open(OUT, "w") as f:
    f.write("\n".join(lines))
log(f"\nResults saved to {OUT}")

