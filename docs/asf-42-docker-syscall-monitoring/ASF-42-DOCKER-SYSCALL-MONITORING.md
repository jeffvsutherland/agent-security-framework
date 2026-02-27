# ASF-42: Docker Syscall Monitoring

## Open-Claw / Clawdbot / Moltbot Integration

| Agent | ASF-42 Syscall Monitor | One-command activation |
|-------|------------------------|-----------------------|
| Open-Claw | trace mount/execve/ptrace/host-fs | ./enable-syscall-monitor.sh --openclaw |
| Clawdbot | WhatsApp bridge localhost only | ./enable-syscall-monitor.sh --clawbot |
| Moltbot | PC-control & voice commands | ./enable-syscall-monitor.sh --moltbot |

## Overview

ASF-42 implements runtime security monitoring for Docker containers using syscall tracing. This detects malicious activity in real-time including:
- File system attacks (mount, write to host)
- Process injection (execve, ptrace)
- Network suspicious activity
- Privilege escalation attempts

## Components

### Syscall Monitor (Falco/bpftrace)
- Real-time syscall capture
- Rule-based alerting
- Discord/Telegram notifications

### Integration with ASF-38 (Trust Framework)
- Triggers trust score recalculation on suspicious activity
- Auto-quarantine on high-severity alerts

## Usage

### Enable for Open-Claw
```bash
cd ~/agent-security-framework/docs/asf-42-docker-syscall-monitoring
./enable-syscall-monitor.sh --openclaw
```

### Enable for Clawdbot
```bash
./enable-syscall-monitor.sh --clawbot
```

### Enable for Moltbot
```bash
./enable-syscall-monitor.sh --moltbot
```

### Full Deployment
```bash
./enable-syscall-monitor.sh --full
```

## Alert Rules

| Severity | Syscall | Action |
|----------|---------|--------|
| CRITICAL | mount | Immediate quarantine |
| CRITICAL | ptrace | Immediate quarantine |
| HIGH | execve (suspicious) | Alert + log |
| MEDIUM | host-fs access | Alert only |

## Related ASF Stories
- ASF-38: Agent Trust Framework (trust scores)
- ASF-41: Security Auditor Guardrail
- ASF-35: OpenClaw Security

## DoD Checklist
- [ ] Syscall monitor installed
- [ ] Rules configured for all agents
- [ ] Discord/Telegram alerts working
- [ ] Integration with ASF-38 trust framework
- [ ] Tested on .openclaw
