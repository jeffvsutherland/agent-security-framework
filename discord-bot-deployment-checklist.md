# Discord Bot Deployment Checklist - ASF-18
**Sprint 2 Story: Deploy Discord Bots**
**Points:** 8
**Owner:** Deploy Agent (coordinated by Product Owner)

## 📋 Pre-Deployment Checklist

### 1. Environment Variables Required
- [ ] `DISCORD_AGENT_BOT_TOKEN` - Token for agent verification bot
- [ ] `DISCORD_SKILL_BOT_TOKEN` - Token for skill security checker bot
- [ ] `ASF_API_KEY` - API key for ASF backend
- [ ] `ASF_API_URL` - Default: http://asf-api:8080
- [ ] `VERIFICATION_CHANNEL_ID` - Discord channel for verifications
- [ ] `ANNOUNCEMENT_CHANNEL_ID` - Discord channel for announcements
- [ ] `SKILL_CHECK_CHANNEL_ID` - Channel for skill security checks
- [ ] `SECURITY_ALERT_CHANNEL_ID` - Channel for security alerts

### 2. Docker Setup
- [ ] Ensure Docker and docker-compose installed
- [ ] Create ASF network: `docker network create asf-network`
- [ ] Build bot containers
- [ ] Set up log directories

### 3. Discord Bot Setup
- [ ] Create two Discord applications at discord.com/developers
- [ ] Generate bot tokens for each
- [ ] Set proper bot permissions (read/write messages, manage roles)
- [ ] Invite bots to target Discord server

### 4. Deployment Commands
```bash
# Navigate to deployment directory
cd /workspace/ASF-15-docker

# Create .env file with all tokens
cat > .env << EOF
DISCORD_AGENT_BOT_TOKEN=your_agent_bot_token
DISCORD_SKILL_BOT_TOKEN=your_skill_bot_token
ASF_API_KEY=your_asf_api_key
VERIFICATION_CHANNEL_ID=channel_id_here
ANNOUNCEMENT_CHANNEL_ID=channel_id_here
SKILL_CHECK_CHANNEL_ID=channel_id_here
SECURITY_ALERT_CHANNEL_ID=channel_id_here
EOF

# Deploy bots
docker-compose -f docker-compose.discord-bots.yml up -d

# Check status
docker ps | grep asf-discord

# View logs
docker logs -f asf-discord-agent-verifier
docker logs -f asf-discord-skill-verifier
```

### 5. Post-Deployment Verification
- [ ] Both containers running without errors
- [ ] Bots appear online in Discord
- [ ] Test commands work in designated channels
- [ ] Health checks passing
- [ ] Logs show successful connections

### 6. Monitoring Setup
- [ ] Set up uptime monitoring
- [ ] Configure alerts for bot offline
- [ ] Document bot commands
- [ ] Create user guide

## 🚀 Benefits Once Deployed
1. **Agent Verification Bot**
   - Verifies legitimate AI agents
   - Prevents impersonation
   - Issues verified badges

2. **Skill Security Checker Bot**
   - Scans skills for vulnerabilities
   - Alerts on malicious patterns
   - Real-time security monitoring

## 📝 Notes for Morning Deployment
- Need Discord developer account access
- Coordinate with Jeff for token generation
- Test in private Discord first
- Plan announcement for community

## Success Metrics
- 99.9% uptime target
- <1s response time
- Zero false positives
- Community adoption rate