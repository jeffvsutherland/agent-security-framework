#!/usr/bin/env bash

# report-moltbook-spam.sh - Spam Reporting Infrastructure for Moltbook
# Part of Agent Security Framework (ASF)
# Version: 1.0.0

set -euo pipefail

# Configuration
REPORT_DIR="${SPAM_REPORT_DIR:-$HOME/.asf/spam-reports}"
BAD_ACTOR_DB="${BAD_ACTOR_DB:-$HOME/.asf/bad-actors.db}"
LOG_FILE="${SPAM_LOG_FILE:-$HOME/.asf/spam-reports.log}"
EVIDENCE_DIR="${EVIDENCE_DIR:-$HOME/.asf/evidence}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for sqlite3
check_sqlite() {
    if ! command -v sqlite3 &> /dev/null; then
        echo -e "${YELLOW}[!] Warning: sqlite3 not found. Using JSON fallback mode.${NC}"
        echo -e "${YELLOW}[!] To enable full features, install sqlite3:${NC}"
        echo "    apt-get install sqlite3  # Debian/Ubuntu"
        echo "    yum install sqlite      # RHEL/CentOS"
        echo "    brew install sqlite     # macOS"
        return 1
    fi
    return 0
}

# Initialize directories and files
init_infrastructure() {
    mkdir -p "$REPORT_DIR" "$EVIDENCE_DIR"
    touch "$LOG_FILE"
    
    # Initialize bad actors JSON file if SQLite is not available
    if ! check_sqlite; then
        if [[ ! -f "$REPORT_DIR/bad-actors.json" ]]; then
            echo '{"actors": {}, "reports": []}' > "$REPORT_DIR/bad-actors.json"
            echo -e "${GREEN}[+] Initialized bad actors JSON database${NC}"
        fi
        return 0
    fi
    
    # Initialize SQLite database if it doesn't exist
    if [[ ! -f "$BAD_ACTOR_DB" ]]; then
        sqlite3 "$BAD_ACTOR_DB" <<EOF
CREATE TABLE IF NOT EXISTS bad_actors (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    user_id TEXT,
    platform TEXT NOT NULL DEFAULT 'moltbook',
    report_count INTEGER DEFAULT 1,
    first_reported TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_reported TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'active',
    notes TEXT
);

CREATE TABLE IF NOT EXISTS spam_reports (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    report_id TEXT UNIQUE NOT NULL,
    actor_id INTEGER,
    reporter TEXT NOT NULL,
    report_type TEXT NOT NULL,
    evidence_path TEXT,
    description TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (actor_id) REFERENCES bad_actors(id)
);

CREATE INDEX IF NOT EXISTS idx_username ON bad_actors(username);
CREATE INDEX IF NOT EXISTS idx_report_id ON spam_reports(report_id);
EOF
        echo -e "${GREEN}[+] Initialized bad actor database${NC}"
    fi
}

# Generate unique report ID
generate_report_id() {
    echo "SPM-$(date +%Y%m%d)-$(openssl rand -hex 4 | tr '[:lower:]' '[:upper:]')"
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
            ;;
        profile)
            echo -e "${YELLOW}[!] Collecting profile data for $username...${NC}"
            # Placeholder for API call to collect profile data
            echo "{\"username\": \"$username\", \"collected_at\": \"$(date -Iseconds)\"}" > "$evidence_subdir/profile.json"
            ;;
        messages)
            echo -e "${YELLOW}[!] Please export spam messages and save to:${NC}"
            echo "    $evidence_subdir/messages.txt"
            ;;
        *)
            echo -e "${RED}[!] Unknown evidence type: $evidence_type${NC}"
            return 1
            ;;
    esac
    
    echo "$evidence_subdir"
}

