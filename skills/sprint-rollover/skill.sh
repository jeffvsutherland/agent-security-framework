#!/bin/bash
#===============================================================================
# Sprint Rollover — Executable wrapper for the sprint-rollover skill
# Called by clawdbot cron at 23:59 nightly
#
# This script can run standalone on the host or inside Docker via:
#   docker exec openclaw-gateway /workspace/skills/sprint-rollover/skill.sh
#===============================================================================

set -euo pipefail

WORKSPACE="${WORKSPACE:-/Users/jeffsutherland/clawd}"
REPORT_DIR="${WORKSPACE}/reports"
BACKLOG_FILE="${WORKSPACE}/SECURITY_FRAMEWORK_BACKLOG.md"
BUILD_LOG="${REPORT_DIR}/DAILY_BUILD_LOG.md"
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S ET')

mkdir -p "$REPORT_DIR"

echo "🔄 Sprint Rollover — $TIMESTAMP"

# --- Step 1: Read Board State ---
echo "📋 Reading board state..."
MC_API=""
if [ -x "/workspace/.mc-api-backup" ]; then
    MC_API="/workspace/.mc-api-backup"
elif command -v mc-api &>/dev/null; then
    MC_API="mc-api"
fi

TASKS_JSON=""
if [ -n "$MC_API" ]; then
    MC_HEALTH=$($MC_API health 2>&1 || true)
    if echo "$MC_HEALTH" | grep -q '"ok":true'; then
        echo "  ✅ Mission Control connected"
        TASKS_JSON=$($MC_API tasks 2>&1 || true)
    else
        echo "  ⚠️  Mission Control offline — filesystem-only mode"
    fi
else
    echo "  ⚠️  mc-api not found — filesystem-only mode"
fi

# --- Step 2: Compile Daily Report ---
echo "📝 Compiling daily report..."

{
    echo ""
    echo "## $DATE — Sprint Rollover Summary"
    echo ""
    echo "**Timestamp:** $TIMESTAMP"
    echo ""

    if [ -n "$TASKS_JSON" ]; then
        echo "### Completed Tasks"
        echo "$TASKS_JSON" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tasks = data if isinstance(data, list) else data.get('tasks', data.get('cards', []))
    done = [t for t in tasks if t.get('column','').lower() in ('done','completed')]
    if done:
        for t in done:
            print(f\"- [{t.get('id','?')}] {t.get('title','Untitled')}\")
    else:
        print('- (No completed tasks)')
except:
    print('- (Could not parse board state)')
" 2>/dev/null || echo "- (Could not parse board state)"
        echo ""
        echo "### Rolled Over (In Progress)"
        echo "$TASKS_JSON" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    tasks = data if isinstance(data, list) else data.get('tasks', data.get('cards', []))
    wip = [t for t in tasks if t.get('column','').lower() in ('in progress','in review','doing')]
    if wip:
        for t in wip:
            print(f\"- [{t.get('id','?')}] {t.get('title','Untitled')} — rolled over\")
    else:
        print('- (None)')
except:
    print('- (Could not parse board state)')
" 2>/dev/null || echo "- (Could not parse board state)"
    else
        echo "### Completed Tasks"
        echo "- (Mission Control offline — no board data)"
        echo ""
        echo "### Rolled Over"
        echo "- (Mission Control offline — no board data)"
    fi

    echo ""
    echo "---"
} >> "$BUILD_LOG"

echo "  💾 Appended to $BUILD_LOG"

# --- Step 3–5: Board operations (require mc-api) ---
if [ -n "$MC_API" ] && [ -n "$TASKS_JSON" ]; then
    echo "🗂️  Archiving done tasks and tagging rollovers..."
    # These operations are handled by the agent reading this skill.
    # The agent will use mc-api commands from skill.md steps 3-5.
    echo "  (Board operations delegated to agent execution)"
fi

# --- Step 6: Summary ---
echo ""
echo "✅ Sprint rollover complete — $TIMESTAMP"
echo "   Report: $BUILD_LOG"

