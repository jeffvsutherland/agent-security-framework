# ASF-42: Docker Syscall Monitoring

## Open-Claw / Clawdbot / Moltbot Integration

| Agent | ASF-42 Syscall Monitor | One-command activation |
|-------|------------------------|-----------------------|
| Open-Claw | trace mount/execve/ptrace/host-fs | ./enable-syscall-monitor.sh --openclaw |
| Clawdbot | WhatsApp bridge localhost only | ./enable-syscall-monitor.sh --clawbot |
| Moltbot | PC-control & voice commands | ./enable-syscall-monitor.sh --moltbot |

## Overview

ASF-42 provides real-time syscall monitoring for container security.

## Usage

```bash
./enable-syscall-monitor.sh --full
```
