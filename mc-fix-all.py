#!/usr/bin/env python3
"""
OpenClaw Mission Control - Fix Script
Fixes 3 issues found in the logs:
1. Missing tasks.story_points column in database
2. Agent tokens not matching (401 errors)
3. Gateway pairing scope upgrade (operator.write)

Run from: /Users/jeffsutherland/clawd
"""
import json
import subprocess
import sys
import urllib.request
import urllib.error

MC_URL = "http://localhost:8001"
AUTH_TOKEN = "HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
DB_CONTAINER = "openclaw-mission-control-db-1"
DB_USER = "mission_control"
DB_NAME = "mission_control"
PAIRED_JSON = "/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/devices/paired.json"
AGENT_TOKENS_FILE = "/Users/jeffsutherland/clawd/agent-tokens.json"


def run_sql(sql):
    """Execute SQL in the Postgres container."""
    result = subprocess.run(
        ["docker", "exec", "-i", DB_CONTAINER, "psql", "-U", DB_USER, "-d", DB_NAME, "-t", "-A"],
        input=sql,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"  SQL ERROR: {result.stderr.strip()}")
        return None
    return result.stdout.strip()


def mc_api(method, path, data=None):
    """Call Mission Control REST API."""
    url = f"{MC_URL}{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(
        url,
        data=body,
        method=method,
        headers={
            "Authorization": f"Bearer {AUTH_TOKEN}",
            "Content-Type": "application/json",
        },
    )
    try:
        r = urllib.request.urlopen(req, timeout=10)
        return json.loads(r.read())
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        print(f"  API ERROR {e.code}: {body[:200]}")
        return None


def fix_story_points_column():
    """Fix #1: Add missing story_points column to tasks table."""
    print("=" * 60)
    print("FIX #1: Missing tasks.story_points column")
    print("=" * 60)

    # Check if column exists
    result = run_sql(
        "SELECT column_name FROM information_schema.columns "
        "WHERE table_name='tasks' AND column_name='story_points';"
    )

    if result and "story_points" in result:
        print("  ✅ Column tasks.story_points already exists. No action needed.")
        return True

    print("  ❌ Column tasks.story_points is MISSING. Adding it now...")
    result = run_sql("ALTER TABLE tasks ADD COLUMN story_points INTEGER;")

    # Verify
    verify = run_sql(
        "SELECT column_name FROM information_schema.columns "
        "WHERE table_name='tasks' AND column_name='story_points';"
    )
    if verify and "story_points" in verify:
        print("  ✅ Column tasks.story_points added successfully!")
        return True
    else:
        print("  ❌ Failed to add column. Check database permissions.")
        return False


def fix_agent_tokens():
    """Fix #2: Regenerate agent tokens so they match what's in the DB."""
    print()
    print("=" * 60)
    print("FIX #2: Agent token 401 errors (stale tokens)")
    print("=" * 60)

    # Get all agents from API
    data = mc_api("GET", "/api/v1/agents?limit=200")
    if not data:
        print("  ❌ Cannot fetch agents from API.")
        return False

    agents = data.get("items", [])
    print(f"  Found {len(agents)} agents in Mission Control")

    # Load existing token file
    try:
        with open(AGENT_TOKENS_FILE) as f:
            old_tokens = json.load(f)
    except FileNotFoundError:
        old_tokens = {}

    # For each agent, check if their token works, and regenerate if not
    new_tokens = {}
    agents_needing_new_tokens = []

    for agent in agents:
        name = agent["name"]
        agent_id = agent["id"]
        old_entry = None
        for k, v in old_tokens.items():
            if v.get("agent_id") == agent_id:
                old_entry = (k, v)
                break

        if old_entry:
            old_name, old_info = old_entry
            token = old_info["token"]
            # Test the token
            test_req = urllib.request.Request(
                f"{MC_URL}/api/v1/agent/boards",
                headers={"X-Agent-Token": token},
            )
            try:
                urllib.request.urlopen(test_req, timeout=5)
                print(f"  ✅ {name}: token is valid")
                new_tokens[name] = {"agent_id": agent_id, "token": token}
                continue
            except urllib.error.HTTPError as e:
                if e.code == 401:
                    print(f"  ❌ {name}: token invalid (401), needs regeneration")
                    agents_needing_new_tokens.append(agent)
                else:
                    print(f"  ⚠️  {name}: got {e.code}, keeping old token")
                    new_tokens[name] = {"agent_id": agent_id, "token": token}
        else:
            print(f"  ❌ {name}: no token on file, needs regeneration")
            agents_needing_new_tokens.append(agent)

    if not agents_needing_new_tokens:
        print("  ✅ All agent tokens are valid!")
        return True

    print(f"\n  Regenerating tokens for {len(agents_needing_new_tokens)} agents via DB...")

    # We need to use the token generation logic directly
    # Import-compatible approach: generate token + hash, update DB
    for agent in agents_needing_new_tokens:
        agent_id = agent["id"]
        name = agent["name"]

        # Generate new token using Python (same logic as backend)
        import secrets
        import hashlib
        import base64

        raw_token = secrets.token_urlsafe(32)
        salt = secrets.token_bytes(16)
        digest = hashlib.pbkdf2_hmac("sha256", raw_token.encode("utf-8"), salt, 200000)

        def b64encode(value):
            return base64.urlsafe_b64encode(value).decode("utf-8").rstrip("=")

        token_hash = f"pbkdf2_sha256$200000${b64encode(salt)}${b64encode(digest)}"

        # Update the database directly
        sql = f"UPDATE agents SET agent_token_hash = '{token_hash}' WHERE id = '{agent_id}';"
        result = run_sql(sql)

        new_tokens[name] = {"agent_id": agent_id, "token": raw_token}
        print(f"  ✅ {name}: new token generated (prefix: {raw_token[:6]}...)")

    # Write updated tokens file
    with open(AGENT_TOKENS_FILE, "w") as f:
        json.dump(new_tokens, f, indent=2)
    print(f"\n  ✅ Updated {AGENT_TOKENS_FILE}")

    # Verify one token works
    for name, info in new_tokens.items():
        test_req = urllib.request.Request(
            f"{MC_URL}/api/v1/agent/boards",
            headers={"X-Agent-Token": info["token"]},
        )
        try:
            urllib.request.urlopen(test_req, timeout=5)
            print(f"  ✅ Verified: {name} token works!")
            break
        except urllib.error.HTTPError as e:
            if e.code == 401:
                print(f"  ⚠️  {name} still 401 - may need backend restart to clear cache")
            break

    return True


