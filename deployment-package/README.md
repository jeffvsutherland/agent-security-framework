# ASF Discord Bot - Real-time Agent Verification for Discord Communities

**Protect your Discord server from fake agents and credential stealers**

## The Problem

Discord servers face increasing infiltration from fake AI agents designed to:
- Steal credentials and API keys from developers
- Manipulate community discussions
- Harvest personal information from server members
- Damage server reputation through spam and scams

## The Solution

ASF Discord Bot provides **real-time agent verification** with a simple slash command:

```
/verify-agent SuspiciousBot
```

Get instant authenticity scoring and risk assessment to protect your community.

## Quick Start (2 minutes)

### 1. Create Discord Application
- Go to https://discord.com/developers/applications
- Click "New Application" → Enter name "ASF Security Bot"
- Go to "Bot" section → Click "Add Bot"
- Copy the bot token

### 2. Set Environment Variables
```bash
export DISCORD_BOT_TOKEN='your-bot-token-here'
export DISCORD_CLIENT_ID='your-application-id'
```

### 3. Install Dependencies
```bash
npm install discord.js
```

### 4. Run the Bot
```bash
node discord-asf-bot.js
```

### 5. Invite to Your Server
- In Discord Developer Portal: OAuth2 → URL Generator
- Select scopes: "bot" and "applications.commands"
- Select permissions: "Send Messages", "Use Slash Commands"
- Copy invite URL and add to your server

## Commands

- `/verify-agent <agent_name>` - Verify agent authenticity
- `/asf-help` - Show available commands

## Features

- **Real-time verification** - Results in <2 seconds
- **Risk scoring** - 0-100 authenticity scale
- **Pattern detection** - Identifies fake agent behaviors
- **Community protection** - Helps moderators make informed decisions

## Security Analysis

The bot analyzes:
- **Behavioral patterns** - Posting frequency and timing
- **Technical verification** - Actual code and deployments  
- **Community engagement** - Quality of interactions
- **Work portfolio** - Evidence of real problem-solving

## Example Output

```
🔍 Agent Verification Results
Agent: SuspiciousBot123
Authenticity Score: 15/100
Classification: FAKE AGENT
Risk Level: HIGH

⚠️ Risk Indicators:
• Suspicious regular posting pattern
• No verifiable technical work
• Low-quality community engagement

Recommendation: Block immediately
```

## Requirements

- Node.js 16+
- Discord.js library
- Discord bot token and permissions

## Support

- Issues: File GitHub issues for bugs or feature requests
- Community: Join our Discord for support and updates
- Updates: Watch repository for new features and security improvements

## License

Open source - protect your community today!

---

**ASF Discord Bot - Making Discord communities safer, one verification at a time** 🛡️