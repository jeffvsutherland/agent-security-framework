#!/bin/bash
# Backup script for Minimax configuration
# Run this after any configuration changes to ensure persistence across reboots

BACKUP_DIR="$HOME/clawd/config-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "🔄 Backing up Minimax configuration..."

# Backup clawdbot config
echo "  📋 Backing up clawdbot main config..."
cp ~/.clawdbot/clawdbot.json "$BACKUP_DIR/clawdbot.json.$TIMESTAMP"

# Backup clawdbot agent auth profiles
for agent in main research social deploy sales product-owner; do
  echo "  🔐 Backing up $agent auth-profiles.json..."
  mkdir -p "$BACKUP_DIR/clawdbot-agents/$agent"
  cp ~/.clawdbot/agents/$agent/agent/auth-profiles.json "$BACKUP_DIR/clawdbot-agents/$agent/auth-profiles.json.$TIMESTAMP"

  echo "  📊 Backing up $agent models.json..."
  if [ -f ~/.clawdbot/agents/$agent/agent/models.json ]; then
    cp ~/.clawdbot/agents/$agent/agent/models.json "$BACKUP_DIR/clawdbot-agents/$agent/models.json.$TIMESTAMP"
  fi
done

# Backup OpenClaw config (from Docker volume mount)
echo "  📋 Backing up OpenClaw config..."
cp ~/clawd/ASF-15-docker/openclaw-state/openclaw.json "$BACKUP_DIR/openclaw.json.$TIMESTAMP"

# Backup OpenClaw auth profiles
echo "  🔐 Backing up OpenClaw auth profiles..."
mkdir -p "$BACKUP_DIR/openclaw-auth-profiles"
cp ~/clawd/ASF-15-docker/openclaw-state/auth-profiles/*.json "$BACKUP_DIR/openclaw-auth-profiles/" 2>/dev/null

# Create latest symlinks
ln -sf "clawdbot.json.$TIMESTAMP" "$BACKUP_DIR/clawdbot.json.latest"
ln -sf "openclaw.json.$TIMESTAMP" "$BACKUP_DIR/openclaw.json.latest"

echo "✅ Backup complete: $BACKUP_DIR"
echo "📝 Timestamp: $TIMESTAMP"
echo ""
echo "To restore, run: ./restore-minimax-config.sh $TIMESTAMP"
