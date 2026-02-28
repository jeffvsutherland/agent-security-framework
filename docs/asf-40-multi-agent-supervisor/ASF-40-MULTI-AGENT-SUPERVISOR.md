# ASF-40: Multi-Agent Supervisor Pattern

## Open-Claw / Clawdbot / Moltbot Integration

| Component | ASF-40 Supervisor Role | ASF-43 White Paper Highlight | One-command activation |
|------------------------|-------------------------------------------------|--------------------------------------------------|-------------------------------------------------|
| Open-Claw host | Oversees all containers (trust + syscall) | "ASF's supervisor + guardrail beats CrewAI" | ./start-supervisor.sh --openclaw |
| Clawdbot (WhatsApp) | Monitors skills in real-time, quarantines low-trust | "Zero-trust bridge vs AutoGPT prompt injection" | ./start-supervisor.sh --clawbot |
| Moltbot (PC-control) | Gates voice/PC commands via ASF-41/42 | "Production-grade isolation not in LangChain" | ./start-supervisor.sh --moltbot |

## Overview

ASF-40 implements a multi-agent supervisor pattern that orchestrates Clawdbot and Moltbot under ASF-38 trust scoring, ASF-41 guardrail, and ASF-42 syscall monitoring.

## Usage

```bash
./start-supervisor.sh --full
```
