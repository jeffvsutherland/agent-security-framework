# ASF-TRUST Score Examples

## Sample Trust Scores (No Real Data)

### Clawdbot (WhatsApp Bridge)
| Skill | Trust Score | Status |
|-------|-------------|--------|
| send-message | 98 | ✅ SECURE |
| receive-media | 96 | ✅ SECURE |
| auth-refresh | 99 | ✅ SECURE |

### Moltbot (PC Control)
| Skill | Trust Score | Status |
|-------|-------------|--------|
| voice-command | 97 | ✅ SECURE |
| screen-capture | 95 | ✅ SECURE |
| keyboard-input | 94 | ⚠️ REVIEW |

### Open-Claw (Host)
| Component | Trust Score | Status |
|-----------|-------------|--------|
| gateway | 99 | ✅ SECURE |
| mission-control | 98 | ✅ SECURE |
| agent-runtime | 97 | ✅ SECURE |

## Score Thresholds

| Score Range | Action |
|-------------|--------|
| 95-100 | ✅ Execute normally |
| 80-94 | ⚠️ Require human approval |
| < 80 | 🔴 Quarantine + alert |

## Trust Factors

- YARA scan result (40%)
- Spam monitor history (20%)
- Code review passed (20%)
- Credential cleanliness (10%)
- Cryptographic signature (10%)

---
*Note: These are example values for documentation purposes.*
