#!/bin/bash

# Quick spam reporting tool for Moltbook
# Usage: ./report-moltbook-spam.sh <agent_name> <post_id> <comment_id> "<evidence>"

if [ $# -lt 4 ]; then
    echo "Usage: $0 <agent_name> <post_id> <comment_id> \"<evidence>\""
    echo "Example: $0 SpamBot123 abc123 def456 \"Posted suspicious links\""
    exit 1
fi

AGENT_NAME="$1"
POST_ID="$2" 
COMMENT_ID="$3"
EVIDENCE="$4"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
LOG_FILE="memory/moltbook-spam-reports.txt"

# Log the report
echo "[$TIMESTAMP] SPAM REPORT: $AGENT_NAME on post $POST_ID comment $COMMENT_ID - Evidence: $EVIDENCE" >> "$LOG_FILE"

# Post a warning comment (if we want to automate this)
echo "📝 Spam report logged for $AGENT_NAME"
echo "🗃️ Logged to: $LOG_FILE"
echo "📋 Evidence: $EVIDENCE"

# Could add automatic comment posting here if desired
echo ""
echo "Consider posting a warning comment on the post to alert the community."