#!/usr/bin/env bash

# report-moltbook-spam-simple.sh - Simplified Spam Reporting (No SQLite Required)
# Part of Agent Security Framework (ASF)
# Version: 1.0.0

set -euo pipefail

# Configuration
REPORT_DIR="${SPAM_REPORT_DIR:-$HOME/.asf/spam-reports}"
LOG_FILE="${SPAM_LOG_FILE:-$HOME/.asf/spam-reports.log}"
EVIDENCE_DIR="${EVIDENCE_DIR:-$HOME/.asf/evidence}"
BAD_ACTORS_JSON="${BAD_ACTORS_JSON:-$HOME/.asf/bad-actors.json}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize directories and files
init_infrastructure() {
    mkdir -p "$REPORT_DIR" "$EVIDENCE_DIR" "$(dirname "$BAD_ACTORS_JSON")"
    touch "$LOG_FILE"
    
    # Initialize bad actors JSON if it doesn't exist
    if [[ ! -f "$BAD_ACTORS_JSON" ]]; then
        cat > "$BAD_ACTORS_JSON" <<EOF
{
    "version": "1.0",
    "created": "$(date -Iseconds)",
    "actors": {},
    "reports": []
}
EOF
        echo -e "${GREEN}[+] Initialized bad actors database (JSON mode)${NC}"
    fi
}

# Generate unique report ID
generate_report_id() {
    echo "SPM-$(date +%Y%m%d)-$(head -c 4 /dev/urandom | od -An -tx1 | tr -d ' \n' | tr '[:lower:]' '[:upper:]')"
}

# Log action with timestamp
log_action() {
    local action="$1"
    local details="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S UTC' -u)
    
    echo "[$timestamp] $action${details:+: $details}" >> "$LOG_FILE"
    echo -e "${BLUE}[LOG]${NC} $action${details:+: $details}"
}

# Collect evidence
collect_evidence() {
    local username="$1"
    local report_id="$2"
    local evidence_type="${3:-screenshot}"
    
    local evidence_subdir="$EVIDENCE_DIR/$report_id"
    mkdir -p "$evidence_subdir"
    
    case "$evidence_type" in
        screenshot)
            echo -e "${YELLOW}[!] Please capture screenshot evidence and save to:${NC}"
            echo "    $evidence_subdir/screenshot.png"
            echo ""
            echo "    Tips for good evidence:"
            echo "    - Include the spam content"
            echo "    - Show username clearly"
            echo "    - Include timestamp if visible"
            ;;
        profile)
            echo -e "${YELLOW}[!] Collecting profile data for $username...${NC}"
            # Create a template for manual profile data entry
            cat > "$evidence_subdir/profile.json" <<EOF
{
    "username": "$username",
    "collected_at": "$(date -Iseconds)",
    "profile_data": {
        "user_id": "TODO: Add if known",
        "display_name": "TODO: Add display name",
        "bio": "TODO: Add bio content",
        "follower_count": "TODO: Add count",
        "following_count": "TODO: Add count",
        "created_date": "TODO: Add if visible"
    },
    "notes": "TODO: Add any relevant observations"
}
EOF
            echo "    Profile template created at: $evidence_subdir/profile.json"
            echo "    Please fill in the TODO fields with actual data"
            ;;
        messages)
            echo -e "${YELLOW}[!] Please export spam messages and save to:${NC}"
            echo "    $evidence_subdir/messages.txt"
            echo ""
            echo "    Include:"
            echo "    - Full message text"
            echo "    - Timestamps"
            echo "    - Any links or attachments mentioned"
            ;;
        *)
            echo -e "${RED}[!] Unknown evidence type: $evidence_type${NC}"
            return 1
            ;;
    esac
    
    echo "$evidence_subdir"
}

# Update bad actors in JSON
update_bad_actors_json() {
    local username="$1"
    local report_id="$2"
    local user_id="${3:-unknown}"
    local description="${4:-}"
    
    local tmp_file=$(mktemp)
    
    # Update the JSON file using jq (or python if jq not available)
    if command -v jq &> /dev/null; then
        jq --arg user "$username" \
           --arg rid "$report_id" \
           --arg uid "$user_id" \
           --arg desc "$description" \
           --arg ts "$(date -Iseconds)" '
            .actors[$user] = (.actors[$user] // {
                "username": $user,
                "user_id": $uid,
                "first_reported": $ts,
                "report_count": 0,
                "report_ids": []
            }) |
            .actors[$user].report_count += 1 |
            .actors[$user].last_reported = $ts |
            .actors[$user].report_ids += [$rid] |
            if .actors[$user].user_id == "unknown" and $uid != "unknown" then
                .actors[$user].user_id = $uid
            else . end |
            .reports += [{
                "report_id": $rid,
                "username": $user,
                "timestamp": $ts,
                "description": $desc
            }]
        ' "$BAD_ACTORS_JSON" > "$tmp_file"
    else
        # Python fallback if jq is not available
        python3 -c "
