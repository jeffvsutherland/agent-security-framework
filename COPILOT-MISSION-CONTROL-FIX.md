# Prompt for Copilot to Fix Mission Control / Clawdbot Environment

```
Fix the Mission Control environment for Clawdbot/OpenClaw.

The system is experiencing issues with:
- Clawdbot can't see Mission Control in Telegram

Your task:
1. Check the current state of Mission Control:
   - cd /workspace/agent-security-framework
   - openclaw status
   - openclaw gateway status

2. Identify the problem:
   - Check logs: tail -50 ~/.openclaw/logs/*.log
   - Check for running processes: ps aux | grep openclaw
   - Test API connectivity: curl http://localhost:8000/health

3. Fix common issues:
   - If gateway not running: openclaw gateway start
   - If API unreachable: Check port 8000 is not blocked
   - If token issues: Verify .mc-token is valid

4. Test the fix:
   - openclaw status
   - Verify all services are running

5. Report what was fixed and current status.
```

---

## Telegram Bot Issues (Clawdbot can't see Mission Control)

### Check Telegram Configuration:

```bash
# Check Telegram bot status
ps aux | grep telegram

# Check OpenClaw config for Telegram
cat ~/.openclaw/config.yaml | grep -i telegram

# Verify bot token is set
grep TELEGRAM ~/.env

# Check relay status
openclaw relay status

# Restart Telegram relay
openclaw relay restart telegram
```

### Telegram Bot Setup Required:

1. **Get Bot Token**: Message @BotFather on Telegram
2. **Add Bot to Group**: Invite @ASF_Mission_Control_Bot to your group
3. **Grant Permissions**: Make bot an admin so it can see all messages
4. **Get Chat ID**: Use @userinfobot to get your group ID

### Common Telegram Fixes:

| Issue | Fix |
|-------|-----|
| Bot not responding | Check if running: `ps aux \| grep openclaw` |
| Can't see messages | Bot needs admin permissions in group |
| API errors | Verify bot token in .env file |
| Relay disconnected | Run `openclaw relay start telegram` |
| Wrong chat ID | Update CHAT_ID in config for your group |

### Test Telegram Connection:

```bash
# Send test message via bot
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d "chat_id=<CHAT_ID>" \
  -d "text=Mission Control test"
```

---

*Use this prompt with Copilot to diagnose and fix Mission Control / Clawdbot Telegram issues*
