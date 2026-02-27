# ASF-41: Security Auditor Guardrail

## Open-Claw / Clawdbot / Moltbot Integration

| Agent | ASF-41 Auditor Guardrail | One-command activation |
|-------|-------------------------|---------------------|
| Open-Claw | block if trust-score < 95 (ASF-38) | ./activate-guardrail.sh --openclaw |
| Clawdbot | enforce skill signature + YARA (ASF-5) | ./activate-guardrail.sh --clawbot |
| Moltbot | kill on anomaly (spam-monitor ASF-37) | ./activate-guardrail.sh --moltbot |

## Overview

ASF-41 implements a security guardrail that acts as a final checkpoint before any agent action is executed. It verifies:
- Trust score (ASF-38)
- Skill signature validity
- YARA scan results (ASF-5)
- Spam monitor status (ASF-37)

## Components

### Guardrail Script
- Pre-execution verification
- Automatic blocking of untrusted actions
- Audit logging

### Integration Points
- ASF-38 Trust Framework
- ASF-5 YARA Rules
- ASF-37 Spam Monitor

## Usage

### Activate for Open-Claw
```bash
cd ~/agent-security-framework/docs/asf-41-security-auditor-guardrail
./activate-guardrail.sh --openclaw
```

### Activate for Clawdbot
```bash
./activate-guardrail.sh --clawbot
```

### Activate for Moltbot
```bash
./activate-guardrail.sh --moltbot
```

### Full Activation
```bash
./activate-guardrail.sh --all-agents --enforce
```

## Trust Score Thresholds

| Score | Action |
|-------|--------|
| ≥ 95 | Execute normally |
| 80-94 | Require human approval |
| < 80 | Block + quarantine |

## Related ASF Stories
- ASF-38: Agent Trust Framework
- ASF-5: YARA Rules
- ASF-37: Spam Monitor
- ASF-42: Docker Syscall Monitoring

## DoD Checklist
- [ ] Guardrail script installed
- [ ] Trust score integration working
- [ ] YARA integration working
- [ ] Spam monitor integration working
- [ ] Tested on .openclaw
