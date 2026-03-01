# Agent Security Framework - Website Content

## Open-Claw / Clawdbot / Moltbot Integration

| Component | Role on ASF Website | One-command activation | Ties to Core ASF |
|--------------------------|--------------------------------------------------|-------------------------------------------------|------------------|
| Open-Claw host | Full isolation showcase | ./full-asf-40-44-secure.sh --openclaw | ASF-35 / ASF-38 |
| Clawdbot (WhatsApp) | Skill monitoring + localhost bridge demo | ./full-asf-40-44-secure.sh --clawbot | ASF-41 / ASF-5 |
| Moltbot (PC-control) | Voice/PC command gating demo | ./full-asf-40-44-secure.sh --moltbot | ASF-42 / ASF-40 |

## Overview

The Agent Security Framework (ASF) provides comprehensive security for autonomous AI agents. ASF protects AI agents from emerging threats including prompt injection, skill-based attacks, and runtime vulnerabilities.

---

## Executive Summary

ASF is the **only** production-grade security framework for AI agents that provides:
- Real-time syscall monitoring
- Trust scoring with automated quarantine
- Pre-action guardrails
- Auto-remediation capabilities

---

## Key Features

| Feature | Description | Status |
|---------|-------------|--------|
| **ASF-42** | Runtime syscall monitoring | ✅ Active |
| **ASF-41** | Security auditor guardrail | ✅ Active |
| **ASF-38** | Trust framework with scoring | ✅ Active |
| **ASF-44** | Automated fix prompt generator | ✅ Active |
| **ASF-40** | Multi-agent supervisor | ✅ Active |
| **ASF-5** | YARA rule scanning | ✅ Active |

---

## Why ASF?

### The Problem

Traditional security tools miss 91% of AI agent threats (per Oathe.ai audit). Most frameworks only scan code - they don't monitor runtime behavior or detect instruction-layer attacks.

### The ASF Solution

ASF provides complete protection:

1. **Runtime Monitoring** - Detects container escape attempts, suspicious syscalls
2. **Trust Scoring** - Continuously evaluates agent reliability (Commitment, Courage, Focus, Openness, Respect)
3. **Guardrails** - Blocks untrusted actions before execution
4. **Auto-Remediation** - Generates fix prompts for any issues found

---

## Comparison

| Feature | ASF | LangChain | CrewAI | AutoGPT | Clawdex |
|---------|-----|-----------|--------|---------|---------|
| Runtime Monitoring | ✅ | ❌ | ❌ | ❌ | ❌ |
| Trust Scoring | ✅ | ❌ | ❌ | ❌ | ❌ |
| Pre-Action Guardrail | ✅ | ❌ | ❌ | ❌ | ❌ |
| Syscall Tracing | ✅ | ❌ | ❌ | ❌ | ❌ |
| Auto-Remediation | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## Security Score

Current ASF security score: **90/100**

---

## Components

### ASF-42: Syscall Monitoring
Detects and blocks container escape attempts in real-time.

### ASF-41: Guardrail
Pre-action validation blocks untrusted code execution.

### ASF-38: Trust Framework
Continuous scoring with automated quarantine for suspicious agents.

### ASF-44: Auto-Fix Generator
Generates agent-executable prompts to fix security issues.

---

## Use Cases

- **WhatsApp Bots** (Clawdbot) - Skill monitoring, localhost isolation
- **PC Control** (Moltbot) - Voice/PC command gating
- **Host Isolation** (Open-Claw) - Container security, trust baseline

---

## Get Started

1. Visit: https://github.com/jeffvsutherland/agent-security-framework
2. Run: `./full-asf-40-44-secure.sh`
3. Scan: `python3 asf-openclaw-scanner.py`

## Production-Ready Stack

For full production security on your New Jersey box (Clawdbot-Moltbot-Open-Claw), run the unified activation script after cloning the repo:

## Contact

For enterprise inquiries, contact the ASF team.

---

*Agent Security Framework - Protecting AI Agents*
