# ASF-40: Multi-Agent Supervisor Pattern

## Open-Claw / Clawdbot / Moltbot Integration

| Component | ASF-40 Supervisor Role | One-command activation |
|------------------------|-------------------------------------------------|
| Open-Claw host | Oversees all containers (trust + syscall) | ./start-supervisor.sh --openclaw |
| Clawdbot (WhatsApp) | Monitors skills in real-time, quarantines low-trust | ./start-supervisor.sh --clawbot |
| Moltbot (PC-control) | Gates voice/PC commands via ASF-41/42 | ./start-supervisor.sh --moltbot |

## Overview

ASF-40 implements a supervisor pattern where one agent monitors and coordinates other agents.

## Scripts

```bash
# start-supervisor.sh - Launches supervisor that watches Clawdbot + Moltbot using ASF-38/41/42
./start-supervisor.sh --full
```

## DoD

- [ ] Supervisor pattern implemented
- [ ] Tested with Clawdbot-Moltbot
