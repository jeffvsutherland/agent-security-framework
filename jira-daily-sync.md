# Daily Jira Sync Checklist

## Morning Sync Process (Part of 7 AM Report)

1. **Run Status Check (LIVE from Mission Control API):**
   ```bash
   # Board summary
   python3 /workspace/agent-security-framework/check-asf-status.py --summary

   # Check specific story
   python3 /workspace/agent-security-framework/check-asf-status.py ASF-33

   # Filter by status
   python3 /workspace/agent-security-framework/check-asf-status.py --status in_progress

   # Full board view
   python3 /workspace/agent-security-framework/check-asf-status.py
   ```
   > **Note:** This script fetches LIVE data from Mission Control API.
   > On host it connects to `localhost:8001`, in Docker to `host.docker.internal:8001`.
   > No Jira token needed — uses Mission Control agent token.

2. **Compare with Yesterday's Memory:**
   - Check /workspace/memory/YYYY-MM-DD.md for completed work
   - Identify stories marked complete but still "To Do" on the board

3. **Update Story Status:**
   - Use Mission Control UI or mc-api to move stories to correct columns
   - Assign unassigned high-priority stories

4. **Document Points for IRS:**
   - Record story ID, title, and points for any completed work
   - Keep running monthly total


## IRS Documentation Format:
```
Date: YYYY-MM-DD
Story: [ID] - [Title]
Points: [X]
Status: Completed
```