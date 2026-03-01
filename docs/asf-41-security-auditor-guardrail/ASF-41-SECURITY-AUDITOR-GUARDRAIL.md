## Open-Claw / Clawdbot / Moltbot Integration

| Component | Role in Stack | One-command activation | Ties to Other ASF |
|------------------------|-------------------------------------------------|-------------------------------------------------|-------------------|
| Open-Claw host | Full isolation + trust baseline | ./full-asf-40-43-secure.sh --openclaw | ASF-35 / ASF-38 |
| Clawdbot (WhatsApp) | Skill monitoring + localhost bridge | ./full-asf-40-43-secure.sh --clawbot | ASF-41 / ASF-5 |
| Moltbot (PC-control) | Voice/PC commands gated by guardrail | ./full-asf-40-43-secure.sh --moltbot | ASF-42 / ASF-40 |

---

# ASF-41: Security Auditor Guardrail

**Story:** Implement pre-action security guardrail that audits all agent actions before execution

## Description
Guardrail intercepts all agent actions and runs security checks before allowing execution.

## Integration

## Open-Claw / Clawdbot / Moltbot Integration

| Component | Role in Stack | One-command activation | Ties to Other ASF |
|------------------------|-------------------------------------------------|-------------------------------------------------|-------------------|
| Open-Claw host | Full isolation + trust baseline | ./full-asf-40-43-secure.sh --openclaw | ASF-35 / ASF-38 |
| Clawdbot (WhatsApp) | Skill monitoring + localhost bridge | ./full-asf-40-43-secure.sh --clawbot | ASF-41 / ASF-5 |
| Moltbot (PC-control) | Voice/PC commands gated by guardrail | ./full-asf-40-43-secure.sh --moltbot | ASF-42 / ASF-40 |

---

## Deliverables
1. Guardrail script
2. Security check hooks
3. Integration with supervisor (ASF-40)

## Acceptance Criteria
- [x] Pre-action security checks
- [x] Block unsafe actions
- [x] Integration with ASF-40 supervisor
