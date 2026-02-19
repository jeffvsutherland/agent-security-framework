# Jira Access Solution for Agents

## Current Situation
Sales Agent (and likely all agents) lack Jira access, blocking their ability to update stories.

## Found Configuration
Location: `/home/node/.jira-config`
```
JIRA_URL="https://frequencyfoundation.atlassian.net"
JIRA_USER="jeff.sutherland@gmail.com"
JIRA_PROJECT="ASF"
```

## Options:

### Option 1: Share Credentials (Quick Fix)
- Copy `.jira-config` to each agent's workspace
- All agents use Jeff's account
- Pros: Immediate access
- Cons: No individual accountability, security risk

### Option 2: Create Agent Accounts (Proper Solution)
- Create individual Jira accounts for each agent
- Grant project permissions
- Each agent gets own credentials
- Pros: Accountability, security, audit trail
- Cons: Takes time to set up

### Option 3: API Token Approach
- Create service account for agents
- Generate API token
- Share with all agents
- Pros: Better than personal credentials
- Cons: Still shared access

## Recommendation
Start with Option 1 for immediate unblocking, then migrate to Option 2 for long-term security and accountability.

---
*This access issue partially explains the "idle" state - agents couldn't update Jira even if they wanted to!*