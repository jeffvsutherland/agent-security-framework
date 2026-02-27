#!/usr/bin/env python3
"""Fix Raven's MC visibility: correct API endpoints, set gateway.id, link agent to MC."""
import subprocess, json

OUTFILE = "/Users/jeffsutherland/clawd/mc-raven-mcfix.txt"
results = []
def log(msg):
    results.append(msg)

TOKEN = "HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"

log("=== Fix Raven MC Visibility ===\n")

# 1. Discover the correct API endpoints
log("--- API Discovery ---")
r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
    f'curl -s -m 5 -H "Authorization: Bearer {TOKEN}" http://host.docker.internal:8001/docs/openapi.json 2>&1 | head -c 3000'],
    capture_output=True, text=True, timeout=10)
# Try to parse paths
try:
    api = json.loads(r.stdout)
    paths = list(api.get("paths", {}).keys())
    log("API paths:")
    for p in paths:
        log(f"  {p}")
except:
    log(f"Couldn't parse OpenAPI, trying /openapi.json...")
    r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
        f'curl -s -m 5 -H "Authorization: Bearer {TOKEN}" http://host.docker.internal:8001/openapi.json 2>&1 | python3 -c "import sys,json; d=json.load(sys.stdin); [print(p) for p in d.get(\'paths\',{{}}).keys()]"'],
        capture_output=True, text=True, timeout=10)
    log(r.stdout.strip()[:1000])

# 2. Try different card endpoints
log("\n--- Finding cards endpoint ---")
for path in [
    "/api/v1/boards/agent-security-framework/cards",
    "/api/v1/boards/agent-security-framework/tasks",
    "/api/v1/cards",
    "/api/v1/tasks",
    "/api/v1/boards/24394a90-a74e-479c-95e8/cards",  # using board ID from earlier
]:
    r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
        f'curl -s -m 5 -H "Authorization: Bearer {TOKEN}" http://host.docker.internal:8001{path} 2>&1 | head -c 200'],
        capture_output=True, text=True, timeout=10)
    status = "OK" if '"items"' in r.stdout or '"id"' in r.stdout else "FAIL"
    log(f"  {path}: {status} — {r.stdout.strip()[:150]}")

# 3. Get the full board info to find the board ID
r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
    f'curl -s -m 5 -H "Authorization: Bearer {TOKEN}" http://host.docker.internal:8001/api/v1/boards 2>&1'],
    capture_output=True, text=True, timeout=10)
board_id = None
try:
    boards = json.loads(r.stdout)
    for b in boards.get("items", []):
        log(f"\n  Board: {b.get('name')} id={b.get('id')} slug={b.get('slug')} gateway_id={b.get('gateway_id')}")
        if b.get("slug") == "agent-security-framework":
            board_id = b.get("id")
except:
    log(f"  Boards raw: {r.stdout[:300]}")

# 4. Try cards with board ID
if board_id:
    log(f"\n--- Cards with board ID {board_id} ---")
    for path in [
        f"/api/v1/boards/{board_id}/cards",
        f"/api/v1/boards/{board_id}/tasks",
    ]:
        r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
            f'curl -s -m 5 -H "Authorization: Bearer {TOKEN}" http://host.docker.internal:8001{path} 2>&1 | head -c 300'],
            capture_output=True, text=True, timeout=10)
        log(f"  {path}: {r.stdout.strip()[:200]}")

# 5. List all API routes from docs page
log("\n--- All API routes ---")
r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
    f'curl -s -m 5 http://host.docker.internal:8001/openapi.json 2>&1 | python3 -c "import sys,json;d=json.load(sys.stdin);[print(m.upper(),p) for p,v in d.get(\'paths\',{{}}).items() for m in v.keys() if m in (\'get\',\'post\',\'put\',\'patch\',\'delete\')]" 2>&1'],
    capture_output=True, text=True, timeout=10)
log(r.stdout.strip()[:1500])

with open(OUTFILE, "w") as f:
    f.write("\n".join(results) + "\n")
print(f"Results: {OUTFILE}")

