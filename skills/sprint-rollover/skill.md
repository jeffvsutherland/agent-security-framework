# SKILL: Daily Sprint Rollover

**Description:** Automates the 24-hour Kanban board reset for the Agent Security Framework.
**Trigger:** Cron — 11:59 PM nightly (`59 23 * * *`)
**Agent:** Architect
**Workspace:** agent-security-framework

## Execution Steps

### 1. Read Board State
Query the local Mission Control database/state for the `agent-security-framework` board.

```bash
# From Docker:
/workspace/.mc-api-backup boards
/workspace/.mc-api-backup tasks
```

### 2. Compile the Daily Report
- Identify all tasks in the `Done` column.
- Format them into a summary bulleted list.
- Append this list to `workspace/reports/DAILY_BUILD_LOG.md` under today's date header.

**Format:**
```markdown
## YYYY-MM-DD — Sprint Rollover Summary

### Completed Tasks
- [TASK-ID] Task title — completed by Agent
- [TASK-ID] Task title — completed by Agent

### Rolled Over (In Progress)
- [TASK-ID] Task title — reason for rollover

### New Backlog Items
- [TASK-ID] Task title — priority tag
```

### 3. Clear the Board
Archive all tasks documented from the `Done` column.

```bash
# For each done task:
/workspace/.mc-api-backup update-task <task-id> --column "Archive"
```

### 4. Tag Rollovers
Identify any tasks in `In Progress` or `In Review`. Add the tag `Rolled-Over` to them. Do not move them.

```bash
# For each in-progress/in-review task:
/workspace/.mc-api-backup tags <task-id> --add "Rolled-Over"
```

### 5. Restock Backlog
- Read `workspace/SECURITY_FRAMEWORK_BACKLOG.md`.
- Extract the top 3 tasks marked as `[URGENT]` or `[NEXT]`.
- Create new task cards for these in the `Backlog` column.
- Remove or check off those items in the markdown backlog file.

```bash
# For each new backlog item:
/workspace/.mc-api-backup create-task --title "<title>" --column "Backlog" --tags "Sprint-Queued"
```

### 6. Notification
Send a brief summary message to the primary communication channel confirming the rollover is complete and listing the 3 new backlog items.

## Error Handling
- If Mission Control is unreachable, write the report to the filesystem only and tag it `[MC-OFFLINE]`.
- If no tasks are in `Done`, skip steps 2-3 and note "No completed tasks today."
- Always write the daily log entry regardless of board state.

## Dependencies
- `/workspace/.mc-api-backup` — Mission Control CLI
- `workspace/reports/DAILY_BUILD_LOG.md` — Append-only log
- `workspace/SECURITY_FRAMEWORK_BACKLOG.md` — Source of new tasks

