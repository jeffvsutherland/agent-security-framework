# Telegram Multi-Agent Setup Guide for Raven

Date: February 18, 2026  
From: Copilot  
To: Raven (Agent Saturday / Product Owner)  
Status: ✅ ALL AGENTS CONNECTED AND WORKING 🎉

## What Was Fixed Today
All ASF agents are now properly connected to their Telegram bots and responding to messages. Here's what Copilot did to make it work:

### The Problem
- All 6 Telegram bots were starting, but messages to @ASFSalesBot (and other agent bots) weren't being processed
- Messages were all routing to the main agent instead of their designated agents
- The agents existed but had no bindings to connect Telegram accounts to agent sessions

### The Solution
Added bindings configuration to OpenClaw that routes each Telegram account to its corresponding agent:
```json
{
  "bindings": [
    {"agentId": "sales", "match": {"channel": "telegram", "accountId": "sales"}},
    {"agentId": "deploy", "match": {"channel": "telegram", "accountId": "deploy"}},
    {"agentId": "social", "match": {"channel": "telegram", "accountId": "social"}},
    {"agentId": "research", "match": {"channel": "telegram", "accountId": "research"}},
    {"agentId": "product-owner", "match": {"channel": "telegram", "accountId": "product-owner"}}
  ]
}
```

## 🤖 Your Agent Team on Telegram

| Agent | Telegram Bot | Role | Workspace |
|-------|--------------|------|-----------|
| main | @jeffsutherlandbot | Primary agent, general tasks | /workspace/ |
| sales | @ASFSalesBot | Sales, website, customer outreach | /workspace/agents/sales/ |
| deploy | @ASFDeployBot | DevOps, Docker, infrastructure | /workspace/agents/deploy/ |
| social | @ASFSocialBot | Social media, marketing | /workspace/agents/social/ |
| research | @ASFResearchBot | Research, analysis, documentation | /workspace/agents/research/ |
| product-owner | @AgentSaturdayASFBot | That's YOU! Product management | /workspace/agents/product-owner/ |

## 💬 How to Communicate with Other Agents

### Direct Messages to Specific Agents
Open Telegram and message the bot directly:

**To Sales Agent:**
- Open @ASFSalesBot in Telegram
- Send: "Please work on ASF-33: Create the Agent Security Framework website"

**To Deploy Agent:**
- Open @ASFDeployBot in Telegram
- Send: "Check the Docker container status and report any issues"

**To Research Agent:**
- Open @ASFResearchBot in Telegram
- Send: "Research competitor AI agent security solutions and create a comparison matrix"

**To Social Agent:**
- Open @ASFSocialBot in Telegram
- Send: "Draft a Twitter thread announcing our ASF v2.0 release"

### Assigning Jira Stories
Include the Jira ticket number for tracking:
```
@ASFSalesBot Please work on ASF-33: Create Agent Security Framework Website
- Use scrumai.org/agentsecurityframework domain
- Include pricing page
- Add documentation section
- Update Jira with hourly progress
```

### Requesting Status Updates
```
@ASFDeployBot What's your current status on ASF-30?
```

Or ask any agent for a team-wide update:
```
@jeffsutherlandbot Give me a status report on all active stories across all agents
```

## 🔄 How the Routing Works

```
You send message to @ASFSalesBot
       ↓
OpenClaw Gateway receives message
       ↓
Bindings check: telegram account "sales" → agentId "sales"
       ↓
Sales Agent session processes the message
       ↓
Response sent back through @ASFSalesBot
```

Each agent has:
- **Isolated workspace** - Their own files and context
- **Isolated session** - Separate conversation history
- **Shared API key** - All agents use the same Anthropic API key

## 📋 Quick Reference Commands

### Check Agent Status
```bash
# SSH into server or use terminal
docker exec openclaw-gateway node /app/openclaw.mjs agents list --bindings
```

### Check Channel Status
```bash
docker exec openclaw-gateway node /app/openclaw.mjs channels status
```

### View Recent Logs
```bash
docker logs --tail=50 openclaw-gateway
```

### Restart After Issues
```bash
cd ~/clawd/ASF-15-docker
docker-compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

### Re-apply Bindings (if lost after restart)
```bash
cd ~/clawd && ./spawn-asf-agents.sh
```

## 🎯 Best Practices for Working with Agent Team

### 1. Be Specific with Assignments
❌ "Work on the website"  
✅ "Work on ASF-33: Create Agent Security Framework website at scrumai.org/agentsecurityframework with pricing, docs, and demo sections"

### 2. Include Jira Ticket Numbers
This helps agents track and update progress:
```
@ASFResearchBot ASF-25: Research AI agent security market - create competitor analysis
```

### 3. Request Hourly Updates for Important Work
```
@ASFSalesBot Work on ASF-33 and provide hourly status updates in Jira
```

### 4. Use the Right Agent for the Job

| Task Type | Best Agent |
|-----------|------------|
| Website, sales materials, outreach | @ASFSalesBot |
| Docker, deployment, infrastructure | @ASFDeployBot |
| Twitter, LinkedIn, Moltbook posts | @ASFSocialBot |
| Documentation, analysis, research | @ASFResearchBot |
| Sprint planning, coordination | @AgentSaturdayASFBot (you!) |
| General tasks, delegation | @jeffsutherlandbot |

### 5. Delegate Through Main Agent
You can also ask the main agent to coordinate:
```
@jeffsutherlandbot Please assign the following:
- ASF-33 (website) → Sales Agent
- ASF-34 (Docker update) → Deploy Agent
- ASF-35 (announcement) → Social Agent
Have each report progress hourly.
```

## 🔧 Troubleshooting

### Agent Not Responding
Check if container is running:
```bash
docker ps | grep openclaw
```

Check logs for errors:
```bash
docker logs --tail=20 openclaw-gateway
```

Restart the gateway:
```bash
cd ~/clawd/ASF-15-docker
docker-compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

### Messages Going to Wrong Agent
Verify bindings are configured:
```bash
docker exec openclaw-gateway node /app/openclaw.mjs agents list --bindings
```

Re-run the spawn script:
```bash
cd ~/clawd && ./spawn-asf-agents.sh
```

### API Key Errors
Check that auth-profiles.json exists for each agent:
```bash
docker exec openclaw-gateway cat /home/node/.openclaw/agents/sales/agent/auth-profiles.json
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| ~/clawd/spawn-asf-agents.sh | Script to set up agent bindings |
| ~/clawd/ASF-15-docker/docker-compose.yml | Docker configuration |
| ~/clawd/ASF-15-docker/Dockerfile.openclaw | Extended OpenClaw image |
| ~/clawd/RAVEN-AGENT-TEAM-GUIDE.md | Full team management guide |

## 🚀 Ready to Go!
All agents are now live and ready to work. Try sending a message to any of them:
- @ASFSalesBot - "Hello, are you ready to work on ASF-33?"
- @ASFDeployBot - "Check Docker container health"
- @ASFResearchBot - "What research tasks are in the backlog?"
- @ASFSocialBot - "Draft a tweet about our multi-agent setup"

Happy coordinating! 🎉

_Document created by Copilot on February 18, 2026_