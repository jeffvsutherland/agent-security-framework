# ASF-23: Mission Control Board - Complete Specification

## 🛡️ Clawdbot ASF Security Framework – Mission Control Initiative

### Core Vision
A real-time, web-based Mission Control Dashboard where Clawdbot agents operate as a self-organizing squad with:
- Visible agent roster with roles, status, and SOUL profiles
- Shared Kanban mission queue (Inbox → Assigned → In Progress → Review → Done)
- Live feed of agent-to-agent communication
- Jarvis-style lead agent orchestration
- Full ASF security envelope: zero trust by design

## 📋 Complete Epic List

### Epic 1: Agent Discovery & Registration
- Story 1.1: Register agents with unique IDs and SOUL profiles
- Skills: mission_control:register_agent, mission_control:update_soul
- Tech: PostgreSQL + Prisma, unique agent JWT tokens

### Epic 2: Real-Time Status & Heartbeats
- Story 2.1: Send heartbeats and status updates
- Story 2.2: Color-coded status with 24/7 monitoring
- Skills: mission_control:send_heartbeat
- Tech: Socket.io, Redis for presence

### Epic 3: Shared Mission Queue & Self-Tasking
- Story 3.1: Shared Kanban board
- Story 3.2: One-click task claiming
- Skills: mission_control:list_tasks, claim_task, update_task_status
- Tech: BullMQ or Redis Streams, React DnD

### Epic 4: Inter-Agent Communication & Live Feed
- Story 4.1: Post comments, praise, refute, review
- Story 4.2: Searchable/filterable feed with @mentions
- Skills: mission_control:post_comment, send_message_to_agent
- Tech: Socket.io rooms + PostgreSQL

### Epic 5: Leadership & Orchestration Layer
- Story 5.1: Jarvis elevated privileges (create/reassign/pause)
- Story 5.2: Squad Commands panel for broadcasts
- Skills: mission_control:orchestrate_squad (lead-only)
- Tech: Role-based JWT scopes + Temporal.io workflows

### Epic 6: ASF Security & Hardening ⚠️ NON-NEGOTIABLE
- Story 6.1: Authenticate and audit every action
- Story 6.2: Kill-switches, permissions, full audit logs
- Skills: asf_auth:request_permission, asf_security:log_action
- Tech: mTLS/signed JWTs, encrypted Redis, WAF-style rate limiting

### Epic 7: SOUL Profiles & Visualization
- Story 7.1: Store and display agent SOUL profiles
- Skills: mission_control:get_soul, visualize_soul
- Tech: Nice card view UI

### Epic 8: 24/7 Resilience & Observability
- Story 8.1: Automatic reconnection and state recovery
- Tech: Redis persistence, Docker healthchecks, Grafana/Prometheus

## 🛠️ Technology Stack

| Layer | Tech | ASF Security Rationale |
|-------|------|------------------------|
| Frontend | Next.js 15 + Tailwind + shadcn/ui | Modern, secure, type-safe |
| Real-time | Socket.io v4 | Encrypted websockets |
| Backend | NestJS/Express + Prisma | Structured, validated inputs |
| Queue | BullMQ + Redis | Reliable task management |
| Database | PostgreSQL | ACID compliance for audits |
| Auth | ASF Auth + JWT + mTLS | Zero-trust architecture |
| Deploy | Docker Compose + Traefik | Isolated containers |

## 🚀 Implementation Priority

### Phase 1: Foundation (Jeff building now)
1. Basic agent registration & heartbeats
2. Jira integration for task visibility
3. Simple message feed

### Phase 2: Self-Organization
4. Kanban board with drag-drop
5. Task claiming & assignment
6. Inter-agent comments

### Phase 3: Security & Scale
7. Full ASF auth layer
8. Audit logging
9. Kill switches & rate limits
10. SOUL profile management

### Phase 4: Advanced Features
11. Jarvis orchestration
12. Temporal workflows
13. Metrics & monitoring

## 🎯 Success Metrics
- All agents visible in real-time
- Zero manual task assignment
- Complete audit trail
- 24/7 autonomous operation
- No security breaches