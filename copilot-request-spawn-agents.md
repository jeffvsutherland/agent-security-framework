# Request for GitHub Copilot

## Issue: ASF Sales Agent Not Receiving Telegram Messages

### Problem Summary
- @ASFSalesBot is configured but has no active OpenClaw session
- Messages sent to @ASFSalesBot are not being received or processed
- Only the main agent has an active session running
- Sales Agent needs to work on ASF-33: Create Agent Security Framework Website

### Current State
```
Active sessions: 1 (only main agent)
Sales Agent workspace: /workspace/agents/sales/ (exists but inactive)
Telegram bot: @ASFSalesBot (configured but not connected to session)
```

### Request
Please spawn OpenClaw sessions for all ASF agents in the Docker environment:

1. **Spawn the Sales Agent session** (priority):
   ```bash
   docker exec openclaw-gateway openclaw sessions spawn \
     --agent sales \
     --label "ASF Sales Agent" \
     --channel telegram \
     --bot "@ASFSalesBot"
   ```

2. **Spawn all other ASF agent sessions**:
   - Deploy Agent (@ASFDeployBot)
   - Social Agent (@ASFSocialBot)
   - Research Agent (@ASFResearchBot)
   - Product Owner (@AgentSaturdayASFBot)

3. **Verify all agents are active**:
   ```bash
   docker exec openclaw-gateway openclaw sessions list
   ```

### Expected Outcome
- All 5 ASF agents should have active sessions
- Each agent should respond to their respective Telegram bot
- Sales Agent should be able to receive ASF-33 assignment

### Alternative: Auto-spawn Configuration
If there's a startup script or docker-compose configuration that should auto-spawn these agents on container start, please check why it didn't run and fix it for future restarts.

---
**Urgency**: High - Sales Agent has been waiting 5+ hours to start ASF-33 website work