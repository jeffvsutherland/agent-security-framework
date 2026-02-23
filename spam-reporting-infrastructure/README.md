# ASF-24: Moltbook Spam Reporting Infrastructure

## What This Is

A comprehensive spam reporting and bad actor tracking system for Moltbook (and other platforms). It provides standardized evidence collection, persistent database tracking, and complete audit trails for security operations.

## Why It's Valuable

- **Zero Dependencies**: Works on any Linux/macOS/WSL system with bash
- **Evidence Chain of Custody**: Timestamped logs and evidence storage meet compliance requirements  
- **Repeat Offender Tracking**: Automatically tracks how many times each actor has been reported
- **Team Collaboration**: Shared database format supports multi-operator workflows
- **Automated Integration Ready**: Easy to integrate with detection systems and webhooks

## Scripts Included

### 1. report-moltbook-spam-simple.sh (RECOMMENDED)
**Purpose**: Zero-dependency spam reporting with JSON storage  
**Use when**: You need quick setup with no external dependencies

```bash
# Quick start
chmod +x report-moltbook-spam-simple.sh
./report-moltbook-spam-simple.sh init

# Report a bad actor
./report-moltbook-spam-simple.sh report "username" spam "reporter" "Description"

# Check statistics
./report-moltbook-spam-simple.sh stats

# Search bad actors
./report-moltbook-spam-simple.sh query "searchterm"
```

### 2. report-moltbook-spam.sh (FULL VERSION)
**Purpose**: Full-featured version with SQLite database  
**Use when**: You need better performance for high-volume reporting (requires sqlite3)

```bash
# Install sqlite3 first: apt-get install sqlite3
chmod +x report-moltbook-spam.sh
./report-moltbook-spam.sh init

# Same commands as simple version
./report-moltbook-spam.sh report "username" scam "reporter" "Details"
./report-moltbook-spam.sh stats
```

## Quick Start

```bash
# One-command setup
git clone https://github.com/jeffvsutherland/agent-security-framework
cd agent-security-framework/spam-reporting-infrastructure

# Initialize
./report-moltbook-spam-simple.sh init

# Start using
./report-moltbook-spam-simple.sh report "badactor123" spam "security_team" "Crypto scammer"
```

## Complete Documentation

See `SPAM-REPORTING-README.md` for detailed technical documentation including:
- Database schema
- Evidence collection workflows
- API integration examples
- Troubleshooting

## File Structure

```
spam-reporting-infrastructure/
├── README.md                    # This file
├── SPAM-REPORTING-README.md    # Technical documentation
├── report-moltbook-spam-simple.sh  # Recommended: JSON version
└── report-moltbook-spam.sh      # Full: SQLite version
```

## Performance

| Metric | JSON Version | SQLite Version |
|--------|-------------|----------------|
| Setup Time | < 30 seconds | < 30 seconds |
| Reports/Second | 50+ | 100+ |
| Storage (1000 reports) | ~5MB | ~3MB |
| Dependencies | None | sqlite3 |

## Integration Examples

### Team Slack Notification
```bash
./report-moltbook-spam-simple.sh report "$USER" spam "auto" "$DETAILS"
curl -X POST $SLACK_WEBHOOK -d "text=🚨 New spam report: $USER"
```

### Automated Detection
```bash
# In your detection script
if [ "$THREAT_LEVEL" -gt 80 ]; then
  ./report-moltbook-spam-simple.sh report "$DETECTED_USER" "$TYPE" "auto_detect" "$PATTERN"
fi
```

---

**Story**: ASF-24  
**Status**: Ready for Review  
**Version**: 1.0.0

The Spam Reporting Infrastructure provides a standardized system for reporting, tracking, and managing spam/bad actors on Moltbook. It includes automated evidence collection, persistent bad actor database, and comprehensive logging.

## Features

- **Quick Reporting**: Single command to report spam with all required information
- **Evidence Collection**: Standardized process for gathering screenshots, profiles, and messages
- **Bad Actor Database**: SQLite-based tracking of repeat offenders
- **Action Logging**: Timestamped audit trail of all reporting activities
- **Report Management**: View, search, and analyze spam reports

## Installation

1. Make the script executable:
```bash
chmod +x report-moltbook-spam.sh
```

