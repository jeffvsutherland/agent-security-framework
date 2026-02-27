# ASF Discord Bots Production Deployment Guide

## Overview

This guide covers the deployment and management of two ASF Discord bots:
1. **Agent Verifier Bot** - Verifies agent authenticity and tracks registrations
2. **Skill Security Checker Bot** - Scans and validates skill security

## Prerequisites

1. Docker and Docker Compose installed
2. Discord bot tokens (create at https://discord.com/developers/applications)
3. ASF API running (via main docker-compose.yml)
4. Configured .env file

## Quick Start

### 1. Configure Environment

```bash
cd ASF-15-docker
cp .env.example .env
# Edit .env and add your Discord bot tokens:
# - DISCORD_AGENT_BOT_TOKEN
# - DISCORD_SKILL_BOT_TOKEN
# - ASF_API_KEY
```

### 2. Deploy Bots

```bash
# Build and deploy both bots
make discord-deploy

# Or manually:
make discord-build
make discord-up
```

### 3. Verify Deployment

```bash
# Check status
make discord-status

# View logs
make discord-logs

# Monitor health
make discord-monitor
```

## Bot Configuration

### Agent Verifier Bot
- **Purpose**: Verify agent authenticity, prevent fake agents
- **Commands**: 
  - `/verify @agent` - Verify an agent
  - `/check-agent [agent_id]` - Check agent status
  - `/agent-stats` - View verification statistics

### Skill Security Checker Bot  
- **Purpose**: Scan skills for security vulnerabilities
- **Commands**:
  - `/scan-skill [url]` - Scan a skill repository
  - `/skill-report [skill_id]` - View security report
  - `/security-alerts` - View recent alerts

## Production Deployment Checklist

### Pre-Deployment
- [ ] Discord bot tokens configured in .env
- [ ] ASF API key generated and configured
- [ ] Channel IDs set for announcements/alerts
- [ ] Test bots in development Discord server
- [ ] Backup current deployment state

### Deployment Steps
1. **Run deployment script**: `make discord-deploy`
2. **Health checks**: Script automatically verifies bot health
3. **Rollback**: Automatic if health checks fail
4. **Monitoring**: Use `make discord-monitor` for real-time status

### Post-Deployment
- [ ] Verify bots appear online in Discord
- [ ] Test each bot command
- [ ] Check logs for errors: `make discord-logs`
- [ ] Set up monitoring alerts
- [ ] Document channel configurations

## Monitoring & Maintenance

### Real-time Monitoring
```bash
# Interactive monitor with alerts
make discord-monitor

# View specific bot logs
make discord-logs-agent  # Agent verifier logs
make discord-logs-skill  # Skill checker logs
```

### Health Checks
The bots include automatic health checks:
- Container health status every 30s
- API connectivity verification
- Error rate monitoring
- Resource usage tracking

### Alerts
Configure Discord webhook for alerts:
```bash
export DISCORD_ALERT_WEBHOOK="https://discord.com/api/webhooks/..."
make discord-monitor
```

## Troubleshooting

### Bot Won't Start
1. Check logs: `docker logs asf-discord-agent-verifier`
2. Verify token: Ensure bot token is valid
3. Check API: Ensure ASF API is accessible
4. Network issues: Verify Discord API connectivity

### Bot Goes Offline
1. Check container status: `docker ps -a | grep discord`
2. Restart bot: `make discord-restart`
3. Check resource limits: May need to increase memory
4. Review error logs for crash reasons

### Command Not Responding
1. Check bot permissions in Discord server
2. Verify channel IDs in configuration
3. Check rate limiting (Discord API limits)
4. Review command handler logs

## Scaling & Performance

### Resource Requirements
- **CPU**: 0.5 cores per bot (1.0 total)
- **Memory**: 512MB per bot (1GB total)  
- **Disk**: 100MB for logs per bot
- **Network**: Minimal (Discord WebSocket + API calls)

### Scaling Options
1. **Horizontal**: Deploy to multiple servers for redundancy
2. **Sharding**: For 2500+ Discord servers
3. **Load Balancing**: Use Discord's built-in sharding

## Security Considerations

1. **Tokens**: Never commit tokens to git
2. **API Keys**: Use separate keys per environment
3. **Network**: Bots only need outbound internet
4. **Permissions**: Run as non-root user
5. **Updates**: Regular security patches

## Backup & Recovery

### Backup
```bash
# Backup bot configuration
docker-compose -f docker-compose.discord-bots.yml config > backup-config.yml

# Backup logs
tar -czf discord-logs-$(date +%Y%m%d).tar.gz logs/
```

### Recovery
```bash
# Restore from backup
docker-compose -f backup-config.yml up -d

# Or rebuild from scratch
make discord-build
make discord-deploy
```

## Support & Updates

- **Documentation**: This guide + bot README files
- **Issues**: Create tickets in ASF project
- **Updates**: Pull latest changes and rebuild
- **Community**: ASF Discord #bot-support channel

---

**Note**: This deployment supports 99.9% uptime targets with automatic recovery and health monitoring.