import json
import sys

with open('$BAD_ACTORS_JSON', 'r') as f:
    data = json.load(f)

username = '$username'
report_id = '$report_id'
user_id = '$user_id'
description = '''$description'''
timestamp = '$(date -Iseconds)'

if username not in data['actors']:
    data['actors'][username] = {
        'username': username,
        'user_id': user_id,
        'first_reported': timestamp,
        'last_reported': timestamp,
        'report_count': 0,
        'report_ids': []
    }

actor = data['actors'][username]
actor['report_count'] += 1
actor['last_reported'] = timestamp
actor['report_ids'].append(report_id)
if actor['user_id'] == 'unknown' and user_id != 'unknown':
    actor['user_id'] = user_id

data['reports'].append({
    'report_id': report_id,
    'username': username,
    'timestamp': timestamp,
    'description': description
})

with open('$tmp_file', 'w') as f:
    json.dump(data, f, indent=2)
"
    fi
    
    mv "$tmp_file" "$BAD_ACTORS_JSON"
    log_action "Updated bad actor" "$username in JSON database"
}

# File spam report
file_report() {
    local username="$1"
    local report_type="$2"
    local reporter="$3"
    local description="$4"
    local user_id="${5:-unknown}"
    
    local report_id=$(generate_report_id)
    local report_file="$REPORT_DIR/$report_id.json"
    
    log_action "Starting spam report" "$report_id for @$username"
    
    # Collect evidence
    local evidence_path=$(collect_evidence "$username" "$report_id" "screenshot")
    
    # Create report JSON
    cat > "$report_file" <<EOF
{
    "report_id": "$report_id",
    "timestamp": "$(date -Iseconds)",
    "reporter": "$reporter",
    "bad_actor": {
        "username": "$username",
        "user_id": "$user_id",
        "platform": "moltbook"
    },
    "report_type": "$report_type",
    "description": "$description",
    "evidence": {
        "path": "$evidence_path",
        "collected": false
    },
    "status": "pending_evidence"
}
EOF
    
    # Update bad actors database
    update_bad_actors_json "$username" "$report_id" "$user_id" "$description"
    
    log_action "Report filed" "$report_id"
    
    echo -e "${GREEN}[+] Spam report created: $report_id${NC}"
    echo -e "${YELLOW}[!] Next steps:${NC}"
    echo "    1. Add screenshot evidence to: $evidence_path/"
    echo "    2. Run: $0 finalize $report_id"
    
    echo "$report_id"
}

# Finalize report after evidence collection
finalize_report() {
    local report_id="$1"
    local report_file="$REPORT_DIR/$report_id.json"
    
    if [[ ! -f "$report_file" ]]; then
        echo -e "${RED}[!] Report not found: $report_id${NC}"
        return 1
    fi
    
    # Check if evidence files exist
    local evidence_path=$(grep -o '"path": "[^"]*"' "$report_file" | cut -d'"' -f4)
    local has_evidence=false
    
    if [[ -d "$evidence_path" ]] && [[ -n "$(ls -A "$evidence_path")" ]]; then
        has_evidence=true
    fi
    
    # Update report status
    local tmp_file=$(mktemp)
    if command -v jq &> /dev/null; then
        jq --arg collected "$has_evidence" '.status = "complete" | .evidence.collected = ($collected == "true")' "$report_file" > "$tmp_file"
    else
        # Simple sed replacement
        sed 's/"status": "pending_evidence"/"status": "complete"/' "$report_file" | \
        sed "s/\"collected\": false/\"collected\": $has_evidence/" > "$tmp_file"
    fi
    mv "$tmp_file" "$report_file"
    
    log_action "Report finalized" "$report_id"
    echo -e "${GREEN}[+] Report $report_id finalized${NC}"
    
    if [[ "$has_evidence" == "false" ]]; then
        echo -e "${YELLOW}[!] Warning: No evidence files found in $evidence_path${NC}"
    fi
}

