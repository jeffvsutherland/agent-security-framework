# Autonomous Scrum Team Setup Guide

## The Problem: Context Bloat

When autonomous agents run 24/7 in long sessions, they hit context limits and get "dumber." A 150K context window fills up fast when every conversation is stored.

**Symptoms:**
- Agent performance degrades over time
- Responses become generic
- Costs increase with context size
- Team coordination fails

## The Solution: Orchestrator Architecture

### Core Principle
**You are the orchestrator. Subagents execute. Your main session stays lean.**

### Architecture Components

#### 1. Lean Main Session (<30K context)
- Read external state, don't remember everything
- Make decisions, delegate work
- Spawn subagents for heavy lifting
- Update external files, don't store in-context

#### 2. External Memory System
```
BRAIN.md    → Current context, active tasks, blockers
MEMORY.md   → Long-term decisions, learnings, team info
daily/      → What happened each day
```

#### 3. Subagent Spawning
```python
# Spawn fresh subagent for heavy work
subagent.spawn(
    task="Build the website component",
    context={"requirements": "...", "files": ["..."]},
    timeout=300
)
# Subagent gets fresh context
# Work happens in isolation
# Results reported back, context dies
```

#### 4. Optimized Heartbeats
- Fast: <3 seconds per check
- Lean: Only read status, don't load files unless idle
- External: Write to BRAIN.md, don't remember

### Implementation Steps

#### Step 1: Set Up External Memory
Create these files:
- `BRAIN.md` - Current session state
- `MEMORY.md` - Long-term memory  
- `memory/YYYY-MM-DD.md` - Daily logs

#### Step 2: Update SOUL.md
Add orchestrator directive:
```
### Your Role: Orchestrator
**Core Rule:** You orchestrate. Subagents execute. Never do in-context what can be delegated externally.
```

#### Step 3: Configure Heartbeats
```python
def heartbeat():
    # Fast check - read BRAIN.md only
    state = read_file("BRAIN.md", lines=20)
    
    # Make decisions
    if state.needs_work:
        spawn_subagent(state.top_task)
    
    # Write update - don't remember
    append_file("BRAIN.md", f"Last update: {now()}")
```

#### Step 4: Set Up Subagent Spawning
Use OpenClaw's subagent system:
```
/spawn agentId=developer task="Build X" timeout=300
```

#### Step 5: Define Protocol
- All work visible on Scrum board (Mission Control)
- Hourly heartbeats in external files
- Subagents report back, then context dies
- Never store history in main session

### Files You Need

| File | Purpose | Read Frequency |
|------|---------|----------------|
| SOUL.md | Identity, directives | On wake |
| BRAIN.md | Current context | Every decision |
| MEMORY.md | Long-term | Daily review |
| Daily logs | What happened | Weekly review |

### The Golden Rules

1. **Never let context grow past 30K**
2. **Everything important → external file**
3. **Heavy work → spawn subagent**
4. **Heartbeats → fast and lean**
5. **When in doubt, delegate**

### Benefits

- ✅ Consistent agent performance
- ✅ Lower costs (less context = fewer tokens)
- ✅ Better team coordination
- ✅ Scalable to many agents
- ✅ New team members can read state instantly

### Real Example: Our Setup

```
Main Session (Raven)
├── BRAIN.md (current context - 20 lines)
├── MEMORY.md (long-term - updated weekly)
├── Subagents (spawned for work)
│   ├── Sales Agent (ASF-26)
│   ├── Main Agent (ASF-27)
│   └── Deploy Agent (infrastructure)
└── Mission Control (Scrum board)

Main session context: ~25K tokens
Subagent context: Fresh each time
Total team context: Distributed, not bloated
```

### Troubleshooting

**Problem:** Agent keeps loading history
**Fix:** Update SOUL.md with "read BRAIN.md, not history"

**Problem:** Heartbeats too slow
**Fix:** Only read 20 lines of BRAIN.md, don't load full files

**Problem:** Subagents not returning results
**Fix:** Set clear reporting format in spawn command

## Resources

- Mission Control: http://localhost:3001
- OpenClaw docs: /app/docs
- Community: https://discord.com/invite/clawd

---
*Last updated: February 21, 2026*
*This guide is open source - share freely!*