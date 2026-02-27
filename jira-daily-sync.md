# Daily Jira Sync Checklist

## Morning Sync Process (Part of 7 AM Report)

1. **Run Status Check:**
   ```bash
   cd /workspace && JIRA_API_TOKEN="..." python3 check-asf-status.py
   ```

2. **Compare with Yesterday's Memory:**
   - Check /workspace/memory/YYYY-MM-DD.md for completed work
   - Identify stories marked complete but still "To Do" in Jira

3. **Update Story Status:**
   - Use Jira web UI or API to move stories to correct columns
   - Assign unassigned high-priority stories

4. **Document Points for IRS:**
   - Record story ID, title, and points for any completed work
   - Keep running monthly total

## Current Updates Needed (Feb 17):
- [ ] ASF-22 → Done (3 pts)
- [ ] ASF-24 → Done (2 pts)

## IRS Documentation Format:
```
Date: YYYY-MM-DD
Story: [ID] - [Title]
Points: [X]
Status: Completed
```