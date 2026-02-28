# ASF-43: White Paper - ASF vs Other Security Frameworks

## Open-Claw / Clawdbot / Moltbot Integration

| Component | ASF-40 Supervisor Role | ASF-43 White Paper Highlight | One-command activation |
|------------------------|-------------------------------------------------|--------------------------------------------------|-------------------------------------------------|
| Open-Claw host | Oversees all containers (trust + syscall) | "ASF's supervisor + guardrail beats CrewAI" | ./start-supervisor.sh --openclaw |
| Clawdbot (WhatsApp) | Monitors skills in real-time, quarantines low-trust | "Zero-trust bridge vs AutoGPT prompt injection" | ./start-supervisor.sh --clawbot |
| Moltbot (PC-control) | Gates voice/PC commands via ASF-41/42 | "Production-grade isolation not in LangChain" | ./start-supervisor.sh --moltbot |

## Overview

Compares ASF (Agent Security Framework) against other security frameworks.

## Comparison

| Feature | ASF | LangChain | CrewAI | AutoGPT |
|---------|-----|-----------|--------|---------|
| Runtime protection | ✅ | ❌ | ❌ | ❌ |
| Trust scoring | ✅ | ❌ | ❌ | ❌ |
| Syscall monitoring | ✅ | ❌ | ❌ | ❌ |
| Scrum protocol | ✅ | ❌ | ❌ | ❌ |
| Supervisor pattern | ✅ | ❌ | ✅ | ❌ |
| Guardrail | ✅ | ❌ | ❌ | ❌ |

## Key Differentiators

- **ASF vs LangChain**: Production-grade isolation not in LangChain
- **ASF vs CrewAI**: Full supervisor + guardrail beats CrewAI
- **ASF vs AutoGPT**: Zero-trust bridge vs prompt injection

## DoD

- [ ] Complete comparison
- [ ] Business value defined
