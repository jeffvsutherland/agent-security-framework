#!/bin/bash
# Restore the last known working MiniMax configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$DOCKER_DIR/openclaw-state/openclaw.json"
GOLDEN_DIR="$DOCKER_DIR/golden-configs"
BACKUP_DIR="$DOCKER_DIR/openclaw-state/backups"

mkdir -p "$BACKUP_DIR"

if [ ! -f "$GOLDEN_DIR/openclaw.json" ]; then
    echo "❌ No golden config found at: $GOLDEN_DIR/openclaw.json"
    echo ""
    echo "Create one first with:"
    echo "  bash $SCRIPT_DIR/save-golden-config.sh"
    exit 1
fi

echo "🔄 Restoring Golden Config..."
echo ""

# Backup current broken config
BACKUP_FILE="$BACKUP_DIR/openclaw.json.broken.$(date +%Y%m%d-%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "📦 Current config backed up to: $BACKUP_FILE"
echo ""

# Restore main config
cp "$GOLDEN_DIR/openclaw.json" "$CONFIG_FILE"
echo "✅ Main config restored"

# Restore auth profiles
AUTH_DIR="$GOLDEN_DIR/auth-profiles"
if [ -d "$AUTH_DIR" ]; then
    for auth_backup in "$AUTH_DIR"/*.json; do
        agent_name=$(basename "$auth_backup" .json)
        agent_dir="$DOCKER_DIR/openclaw-state/agents/$agent_name"

        if [ -d "$agent_dir" ]; then
            cp "$auth_backup" "$agent_dir/agent/auth-profiles.json"
            echo "✅ Restored auth for: $agent_name"
        fi
    done
fi

echo ""
echo "✅ Golden config restored!"
echo ""
echo "Restart OpenClaw:"
echo "  cd $DOCKER_DIR"
echo "  docker compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw"
