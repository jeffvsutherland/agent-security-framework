# ASF-27: Message Board Implementation Plan
**Product Owner:** Raven (Agent Saturday)  
**Date:** February 18, 2026

## 🏁 Sprint Goal
**"All 6 ASF agents self-assign 90% of inbox tasks within 1 hour using the message board, with zero credential exposure."**

---

## 🎯 Objective
Implement Bhanu Teja's message board pattern for ASF multi-agent coordination.

## ✅ INVEST Criteria
- **Independent:** Each agent can post/read independently
- **Negotiable:** Message format is flexible per agent needs
- **Valuable:** Enables autonomous task assignment
- **Estimable:** ~8 hours total effort
- **Small:** Can ship after Phase 2
- **Testable:** Agents self-assign tasks without race conditions

## ✅ Definition of Done (DoD) Checklist
- [ ] Phase 1: Telegram channel created, file-based board working
- [ ] Phase 2: All agents posting/reading from board
- [ ] Phase 3: Security test (no credentials exposed)
- [ ] Rate limiting enforced (max 100 calls/day)
- [ ] Kill switch functional
- [ ] Outcome verified: 90% self-assignment within 1 hour
- [ ] Security scan passed (zero secrets in board messages)

## ✅ Security Acceptance Criteria
- [ ] No API keys in message board
- [ ] No credentials in log files
- [ ] Rate limiting prevents abuse
- [ ] Docker isolation verified
- [ ] Audit trail captures all actions

## 🏗️ Proposed Architecture

### 1. Agent Roles & Responsibilities

| Current Bot | New Role | Message Board Responsibilities |
|-------------|----------|-------------------------------|
| @jeffsutherlandbot | **Jarvis** (Coordinator) | • Orchestrate work<br>• Resolve conflicts<br>• Daily summaries |
| @AgentSaturdayASFBot | **Product Owner** (me) | • Manage backlog<br>• Define stories<br>• Accept work |
| @ASFSalesBot | **Creator-1** (Sales) | • Website content<br>• Marketing materials |
| @ASFDeployBot | **Executor-1** (Deploy) | • Infrastructure<br>• Security scans |
| @ASFSocialBot | **Creator-2** (Social) | • Social media<br>• Announcements |
| @ASFResearchBot | **Researcher-1** | • Analysis<br>• Documentation |

### 2. Message Board Structure

```
/asf-message-board/
├── announcements/      # Important updates
├── tasks/             # Work items from Jira
├── claims/            # Agents claiming tasks
├── reviews/           # Code/content reviews
├── status/            # Progress updates
└── discussions/       # Team conversations
```

### 3. Message Format

```markdown
[AGENT: Sales] [ACTION: CLAIM] [TASK: ASF-26]
I'm taking on the website creation task. ETA: 4 hours.

[AGENT: Deploy] [ACTION: REVIEW] [TASK: ASF-26]
Reviewed staging site. Security headers need adjustment. Details: ...

[AGENT: ProductOwner] [ACTION: ANNOUNCE]
New priority: ASF-28 created for security policy framework.
```

### 4. Implementation Steps

**Phase 1: Basic Setup (Deploy Agent)**
- Create Telegram channel "ASF-Squad-Board"
- Set up file-based message board in shared workspace
- Configure heartbeat polling (15-minute intervals)

**Phase 2: Agent Integration (Main Agent/Jarvis)**
- Update each agent's SOUL.md with board protocols
- Implement message posting/reading functions
- Add self-assignment logic

**Phase 3: Security & Controls (Deploy Agent)**
- Docker sandboxing for each agent
- Rate limiting (max 100 LLM calls/day per agent)
- Cost monitoring dashboard
- Kill switch implementation

## 🔐 Security Requirements

1. **Isolation**: Each agent in separate Docker container
2. **Permissions**: Read-only access to other agents' workspaces
3. **API Limits**: Enforced rate limiting
4. **Audit Trail**: All actions logged with timestamps
5. **Budget Control**: Auto-shutdown at 80% of daily budget

## 📊 Success Metrics

- All agents posting to board within 24 hours
- Zero manual task assignment needed
- 90% of tasks self-assigned within 1 hour
- Full audit trail of all agent actions
- Cost stays within budget limits

## 🚀 Recommended Next Steps

1. **Assign ASF-27 to Deploy Agent** for technical implementation
2. **Have Main Agent (Jarvis)** coordinate the rollout
3. **I'll create detailed soul.md updates** for each agent role
4. **Research Agent** can analyze similar implementations for best practices

## 🏁 Sprint Goal
All 6 ASF agents self-assign 90% of inbox tasks within 1 hour using the message board, with zero credential exposure.

## ✅ Definition of Done (DoD) – Mandatory (from memory.md)
- Code written, reviewed, integrated
- Automated tests pass (unit/integration + security scans)
- **Zero secrets** (APIs, passwords, emails, keys, tokens) – verified by scan; use env vars/GitHub Secrets only
- Documented
- Outcome validated against Sprint Goal
- CI/CD pipeline green and releasable

**Aligned with Clawdbot-Moltbot-Open-Claw Scrum Expansion Pack (soul/brain/memory.md sections)**
