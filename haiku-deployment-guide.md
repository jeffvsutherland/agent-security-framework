# 🚨 EMERGENCY: Deploy Haiku NOW - $50/hr → $5/hr

## Current Crisis
- Burning: **$50/hour** = $1,200/day = $438,000/year
- Target: **$5/hour** = $120/day = $43,800/year
- Required: **90% reduction immediately**

## SOLUTION: One Command for All Agents

### Option 1: Global Override (Fastest)
```bash
# Run this in main session:
openclaw agent model --all claude-3-haiku-20240307
```

### Option 2: Per-Agent Commands
```bash
# For each agent:
openclaw agent model main-agent claude-3-haiku-20240307
openclaw agent model sales-agent claude-3-haiku-20240307
openclaw agent model deploy-agent claude-3-haiku-20240307
openclaw agent model research-agent claude-3-haiku-20240307
openclaw agent model social-agent claude-3-haiku-20240307
openclaw agent model product-owner claude-3-haiku-20240307
```

### Option 3: Via Configuration
Add to OpenClaw config:
```yaml
agents:
  default_model: claude-3-haiku-20240307
  model_overrides:
    security_tasks: claude-3-sonnet-20240229
    critical_thinking: claude-3-sonnet-20240229
```

## Model Pricing Comparison

| Model | Cost/1K tokens | Current Usage | New Usage | Savings |
|-------|----------------|---------------|-----------|----------|
| Opus | $0.015 | 100% | 5% | 95% |
| Sonnet | $0.003 | 0% | 15% | - |
| Haiku | $0.00025 | 0% | 80% | - |

## Immediate Actions

1. **NOW**: Deploy Haiku as default model
2. **Monitor**: Run `openclaw agent status --all` to confirm
3. **Track**: Check costs after 1 hour

## Expected Results
- Hour 1: $50 → $5 (90% reduction)
- Day 1: Save $1,080
- Week 1: Save $7,560
- Month 1: Save $32,400
- Year 1: Save $394,200

## Rollback (if needed)
```bash
openclaw agent model --all claude-3-opus-20240229
```

---
**This is the highest-impact entropy elimination possible. Every minute of delay costs $0.75!**