#!/usr/bin/env python3
"""
Fix Raven's model to use Gemini 3 Flash (higher free-tier limits) as primary,
with Gemini 3 Pro as fallback.

Gemini 3 Pro Preview has very low free-tier RPM (5 RPM / 250k TPM).
Gemini 3 Flash Preview has much higher free-tier limits.

Run: python3 fix-raven-model-flash-primary.py
Then: cd /Users/jeffsutherland/clawd/ASF-15-docker
      docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
"""

import json
import os
import subprocess

CONFIG_PATH = "/Users/jeffsutherland/clawd/ASF-15-docker/openclaw-state/openclaw.json"

# Raven agent IDs (both the direct agent and the MC-mapped agent)
RAVEN_AGENT_IDS = [
    "product-owner",
    "mc-3634c19a-9174-4f23-b03a-0d451f5de6be"
]

def main():
    with open(CONFIG_PATH) as f:
        cfg = json.load(f)

    # Step 1: Swap primary/fallback for Raven agents
    # Flash as primary (higher free-tier limits), Pro as fallback
    for agent in cfg["agents"]["list"]:
        if agent.get("id") in RAVEN_AGENT_IDS:
            agent["model"] = {
                "primary": "google/gemini-3-flash-preview",
                "fallbacks": ["google/gemini-3-pro-preview"]
            }
            name = agent.get("name", agent["id"])
            print(f"  {agent['id']} ({name}): primary=google/gemini-3-flash-preview, fallback=google/gemini-3-pro-preview")

    # Save
    with open(CONFIG_PATH, "w") as f:
        json.dump(cfg, f, indent=2)
    print(f"\nConfig saved: {CONFIG_PATH} ({os.path.getsize(CONFIG_PATH)} bytes)")

    # Step 2: Copy to container
    try:
        subprocess.run([
            "docker", "cp", CONFIG_PATH,
            "openclaw-gateway:/home/node/.openclaw/openclaw.json"
        ], check=True, capture_output=True)
        print("Config copied to container")
    except Exception as e:
        print(f"Warning: Could not copy to container: {e}")
        print("  Copy manually or restart the container (it mounts the state dir)")

    # Verify
    print("\n=== VERIFICATION ===")
    with open(CONFIG_PATH) as f:
        d = json.load(f)
    print(f"Default primary: {d['agents']['defaults']['model']['primary']}")
    for a in d["agents"]["list"]:
        if a.get("id") in RAVEN_AGENT_IDS:
            m = a.get("model", {})
            print(f"  {a['id']}: primary={m.get('primary','DEFAULT')}, fallbacks={m.get('fallbacks','NONE')}")

    print("\nDONE! Restart gateway to apply:")
    print("  cd /Users/jeffsutherland/clawd/ASF-15-docker")
    print("  docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw")

if __name__ == "__main__":
    main()