# Query bad actors
query_bad_actors() {
    local search="${1:-}"
    
    echo -e "${BLUE}=== Bad Actor Database (JSON Mode) ===${NC}"
    
    if command -v jq &> /dev/null; then
        if [[ -n "$search" ]]; then
            jq -r --arg search "$search" '
                .actors | to_entries | 
                map(select(.key | contains($search))) |
                sort_by(.value.last_reported) | reverse |
                .[] | 
                "\(.value.username) - Reports: \(.value.report_count) - Last: \(.value.last_reported)"
            ' "$BAD_ACTORS_JSON"
        else
            jq -r '
                .actors | to_entries | 
                sort_by(.value.report_count) | reverse |
                .[:10] | 
                .[] | 
                "\(.value.username) - Reports: \(.value.report_count) - Last: \(.value.last_reported)"
            ' "$BAD_ACTORS_JSON"
        fi
    else
        # Python fallback
        python3 -c "
import json
search = '$search'

with open('$BAD_ACTORS_JSON', 'r') as f:
    data = json.load(f)

actors = []
for username, actor in data['actors'].items():
    if not search or search in username:
        actors.append((username, actor['report_count'], actor.get('last_reported', 'N/A')))

actors.sort(key=lambda x: x[1], reverse=True)

for username, count, last in actors[:10]:
    print(f'{username} - Reports: {count} - Last: {last}')
"
    fi
}

# View report details
view_report() {
    local report_id="$1"
    local report_file="$REPORT_DIR/$report_id.json"
    
    if [[ ! -f "$report_file" ]]; then
        echo -e "${RED}[!] Report not found: $report_id${NC}"
        return 1
    fi
    
    echo -e "${BLUE}=== Spam Report: $report_id ===${NC}"
    if command -v jq &> /dev/null; then
        jq . "$report_file"
    else
        cat "$report_file"
    fi
}

# Statistics
show_stats() {
    echo -e "${BLUE}=== Spam Reporting Statistics ===${NC}"
    
    if command -v jq &> /dev/null; then
        jq -r '
            "Total bad actors: \(.actors | length)",
            "Total reports filed: \(.reports | length)",
            "",
            "Top 5 reported actors:",
            (.actors | to_entries | 
             sort_by(.value.report_count) | reverse |
             .[:5] | 
             .[] | 
             "  \(.value.username): \(.value.report_count) reports")
        ' "$BAD_ACTORS_JSON"
    else
        # Python fallback
        python3 -c "
import json

with open('$BAD_ACTORS_JSON', 'r') as f:
    data = json.load(f)

print(f'Total bad actors: {len(data[\"actors\"])}')
print(f'Total reports filed: {len(data[\"reports\"])}')
print()
print('Top 5 reported actors:')

actors = [(name, info['report_count']) for name, info in data['actors'].items()]
actors.sort(key=lambda x: x[1], reverse=True)

for name, count in actors[:5]:
    print(f'  {name}: {count} reports')
"
    fi
}

# Usage information
usage() {
    cat <<EOF
Moltbook Spam Reporting Tool - Agent Security Framework (Simple Version)

Usage: $0 <command> [arguments]

Commands:
    report <username> <type> <reporter> <description> [user_id]
        File a new spam report
        Types: spam, scam, harassment, impersonation, other
        
    finalize <report_id>
        Mark report as complete after adding evidence
        
    query [search_term]
        Search bad actor database
        
    view <report_id>
        View details of a specific report
        
    stats
        Show reporting statistics
        
    init
        Initialize reporting infrastructure

Examples:
    $0 report spammer123 spam "jeff" "Posting crypto scams"
    $0 finalize SPM-20260221-A1B2C3D4
    $0 query spammer
    $0 stats

Environment Variables:
    SPAM_REPORT_DIR    - Report storage directory (default: ~/.asf/spam-reports)
    BAD_ACTORS_JSON    - JSON database path (default: ~/.asf/bad-actors.json)
    SPAM_LOG_FILE      - Log file path (default: ~/.asf/spam-reports.log)
    EVIDENCE_DIR       - Evidence storage directory (default: ~/.asf/evidence)

Note: This is the simplified version that uses JSON instead of SQLite.
      Some features may be limited compared to the full version.
EOF
}

# Main command handler
main() {
    case "${1:-}" in
        init)
            init_infrastructure
            ;;
        report)
            if [[ $# -lt 5 ]]; then
                echo -e "${RED}[!] Missing arguments${NC}"
                usage
                exit 1
            fi
            init_infrastructure
            file_report "$2" "$3" "$4" "$5" "${6:-}"
            ;;
        finalize)
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}[!] Report ID required${NC}"
                usage
                exit 1
            fi
            finalize_report "$2"
            ;;
        query)
            init_infrastructure
            query_bad_actors "${2:-}"
            ;;
        view)
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}[!] Report ID required${NC}"
                usage
                exit 1
            fi
            view_report "$2"
            ;;
        stats)
            init_infrastructure
            show_stats
            ;;
        *)
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"