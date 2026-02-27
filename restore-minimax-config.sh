#!/bin/bash
# Restore script for Minimax configuration
# Usage: ./restore-minimax-config.sh [TIMESTAMP]
# If no timestamp provided, restores latest backup

BACKUP_DIR="$HOME/clawd/config-backups"

if [ -z "$1" ]; then
  # Find latest backup
  TIMESTAMP=$(ls -t "$BACKUP_DIR"/clawdbot.json.* | grep -v latest | head -1 | sed 's/.*\.//')
  echo "📅 No timestamp provided, using latest: $TIMESTAMP"
else
  TIMESTAMP="$1"
fi

if [ ! -f "$BACKUP_DIR/clawdbot.json.$TIMESTAMP" ]; then
  echo "❌ Error: Backup not found for timestamp $TIMESTAMP"
  echo "Available backups:"
  ls -1 "$BACKUP_DIR"/clawdbot.json.* | grep -v latest
  exit 1
fi

echo "🔄 Restoring Minimax configuration from $TIMESTAMP..."

# Stop services
echo "  🛑 Stopping services..."
pkill -f clawdbot
docker stop openclaw-gateway 2>/dev/null

sleep 2

# Restore clawdbot config
echo "  📋 Restoring clawdbot main config..."
cp "$BACKUP_DIR/clawdbot.json.$TIMESTAMP" ~/.clawdbot/clawdbot.json

# Restore clawdbot agent auth profiles and models
for agent in main research social deploy sales product-owner; do
  echo "  🔐 Restoring $agent auth-profiles.json..."
  if [ -f "$BACKUP_DIR/clawdbot-agents/$agent/auth-profiles.json.$TIMESTAMP" ]; then
    cp "$BACKUP_DIR/clawdbot-agents/$agent/auth-profiles.json.$TIMESTAMP" ~/.clawdbot/agents/$agent/agent/auth-profiles.json
  fi

  echo "  📊 Restoring $agent models.json..."
  if [ -f "$BACKUP_DIR/clawdbot-agents/$agent/models.json.$TIMESTAMP" ]; then
    cp "$BACKUP_DIR/clawdbot-agents/$agent/models.json.$TIMESTAMP" ~/.clawdbot/agents/$agent/agent/models.json
  fi
done

# Restore OpenClaw config
echo "  📋 Restoring OpenClaw config..."
cp "$BACKUP_DIR/openclaw.json.$TIMESTAMP" ~/clawd/ASF-15-docker/openclaw-state/openclaw.json

# Restore OpenClaw auth profiles
echo "  🔐 Restoring OpenClaw auth profiles..."
if [ -d "$BACKUP_DIR/openclaw-auth-profiles" ]; then
  cp "$BACKUP_DIR/openclaw-auth-profiles"/*.json ~/clawd/ASF-15-docker/openclaw-state/auth-profiles/ 2>/dev/null
fi

# Restart services
echo "  🚀 Restarting services..."
docker start openclaw-gateway 2>/dev/null

echo "✅ Restore complete!"
echo "📝 Restored from: $TIMESTAMP"
echo ""
echo "Clawdbot will auto-start. Check logs with: tail -f ~/.clawdbot/logs/gateway.log"