# Add or update bad actor in database
update_bad_actor_db() {
    local username="$1"
    local user_id="${2:-}"
    local notes="${3:-}"
    
    # Check if actor already exists
    local actor_id=$(sqlite3 "$BAD_ACTOR_DB" "SELECT id FROM bad_actors WHERE username = '$username' LIMIT 1;")
    
    if [[ -n "$actor_id" ]]; then
        # Update existing actor
        sqlite3 "$BAD_ACTOR_DB" <<EOF
UPDATE bad_actors 
SET report_count = report_count + 1,
    last_reported = CURRENT_TIMESTAMP,
    user_id = COALESCE('$user_id', user_id),
    notes = COALESCE('$notes', notes)
WHERE id = $actor_id;
EOF
        log_action "Updated bad actor" "$username (ID: $actor_id)"
    else
        # Insert new actor
        sqlite3 "$BAD_ACTOR_DB" <<EOF
INSERT INTO bad_actors (username, user_id, notes) 
VALUES ('$username', '$user_id', '$notes');
EOF
        actor_id=$(sqlite3 "$BAD_ACTOR_DB" "SELECT last_insert_rowid();")
        log_action "Added new bad actor" "$username (ID: $actor_id)"
    fi
    
    echo "$actor_id"
}

# File spam report
file_report() {
    local username="$1"
    local report_type="$2"
    local reporter="$3"
    local description="$4"
    local user_id="${5:-}"
    
    local report_id=$(generate_report_id)
    local report_file="$REPORT_DIR/$report_id.json"
    
    log_action "Starting spam report" "$report_id for @$username"
    
    # Collect evidence
    local evidence_path=$(collect_evidence "$username" "$report_id" "screenshot")
    
    # Update bad actor database
    local actor_id=$(update_bad_actor_db "$username" "$user_id" "$description")
    
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
    
    # Add to spam reports table
    sqlite3 "$BAD_ACTOR_DB" <<EOF
INSERT INTO spam_reports (report_id, actor_id, reporter, report_type, evidence_path, description)
VALUES ('$report_id', $actor_id, '$reporter', '$report_type', '$evidence_path', '$description');
EOF
    
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
    
    # Update report status
    local tmp_file=$(mktemp)
    jq '.status = "complete" | .evidence.collected = true' "$report_file" > "$tmp_file"
    mv "$tmp_file" "$report_file"
    
    log_action "Report finalized" "$report_id"
    echo -e "${GREEN}[+] Report $report_id finalized${NC}"
}

# Query bad actors
query_bad_actors() {
    local search="${1:-}"
    
    echo -e "${BLUE}=== Bad Actor Database ===${NC}"
    
    if [[ -n "$search" ]]; then
        sqlite3 -header -column "$BAD_ACTOR_DB" <<EOF
SELECT username, user_id, report_count, 
       datetime(first_reported, 'localtime') as first_seen,
       datetime(last_reported, 'localtime') as last_seen,
       status
FROM bad_actors 
WHERE username LIKE '%$search%' 
ORDER BY last_reported DESC;
EOF
    else
        sqlite3 -header -column "$BAD_ACTOR_DB" <<EOF
SELECT username, report_count, 
       datetime(last_reported, 'localtime') as last_seen,
       status
FROM bad_actors 
ORDER BY last_reported DESC 
LIMIT 20;
EOF
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
    jq . "$report_file"
}

# Statistics
show_stats() {
    echo -e "${BLUE}=== Spam Reporting Statistics ===${NC}"
    
    local total_actors=$(sqlite3 "$BAD_ACTOR_DB" "SELECT COUNT(*) FROM bad_actors;")
    local total_reports=$(sqlite3 "$BAD_ACTOR_DB" "SELECT COUNT(*) FROM spam_reports;")
    local active_actors=$(sqlite3 "$BAD_ACTOR_DB" "SELECT COUNT(*) FROM bad_actors WHERE status = 'active';")
    
    echo "Total bad actors: $total_actors"
    echo "Active bad actors: $active_actors"
    echo "Total reports filed: $total_reports"
    echo ""
    echo "Top 5 reported actors:"
    sqlite3 -header -column "$BAD_ACTOR_DB" <<EOF
SELECT username, report_count
FROM bad_actors 
ORDER BY report_count DESC 
LIMIT 5;
EOF
}

# Usage information
usage() {
    cat <<EOF
Moltbook Spam Reporting Tool - Agent Security Framework

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
    BAD_ACTOR_DB       - SQLite database path (default: ~/.asf/bad-actors.db)
    SPAM_LOG_FILE      - Log file path (default: ~/.asf/spam-reports.log)
    EVIDENCE_DIR       - Evidence storage directory (default: ~/.asf/evidence)
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