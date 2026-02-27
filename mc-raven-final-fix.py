#!/usr/bin/env python3
"""
Fix Raven's MC access once and for all.
Problem: Token has special chars (+/=) that break shell quoting.
Solution: Write the token to a file Raven can source, and provide
a helper script she can use.
"""
import subprocess, json

OUT = "/Users/jeffsutherland/clawd/copilot_out.txt"
f = open(OUT, "w")
def log(msg):
    f.write(msg + "\n")
    f.flush()

LOCAL_AUTH_TOKEN = "HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"

log("=== Fixing Raven MC Access ===\n")

# 1. Write token to a plain text file (no quoting issues)
for ws in [
    "/workspace/agents/product-owner",
    "/workspace/workspace-mc-3634c19a-9174-4f23-b03a-0d451f5de6be"
]:
    # Token file
    r = subprocess.run(
        ["docker", "exec", "openclaw-gateway", "sh", "-c",
         f"printf '%s' '{LOCAL_AUTH_TOKEN}' > {ws}/.mc-token && chmod 600 {ws}/.mc-token && echo OK"],
        capture_output=True, text=True, timeout=5
    )
    log(f"  Token file {ws}/.mc-token: {r.stdout.strip()}")

    # Helper script: mc-api.sh
    script = '''#!/bin/sh
# Mission Control API helper - handles token quoting properly
MC_TOKEN=$(cat "$(dirname "$0")/.mc-token")
MC_URL="http://host.docker.internal:8001"

if [ "$1" = "health" ]; then
    curl -s -m 10 "$MC_URL/health"
elif [ "$1" = "boards" ]; then
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/boards"
elif [ "$1" = "cards" ]; then
    curl -s -m 10 -H "Authorization: Bearer $MC_TOKEN" "$MC_URL/api/v1/boards/${2:-agent-security-framework}/cards"
elif [ "$1" = "update-card" ]; then
    curl -s -m 10 -X PATCH -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/cards/$2"
elif [ "$1" = "create-card" ]; then
    curl -s -m 10 -X POST -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$3" "$MC_URL/api/v1/boards/${2:-agent-security-framework}/cards"
else
    # Raw API call: mc-api.sh GET /api/v1/boards
    METHOD="${1:-GET}"
    ENDPOINT="$2"
    BODY="$3"
    if [ -n "$BODY" ]; then
        curl -s -m 10 -X "$METHOD" -H "Authorization: Bearer $MC_TOKEN" -H "Content-Type: application/json" -d "$BODY" "$MC_URL$ENDPOINT"
    else
        curl -s -m 10 -X "$METHOD" -H "Authorization: Bearer $MC_TOKEN" "$MC_URL$ENDPOINT"
    fi
fi
'''
    r = subprocess.run(
        ["docker", "exec", "openclaw-gateway", "sh", "-c",
         f"cat > {ws}/mc-api.sh << 'SCRIPTEOF'\n{script}\nSCRIPTEOF\nchmod +x {ws}/mc-api.sh && echo OK"],
        capture_output=True, text=True, timeout=5
    )
    log(f"  Script {ws}/mc-api.sh: {r.stdout.strip()}")

# 2. Update HEARTBEAT.md with simpler instructions
heartbeat = r'''# HEARTBEAT - Raven (Product Owner)

## CRITICAL: You are INSIDE Docker
- Do NOT run `docker exec` — you are already inside the container
- Do NOT run `docker` — it is not available
- Use the `exec` tool with shell commands directly

## Mission Control API Access

Use the helper script for ALL MC API calls:

```bash
# Health check
./mc-api.sh health

# List boards  
./mc-api.sh boards

# List cards on ASF board
./mc-api.sh cards agent-security-framework

# Update a card
./mc-api.sh update-card CARD_ID '{"status":"done"}'

# Create a card
./mc-api.sh create-card agent-security-framework '{"title":"New task","description":"Details"}'

# Raw API call
./mc-api.sh GET /api/v1/boards
./mc-api.sh PATCH /api/v1/cards/CARD_ID '{"status":"in_progress"}'
```

### IMPORTANT: Do NOT manually construct curl commands with the token.
### The token has special characters. Always use `./mc-api.sh` instead.

### If mc-api.sh is not found, use this exact command (token is in .mc-token file):
```bash
TOKEN=$(cat .mc-token)
curl -s -H "Authorization: Bearer $TOKEN" http://host.docker.internal:8001/api/v1/boards
```

## Pre-flight check
1. `cd /workspace/agents/product-owner`
2. `./mc-api.sh health` → should return `{"ok":true}`
3. `./mc-api.sh boards` → should return board list
4. If both succeed, proceed with tasks
'''

tools = r'''# TOOLS - Mission Control API

## You are inside Docker. Use `exec` tool with shell commands.

## Quick Reference
```bash
cd /workspace/agents/product-owner
./mc-api.sh health              # Health check
./mc-api.sh boards              # List all boards
./mc-api.sh cards               # Cards on ASF board
./mc-api.sh cards BOARD_SLUG    # Cards on specific board
./mc-api.sh update-card ID '{"status":"done"}'
./mc-api.sh create-card SLUG '{"title":"Task"}'
./mc-api.sh GET /api/v1/boards  # Raw GET
./mc-api.sh PATCH /api/v1/cards/ID '{"field":"value"}'  # Raw PATCH
```

## NEVER manually type the auth token in curl commands.
## ALWAYS use ./mc-api.sh or read token from .mc-token file.

## MC Base URL: http://host.docker.internal:8001
## API Docs: http://host.docker.internal:8001/docs
'''

for ws in [
    "/workspace/agents/product-owner",
    "/workspace/workspace-mc-3634c19a-9174-4f23-b03a-0d451f5de6be"
]:
    for filename, content in [("HEARTBEAT.md", heartbeat), ("TOOLS.md", tools)]:
        r = subprocess.run(
            ["docker", "exec", "openclaw-gateway", "sh", "-c",
             f"cat > {ws}/{filename} << 'DOCEOF'\n{content}\nDOCEOF"],
            capture_output=True, text=True, timeout=5
        )
        log(f"  {ws}/{filename}: rc={r.returncode}")

# 3. Test the helper script works
log("\n--- Testing mc-api.sh ---")
r = subprocess.run(
    ["docker", "exec", "-u", "1000", "openclaw-gateway", "sh", "-c",
     "cd /workspace/agents/product-owner && ./mc-api.sh health"],
    capture_output=True, text=True, timeout=10
)
log(f"  health: {r.stdout.strip()}")

r = subprocess.run(
    ["docker", "exec", "-u", "1000", "openclaw-gateway", "sh", "-c",
     "cd /workspace/agents/product-owner && ./mc-api.sh boards | head -c 200"],
    capture_output=True, text=True, timeout=10
)
log(f"  boards: {r.stdout.strip()[:200]}")

# 4. Test from MC Raven workspace too
r = subprocess.run(
    ["docker", "exec", "-u", "1000", "openclaw-gateway", "sh", "-c",
     "cd /workspace/workspace-mc-3634c19a-9174-4f23-b03a-0d451f5de6be && ./mc-api.sh health"],
    capture_output=True, text=True, timeout=10
)
log(f"  MC workspace health: {r.stdout.strip()}")

log("\n=== ALL FIXES APPLIED ===")
log("Raven should use ./mc-api.sh for all MC access.")
log("Token is stored in .mc-token file (no quoting issues).")
f.close()

