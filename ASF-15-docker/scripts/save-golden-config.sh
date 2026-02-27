#!/bin/bash
# Save current working MiniMax config as "golden" reference
# Run this when everything is working correctly

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$DOCKER_DIR/openclaw-state/openclaw.json"
GOLDEN_DIR="$DOCKER_DIR/golden-configs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$GOLDEN_DIR"

echo "💾 Saving Golden Config..."
echo ""

# Validate first
"$SCRIPT_DIR/minimax-health-check.sh" || {
    echo ""
    echo "❌ Current config has issues. Fix them first before saving as golden."
    exit 1
}

# Save main config
cp "$CONFIG_FILE" "$GOLDEN_DIR/openclaw.json"
cp "$CONFIG_FILE" "$GOLDEN_DIR/openclaw.json.$TIMESTAMP"

# Save all auth profiles
AUTH_DIR="$GOLDEN_DIR/auth-profiles"
mkdir -p "$AUTH_DIR"

for agent_dir in "$DOCKER_DIR"/openclaw-state/agents/*/; do
    agent_name=$(basename "$agent_dir")
    auth_file="$agent_dir/agent/auth-profiles.json"

    if [ -f "$auth_file" ]; then
        cp "$auth_file" "$AUTH_DIR/$agent_name.json"
    fi
done

# Save docker-compose env vars
grep -A2 "ANTHROPIC" "$DOCKER_DIR/docker-compose.yml" > "$GOLDEN_DIR/anthropic-env.txt"

echo "✅ Golden config saved!"
echo ""
echo "Saved to: $GOLDEN_DIR/"
echo "  - openclaw.json (latest)"
echo "  - openclaw.json.$TIMESTAMP (timestamped)"
echo "  - auth-profiles/ (all agents)"
echo "  - anthropic-env.txt (env vars)"
echo ""
echo "To restore: bash $SCRIPT_DIR/restore-golden-config.sh"
