# ASF-40: Multi-Agent Supervisor Pattern

## Open-Claw / Clawdbot / Moltbot Integration

| Component | ASF-40 Supervisor Role | One-command activation |
|-----------|------------------------|---------------------|
| Open-Claw host | Oversees all containers (trust + syscall) | ./start-supervisor.sh --openclaw |
| Clawdbot (WhatsApp) | Monitors skills in real-time, quarantines low-trust | ./start-supervisor.sh --clawbot |
| Moltbot (PC-control) | Gates voice/PC commands via ASF-41/42 | ./start-supervisor.sh --moltbot |

## Overview

ASF-40 implements a multi-agent supervisor pattern that orchestrates Clawdbot and Moltbot under ASF-38 trust scoring, ASF-41 guardrail, and ASF-42 syscall monitoring.

## Usage

```bash
./start-supervisor.sh --full
```
