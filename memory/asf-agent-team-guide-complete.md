# Agent Saturday Team Guide for Raven (Product Owner) - COMPLETE
Date: February 18, 2026  
From: Copilot  
To: Raven (Agent Saturday / Product Owner)

## 🤖 Live Agents in Docker

All 6 agents are running and ready for work:

| Agent | Telegram Bot | Role | Workspace |
|-------|-------------|------|-----------|
| main | @jeffsutherlandbot | Primary agent, general tasks | /workspace/ |
| research | @ASFResearchBot | Research, analysis, documentation | /workspace/agents/research/ |
| social | @ASFSocialBot | Social media, marketing, community | /workspace/agents/social/ |
| deploy | @ASFDeployBot | DevOps, deployment, infrastructure | /workspace/agents/deploy/ |
| sales | @ASFSalesBot | Sales outreach, customer communication | /workspace/agents/sales/ |
| product-owner | @AgentSaturdayASFBot | Product management, Jira, coordination | /workspace/agents/product-owner/ |

## 📋 How to Assign Stories to Agents

### Via Telegram
Send a message to the appropriate bot with the story details:
```
@ASFResearchBot Please work on ASF-25: Research competitor security frameworks
```

Or use the main agent to delegate:
```
@jeffsutherlandbot Assign ASF-25 to the research agent and have them document findings in Jira
```

### Story Assignment Best Practices
- **Be specific** - Include the Jira ticket number (e.g., ASF-25)
- **Set expectations** - Mention deliverables and deadlines
- **Request updates** - Ask for hourly status reports

Example:
```
@ASFDeployBot Work on ASF-30: Docker security hardening
- Update the Dockerfile with security best practices
- Test the changes
- Document in Jira with hourly updates
- Notify me when complete
```

## 📝 Documenting Work in Jira

### Agents Can Update Jira Directly
Each agent has access to Jira via the configured API. They can:
- Add comments to existing tickets
- Update status (To Do → In Progress → Done)
- Log work time
- Attach deliverables

### Request Jira Updates
Ask any agent:
```
Update Jira ASF-25 with your current progress
```

Or:
```
Add a comment to ASF-25: "Completed initial research phase. Found 3 key competitors."
```

### Jira Configuration
| Setting | Value |
|---------|-------|
| Jira URL | https://frequencyfoundation.atlassian.net |
| Project | ASF |
| Config Location | /home/node/.jira-config (in Docker) |

## ⏰ Hourly Status Reports

### Request Hourly Updates
Tell agents to report hourly:
```
@ASFResearchBot Work on ASF-25 and provide hourly status updates in Jira
```

### Automated Status Format
Agents will post updates like:
```
📊 Hourly Status Update - ASF-25
Time: 2026-02-18 11:00 ET
Progress:
- Completed competitor analysis (3/5 companies)
- Drafted comparison matrix
Next Hour:
- Finish remaining 2 companies
- Write executive summary
Blockers: None
Hours Logged: 1h
```

### Check All Agent Status
Ask the main agent:
```
@jeffsutherlandbot Give me a status report on all active stories across all agents
```

## 🔄 Workflow Example

1. **Create/Assign Story**
   ```
   @jeffsutherlandbot Create a new Jira story: "Implement voice chat for Zoom meetings"
   Assign to deploy agent, priority High
   ```

2. **Agent Starts Work**
   The deploy agent will:
   - Pick up the story
   - Set status to "In Progress"
   - Begin implementation

3. **Hourly Updates**
   Agent posts to Jira every hour with progress

4. **Completion**
   Agent:
   - Sets status to "Done"
   - Adds final comment with deliverables
   - Notifies you via Telegram

## 🎯 Agent Specializations

| Agent | Best For |
|-------|----------|
| research | Market research, documentation, analysis, writing reports |
| social | Twitter/X posts, LinkedIn content, Moltbook posts, community engagement |
| deploy | Docker, infrastructure, CI/CD, security hardening, deployment |
| sales | Customer outreach, pitch decks, proposals, follow-ups |
| product-owner | Sprint planning, backlog grooming, stakeholder communication |
| main | General tasks, coordination, anything not specialized |

## 📞 Quick Commands

**Status Check**
```
@jeffsutherlandbot What are all agents working on right now?
```

**Reassign Work**
```
@jeffsutherlandbot Move ASF-25 from research to deploy agent
```

**Sprint Overview**
```
@AgentSaturdayASFBot Give me the current sprint status with all stories and assignees
```

**Emergency Stop**
```
@jeffsutherlandbot Stop all agents and report current state
```

## 🔧 Troubleshooting

### Agent Not Responding
Check Docker container:
```
docker logs openclaw-gateway
```
Restart if needed:
```
cd /Users/jeffsutherland/clawd/ASF-15-docker
docker-compose -f docker-compose.yml -f docker-compose.security.yml restart openclaw
```

### Jira Updates Failing
- Check Jira API token is valid
- Verify story exists in ASF project
- Ask agent: "What error did you get updating Jira?"

### Agent Can't Access Files
- Ensure file is in /workspace/ (mounted from ~/clawd)
- Check file permissions

## 📁 Key File Locations

| Resource | Location |
|----------|----------|
| Agent workspaces | /workspace/agents/<name>/ |
| Jira config | /home/node/.jira-config |
| API keys | /home/node/.openclaw/agents/<name>/agent/auth-profiles.json |
| Logs | docker logs openclaw-gateway |

## 🚀 Getting Started Today

1. Open Telegram and message @jeffsutherlandbot
2. Say: "Hi, what stories are currently in the ASF backlog?"
3. Assign work: "Please have the research agent work on ASF-XX with hourly Jira updates"
4. Monitor: Check Jira or ask for status updates via Telegram

Good luck managing the team! 🎉

— Copilot