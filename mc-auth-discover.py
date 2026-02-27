#!/usr/bin/env python3
"""Figure out auth for /api/v1/agent/ endpoints vs /api/v1/ endpoints."""
import subprocess, json

OUTFILE = "/Users/jeffsutherland/clawd/mc-auth-test.txt"
results = []
def log(msg):
    results.append(msg)

LOCAL_TOKEN = "HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
BOARD_ID = "24394a90-a74e-479c-95e8-e5d24c7b4a40"

# Load agent tokens
with open("/Users/jeffsutherland/clawd/agent-tokens.json") as f:
    tokens = json.load(f)

log("=== MC Auth Discovery ===\n")

# Test LOCAL_TOKEN on both endpoint families
for path in ["/api/v1/boards", f"/api/v1/boards/{BOARD_ID}/tasks",
             "/api/v1/agent/boards", f"/api/v1/agent/boards/{BOARD_ID}/tasks",
             "/api/v1/agents"]:
    r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
        f'curl -s -m 5 -H "Authorization: Bearer {LOCAL_TOKEN}" http://host.docker.internal:8001{path} 2>&1 | head -c 150'],
        capture_output=True, text=True, timeout=10)
    ok = "OK" if '"items"' in r.stdout or '"id"' in r.stdout else "FAIL"
    log(f"LOCAL_TOKEN {path}: {ok} — {r.stdout.strip()[:120]}")

log("")

# Test Raven's agent token
for name, tok in tokens.items():
    if "raven" in name.lower() or "product" in name.lower():
        agent_token = tok.get("token", "") if isinstance(tok, dict) else tok
        agent_id = tok.get("agent_id", "") if isinstance(tok, dict) else ""
        log(f"Testing {name} (id={agent_id[:12]}...):")
        for path in ["/api/v1/agent/boards", f"/api/v1/agent/boards/{BOARD_ID}/tasks", "/api/v1/agent/agents"]:
            r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
                f'curl -s -m 5 -H "Authorization: Bearer {agent_token}" http://host.docker.internal:8001{path} 2>&1 | head -c 150'],
                capture_output=True, text=True, timeout=10)
            ok = "OK" if '"items"' in r.stdout or '"id"' in r.stdout else "FAIL"
            log(f"  {path}: {ok} — {r.stdout.strip()[:120]}")
        break

log("")

# Test OPERATOR_TOKEN
OPERATOR_TOKEN = "uuI7HDktGsmbKPLeyJOCOib607dJoKWQybTXuGYMRm0"
log(f"Testing OPERATOR_TOKEN:")
for path in ["/api/v1/agent/boards", f"/api/v1/agent/boards/{BOARD_ID}/tasks"]:
    r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
        f'curl -s -m 5 -H "Authorization: Bearer {OPERATOR_TOKEN}" http://host.docker.internal:8001{path} 2>&1 | head -c 150'],
        capture_output=True, text=True, timeout=10)
    ok = "OK" if '"items"' in r.stdout or '"id"' in r.stdout else "FAIL"
    log(f"  {path}: {ok} — {r.stdout.strip()[:120]}")

# The /api/v1/boards worked with LOCAL_TOKEN but /api/v1/agent/ doesn't.
# The non-agent endpoints were the admin/dashboard endpoints.
# Let's find which endpoints work with LOCAL_TOKEN for tasks:
log(f"\n--- Working task endpoints with LOCAL_TOKEN ---")
for path in [
    f"/api/v1/boards/{BOARD_ID}/tasks",
    f"/api/v1/boards/agent-security-framework/tasks",
    "/api/v1/activity",
    "/api/v1/activity/task-comments",
]:
    r = subprocess.run(["docker", "exec", "openclaw-gateway", "sh", "-c",
        f'curl -s -m 5 -H "Authorization: Bearer {LOCAL_TOKEN}" http://host.docker.internal:8001{path} 2>&1 | head -c 200'],
        capture_output=True, text=True, timeout=10)
    ok = "OK" if '"items"' in r.stdout or '"id"' in r.stdout else "FAIL"
    log(f"  {path}: {ok} — {r.stdout.strip()[:150]}")

with open(OUTFILE, "w") as f:
    f.write("\n".join(results) + "\n")
print(f"Results: {OUTFILE}")

