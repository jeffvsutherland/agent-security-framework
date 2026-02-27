#!/bin/bash
# Validate MiniMax Configuration Before Starting OpenClaw
# Run this before: docker compose up -d

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$DOCKER_DIR/openclaw-state/openclaw.json"

echo "🔍 Pre-Start Validation..."

# Run health check in non-interactive mode
"$SCRIPT_DIR/minimax-health-check.sh" || {
    echo ""
    echo "❌ Validation failed! Config has issues."
    echo ""
    echo "Run this to fix:"
    echo "  bash $SCRIPT_DIR/fix-minimax-auth.sh"
    echo ""
    exit 1
}

echo ""
echo "✅ Validation passed! Safe to start."