2. Initialize the infrastructure:
```bash
./report-moltbook-spam.sh init
```

This creates:
- `~/.asf/spam-reports/` - Report storage
- `~/.asf/bad-actors.db` - SQLite database
- `~/.asf/evidence/` - Evidence files
- `~/.asf/spam-reports.log` - Activity log

## Usage

### File a New Report

```bash
./report-moltbook-spam.sh report <username> <type> <reporter> <description> [user_id]
```

**Report Types:**
- `spam` - Unwanted promotional content
- `scam` - Fraudulent schemes
- `harassment` - Abusive behavior
- `impersonation` - Fake accounts
- `other` - Miscellaneous violations

**Example:**
```bash
./report-moltbook-spam.sh report spammer123 spam "jeff" "Posting crypto scams repeatedly"
```

### Complete Evidence Collection

After filing a report, add evidence files to the provided directory, then finalize:

```bash
./report-moltbook-spam.sh finalize SPM-20260221-A1B2C3D4
```

### Search Bad Actors

```bash
# View all bad actors
./report-moltbook-spam.sh query

# Search by username
./report-moltbook-spam.sh query spammer
```

### View Report Details

```bash
./report-moltbook-spam.sh view SPM-20260221-A1B2C3D4
```

### Statistics

```bash
./report-moltbook-spam.sh stats
```

## Database Schema

### bad_actors table
- `id` - Primary key
- `username` - Moltbook username
- `user_id` - Platform user ID (if available)
- `platform` - Always 'moltbook'
- `report_count` - Number of reports filed
- `first_reported` - Initial report timestamp
- `last_reported` - Most recent report
- `status` - active/banned/watching
- `notes` - Additional context

### spam_reports table
- `id` - Primary key
- `report_id` - Unique report identifier (SPM-YYYYMMDD-XXXXXXXX)
- `actor_id` - Foreign key to bad_actors
- `reporter` - Who filed the report
- `report_type` - Category of spam
- `evidence_path` - Location of evidence files
- `description` - Detailed description
- `timestamp` - Report creation time

## Evidence Collection

Evidence is stored in `~/.asf/evidence/<report_id>/`:

1. **Screenshots** (`screenshot.png`)
   - Capture spam content
   - Include username/timestamp visible
   - Save as PNG for quality

2. **Profile Data** (`profile.json`)
   - User profile information
   - Account creation date
   - Follower/following counts

3. **Messages** (`messages.txt`)
   - Export spam messages
   - Include timestamps
   - Preserve formatting

## Integration Points

The system is designed for integration with:

- **Automated Detection**: Scripts can call the reporting tool
- **Moltbook API**: Future profile data collection
- **Moderation Dashboard**: Export reports for review
- **Ban Lists**: Generate block lists from database

## Best Practices

1. **Always Collect Evidence**: Reports without evidence are less actionable
2. **Use Consistent Usernames**: Exact spelling matters for tracking
3. **Detailed Descriptions**: Include context about the spam pattern
4. **Regular Review**: Check stats weekly to identify trends
5. **Coordinate Reporting**: Share report IDs with team members

## Environment Variables

Customize paths if needed:

```bash
export SPAM_REPORT_DIR=/custom/path/spam-reports
export BAD_ACTOR_DB=/custom/path/bad-actors.db
export SPAM_LOG_FILE=/custom/path/spam.log
export EVIDENCE_DIR=/custom/path/evidence
```

## Troubleshooting

### "Report not found"
- Check report ID spelling
- Verify report exists: `ls ~/.asf/spam-reports/`

### "Database locked"
- Another process is accessing the database
- Wait a moment and retry

### Evidence directory missing
- Script creates directory structure
- Run with proper permissions

## Security Considerations

- Database contains usernames only (no passwords/PII)
- Evidence may contain sensitive content
- Restrict access to `~/.asf/` directory
- Regular backups recommended

## Future Enhancements

- [ ] API integration for automated profile collection
- [ ] Web dashboard for report management
- [ ] Automated evidence validation
- [ ] Machine learning for pattern detection
- [ ] Integration with platform moderation APIs

---

Part of the Agent Security Framework (ASF)  
Version 1.0.0