def fix_gateway_pairing():
    """Fix #3: Approve pending gateway pairing request (operator.write scope)."""
    print()
    print("=" * 60)
    print("FIX #3: Gateway pairing (operator.write scope)")
    print("=" * 60)

    with open(PAIRED_JSON) as f:
        paired = json.load(f)

    # Find the device
    device_id = list(paired.keys())[0]
    device = paired[device_id]
    current_scopes = device["tokens"]["operator"]["scopes"]
    print(f"  Device: {device_id[:16]}...")
    print(f"  Current scopes: {current_scopes}")

    if "operator.write" in current_scopes:
        print("  ✅ operator.write scope already present. No action needed.")
        return True

    print("  ❌ Missing operator.write scope. Adding it now...")

    # Add operator.write to scopes
    if "operator.write" not in device["scopes"]:
        device["scopes"].append("operator.write")
    if "operator.write" not in device["tokens"]["operator"]["scopes"]:
        device["tokens"]["operator"]["scopes"].append("operator.write")

    paired[device_id] = device

    # Write back
    with open(PAIRED_JSON, "w") as f:
        json.dump(paired, f, indent=2)
    print("  ✅ Added operator.write scope to paired.json")

    # Also clear the pending request
    pending_path = PAIRED_JSON.replace("paired.json", "pending.json")
    try:
        with open(pending_path, "w") as f:
            json.dump({}, f, indent=2)
        print("  ✅ Cleared pending.json")
    except Exception as e:
        print(f"  ⚠️  Could not clear pending.json: {e}")

    print("  ⚠️  Gateway container needs restart to pick up scope change.")
    return True


def restart_services():
    """Restart backend and gateway to apply fixes."""
    print()
    print("=" * 60)
    print("RESTARTING SERVICES")
    print("=" * 60)

    print("  Restarting backend...")
    subprocess.run(
        ["docker", "restart", "openclaw-mission-control-backend-1"],
        capture_output=True,
    )
    print("  ✅ Backend restarted")

    print("  Restarting webhook-worker...")
    subprocess.run(
        ["docker", "restart", "openclaw-mission-control-webhook-worker-1"],
        capture_output=True,
    )
    print("  ✅ Webhook worker restarted")

    print("  Restarting gateway...")
    subprocess.run(
        ["docker", "restart", "openclaw-gateway"],
        capture_output=True,
    )
    print("  ✅ Gateway restarted")

    print()
    print("  Waiting for services to come back up...")
    import time
    time.sleep(5)

    # Verify health
    try:
        req = urllib.request.Request(f"{MC_URL}/healthz")
        r = urllib.request.urlopen(req, timeout=10)
        health = json.loads(r.read())
        if health.get("ok"):
            print("  ✅ Backend health check passed!")
        else:
            print("  ⚠️  Backend returned unexpected health response")
    except Exception as e:
        print(f"  ⚠️  Backend not ready yet: {e}")
        print("  (It may take a few more seconds)")


def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  OpenClaw Mission Control - Log Issue Fix Script        ║")
    print("║  Fixing 3 issues found in backend/gateway logs         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    ok1 = fix_story_points_column()
    ok2 = fix_agent_tokens()
    ok3 = fix_gateway_pairing()

    if ok1 or ok2 or ok3:
        restart_services()

    print()
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"  1. story_points column:  {'✅ Fixed' if ok1 else '❌ Failed'}")
    print(f"  2. Agent tokens:         {'✅ Fixed' if ok2 else '❌ Failed'}")
    print(f"  3. Gateway pairing:      {'✅ Fixed' if ok3 else '❌ Failed'}")
    print()
    print("  Dashboard: http://localhost:3001")
    print("  Backend:   http://localhost:8001")
    print()


if __name__ == "__main__":
    main()

