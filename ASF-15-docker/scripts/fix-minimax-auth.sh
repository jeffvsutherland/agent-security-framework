#!/bin/bash
# Fix MiniMax auth profiles to use 'anthropic' provider type
# This is needed because MiniMax uses Anthropic-compatible API

set -e

cd /Users/jeffsutherland/clawd/ASF-15-docker

echo "🔧 Fixing MiniMax auth profiles for all agents..."
echo ""

python3 << 'PYEOF'
import json
import glob

# Update all agent auth profiles
auth_files = glob.glob("openclaw-state/agents/*/agent/auth-profiles.json")

for auth_file in auth_files:
    try:
        with open(auth_file) as f:
            auth = json.load(f)

        profiles = auth.get("profiles", {})
        changed = False

        for profile_id, profile_data in profiles.items():
            if "minimax" in profile_id.lower() or profile_data.get("provider") == "minimax":
                # Change provider from "minimax" to "anthropic"
                profile_data["provider"] = "anthropic"
                changed = True
                agent_name = auth_file.split('/')[-3]
                print(f"✅ {agent_name}: {profile_id} -> anthropic provider")

        if changed:
            with open(auth_file, "w") as f:
                json.dump(auth, f, indent=2)

    except Exception as e:
        print(f"⚠️  Error: {auth_file}: {e}")

print("\n✅ All auth profiles updated")
PYEOF

echo ""
echo "🔄 Restarting OpenClaw to apply changes..."
docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw

echo ""
echo "✅ Done! All agents now use MiniMax with correct provider type."
echo ""
echo "Test with: Send a message to any agent via Telegram"
