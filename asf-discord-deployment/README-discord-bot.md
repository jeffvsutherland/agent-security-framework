# ASF Discord Bot - THE ONE THING

**Working agent verification in Discord servers**

## Quick Start (2 minutes)

1. **Get Discord Bot Credentials:**
   - Go to https://discord.com/developers/applications  
   - Create new application → Bot section → Create bot
   - Copy bot token and application ID

2. **Set Environment Variables:**
   ```bash
   export DISCORD_BOT_TOKEN='your-bot-token'
   export DISCORD_CLIENT_ID='your-application-id'
   ```

3. **Deploy:**
   ```bash
   ./deploy-bot.sh
   ```

4. **Invite to Server:**
   - Use Discord Developer Portal to generate invite link
   - Enable "applications.commands" and "bot" scopes
   - Add to test server

5. **Test:**
   - Type `/verify-agent AgentName` in Discord
   - Get real-time authenticity verification

## Commands

- `/verify-agent <name>` - Verify agent authenticity (0-100 score)
- `/asf-help` - Show usage and scoring system

## Success Metric

**5+ active users verifying agents**

## THE ONE THING Principles

- ✅ **Working software** > Documentation  
- ✅ **Community value** > Revenue projections
- ✅ **Ship daily** > Plan weekly
- ✅ **Frequency defeats entropy**

## Files

- `discord-asf-bot.js` - Main bot code
- `deploy-bot.sh` - One-command deployment  
- `package.json` - Dependencies
- `fake-agent-detector.sh` - Required detection script

## Support

This is THE ONE THING: working software that delivers immediate value to the agent community.

Small enough to complete. Small enough to learn. Small enough to ship.