# OpenClaw Docker Deployment Record
Date: February 16-17, 2026
Deployed By: GitHub Copilot (via Jeff's IDE)
Version: OpenClaw 2026.2.15

## Container Details
- Image: openclaw-extended:2026.2.15 (custom build)
- Location: /Users/jeffsutherland/clawd/ASF-15-docker/
- Gateway: Running on 127.0.0.1:18789

## Volume Mounts
| Host Path | Container Path | Purpose |
|-----------|---------------|---------|
| ~/clawd | /workspace | Main workspace |
| ~/.jira-config | /home/node/.jira-config | Jira credentials |
| ~/.clawdbot | /home/node/.clawdbot-host | Bot configs |
| ~/agent-security-framework | /home/node/agent-security-framework | ASF files |
| ~/clawdbot-gmail | /home/node/clawdbot-gmail | Gmail integration |

## Installed Dependencies
### Python Packages
- yfinance (market data)
- google-api-python-client
- google-auth-httplib2
- google-auth-oauthlib
- atlassian-python-api
- requests

### CLI Tools
- jq 1.6 (JSON processing)
- himalaya 1.1.0 (email client)
- curl
- bash

## Working Scripts
- get-prices.py ✅
- jira-api-v3.py ✅ (new v3 API wrapper)
- moltbook-spam-monitor.sh ✅ (with jq)
- check-ff-email.sh ✅ (with himalaya)

## Telegram Bots Connected
1. @jeffsutherlandbot (default)
2. @ASFDeployBot
3. @ASFSalesBot
4. @ASFResearchBot
5. @ASFSocialBot
6. @AgentSaturdayASFBot (product-owner)

## Management Commands
```bash
# Navigate to deployment directory
cd /Users/jeffsutherland/clawd/ASF-15-docker

# Stop OpenClaw
docker-compose -f docker-compose.yml -f docker-compose.security.yml down openclaw

# Start OpenClaw
docker-compose -f docker-compose.yml -f docker-compose.security.yml up -d openclaw

# View logs
docker logs -f openclaw-gateway

# Test Jira
docker exec openclaw-gateway python3 /workspace/jira-api-v3.py test

# Check dependencies
docker exec openclaw-gateway python3 -c "import yfinance; print('OK')"
```

## Key Achievement
Successfully migrated from host-based Clawdbot to fully containerized OpenClaw 2026.2.15 with all monitoring capabilities intact and security enhanced through Docker isolation.