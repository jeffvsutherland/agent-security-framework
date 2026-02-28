# ASF-40: Multi-Agent Supervisor Pattern

## Open-Claw / Clawdbot / Moltbot Integration

| Component | ASF-40 Supervisor Role | One-command activation |
|-----------|------------------------|---------------------|
| Open-Claw host | Oversees all containers (trust + syscall) | ./start-supervisor.sh --openclaw |
| Clawdbot (WhatsApp) | Monitors skills in real-time, quarantines low-trust | ./start-supervisor.sh --clawbot |
| Moltbot (PC-control) | Gates voice/PC commands via ASF-41/42 | ./start-supervisor.sh --moltbot |

## Activation
./start-supervisor.sh --full
