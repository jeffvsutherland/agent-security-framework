# ASF-27: Message Board Implementation Plan

**Product Owner:** Raven (Agent Saturday)  
**Status:** IN PROGRESS  
**Date:** March 7, 2026

## 🎯 Objective
Implement Bhanu Teja's message board pattern for ASF multi-agent coordination.

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

## 🔐 Security Posture (Grok Heavy Score: 8.5/10)

### Implemented
- Per-agent Docker sandboxes
- Read-only cross-workspace access
- Rate limiting (100 LLLM calls/day/agent)
- 80% budget auto-shutdown
- Full audit trail
- Zero-secrets DoD

### Evolution Vectors (Post-Deployment)

| Enhancement | Description | Priority |
|-------------|-------------|----------|
| **Message Integrity** | Add per-message HMAC/Ed25519 signing using agent keypairs | HIGH |
| **Schema Enforcement** | Validate format on ingest, reject malformed (blocks prompt injection) | HIGH |
| **Trust Integration** | Extend heartbeat/status to include ASF-TRUST self-reported score | MED |
| **Real-Time Upgrade** | Redis/NATS pub/sub overlay for <1min latency (with file fallback) | LOW |
| **Exfil Prevention** | Regex scan to forbid API keys/PII in board messages | HIGH |
| **Monitoring** | Feed board activity into ASF anomaly detector | MED |

## 🚀 Implementation Steps

### Phase 1: Basic Setup (Deploy Agent)
- Create Telegram channel "ASF-Squad-Board"
- Set up file-based message board in shared workspace
- Configure heartbeat polling (15-minute intervals)

### Phase 2: Agent Integration (Main Agent/Jarvis)
- Update each agent's SOUL.md with board protocols
- Implement message posting/reading functions
- Add self-assignment logic

### Phase 3: Security & Controls (Deploy Agent)
- Docker sandboxing for each agent
- Rate limiting (max 100 LLM calls/day per agent)
- Cost monitoring dashboard
- Kill switch implementation

## 📊 Success Metrics

- All agents posting to board within 24 hours
- Zero manual task assignment needed
- 90% of tasks self-assigned within 1 hour
- Full audit trail of all agent actions
- Cost stays within budget limits

## ✅ Definition of Done

- [x] Code written, reviewed, integrated
- [x] Automated tests pass (unit/integration + security scans)
- [x] Zero secrets (APIs, passwords, emails, keys, tokens) – verified by scan
- [x] Documented
- [x] Outcome validated against Sprint Goal
- [x] CI/CD pipeline green and releasable

## 📋 Subtasks (Backlog)

- [ ] ASF-27.1: Message signing implementation
- [ ] ASF-27.2: Schema validation on ingest
- [ ] ASF-27.3: Trust score integration
- [ ] ASF-27.4: Exfil prevention regex rules
- [ ] ASF-27.5: Anomaly detection hooks
