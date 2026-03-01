## Open-Claw / Clawdbot / Moltbot Integration

| Component | Role in Stack | One-command activation | Ties to Other ASF |
|------------------------|-------------------------------------------------|-------------------------------------------------|-------------------|
| Open-Claw host | Full isolation + trust baseline | ./full-asf-40-43-secure.sh --openclaw | ASF-35 / ASF-38 |
| Clawdbot (WhatsApp) | Skill monitoring + localhost bridge | ./full-asf-40-43-secure.sh --clawbot | ASF-41 / ASF-5 |
| Moltbot (PC-control) | Voice/PC commands gated by guardrail | ./full-asf-40-43-secure.sh --moltbot | ASF-42 / ASF-40 |

---

# ASF-42: Docker Syscall Monitoring

**Story:** Implement syscall-level monitoring for Docker containers running agents

## Description
Monitor all syscalls from agent containers to detect malicious behavior at the kernel level.

## Integration

## Open-Claw / Clawdbot / Moltbot Integration

| Component | Role in Stack | One-command activation | Ties to Other ASF |
|------------------------|-------------------------------------------------|-------------------------------------------------|-------------------|
| Open-Claw host | Full isolation + trust baseline | ./full-asf-40-43-secure.sh --openclaw | ASF-35 / ASF-38 |
| Clawdbot (WhatsApp) | Skill monitoring + localhost bridge | ./full-asf-40-43-secure.sh --clawbot | ASF-41 / ASF-5 |
| Moltbot (PC-control) | Voice/PC commands gated by guardrail | ./full-asf-40-43-secure.sh --moltbot | ASF-42 / ASF-40 |

---

## Deliverables
1. Syscall monitoring script
2. Falco integration
3. Alert on suspicious syscalls

## Acceptance Criteria
- [x] Monitor container syscalls
- [x] Detect malicious behavior
- [x] Integration with ASF-40 supervisor
