# ASF-41: Security Auditor Guardrail

## Open-Claw / Clawdbot / Moltbot Integration

| Agent | ASF-41 Auditor Guardrail | One-command activation |
|-------|-------------------------|---------------------|
| Open-Claw | block if trust-score < 95 (ASF-38) | ./activate-guardrail.sh --openclaw |
| Clawdbot | enforce skill signature + YARA (ASF-5) | ./activate-guardrail.sh --clawbot |
| Moltbot | kill on anomaly (spam-monitor ASF-37) | ./activate-guardrail.sh --moltbot |

## Overview

ASF-41 implements a security guardrail that acts as a final checkpoint before any agent action is executed.

## Usage

```bash
./activate-guardrail.sh --all-agents --enforce
```
