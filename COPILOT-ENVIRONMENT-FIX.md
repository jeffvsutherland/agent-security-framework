# Prompt for Copilot: Fix OpenClaw Environment

## Contact
If you need help, reach out to:
- **Research Agent**: @ASFResearchBot (Telegram)
- **Raven (Product Owner)**: @AgentSaturdayASFBot (Telegram)
- **Jeff (Scrum Master)**: @jeffsutherland (Telegram)

## Context
There are issues with the OpenClaw environment that need to be fixed. Please investigate and resolve.

## Investigation Steps

1. Check Mission Control status:
```bash
curl -s http://openclaw-mission-control-backend-1:8000/health
```

2. Check OpenClaw Gateway:
```bash
docker ps | grep openclaw
docker logs openclaw-gateway --since 5m
```

3. Check for errors in recent logs:
```bash
tail -100 /var/log/openclaw/gateway.log
```

4. Test API connectivity:
```bash
curl -s "http://openclaw-mission-control-backend-1:8000/api/v1/boards"
```

## Common Fixes

### If Mission Control API is down:
```bash
cd ~/clawd/ASF-15-docker
docker compose restart openclaw-mission-control-backend-1
```

### If Gateway is not connecting:
```bash
# Check configuration
cat ~/.openclaw/openclaw.json | jq '.gateway'

# Restart gateway
docker compose restart openclaw-gateway
```

### If agents can't connect:
```bash
# Check agent status
docker ps | grep -E "sales|deploy|social|research"

# Restart specific agent
docker restart <agent-container>
```

## Verification

After fixes, verify:
1. Mission Control loads at http://localhost:3001
2. Gateway responds at http://localhost:8080/health
3. All agents show connected in supergroup

Please run these checks and fix any issues found.
