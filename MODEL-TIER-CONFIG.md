# Model Tier Configuration - Cost Optimized

## Current Setup (February 21, 2026)

### Primary Model
- **Claude Sonnet 4** - Main workhorse
- Cost: ~$0.003/1K tokens
- Use: All standard operations

### Backup Model (NEW!)
- **Minimax** - 90% cheaper alternative
- Cost: ~$0.0003/1K tokens
- Use: Overflow, batch operations, simple tasks
- Feature: Self-throttling with hourly reset

### Fallback
- **Wait** - If Minimax throttles
- Reset: Automatic after 1 hour

## Cost Comparison

| Model | Cost/1K | Use Case |
|-------|---------|----------|
| Claude Opus | $0.015 | Reserved for critical only |
| Claude Sonnet | $0.003 | Primary - all standard work |
| **Minimax** | **$0.0003** | **Backup - 90% savings!** |
| Haiku | $0.00025 | Not available here |

## Usage Strategy

### Normal Operations
1. Use Claude Sonnet 4 for all work
2. No artificial limitations needed

### Overflow Handling
1. If Sonnet rate limited → Use Minimax
2. Track Minimax usage
3. If Minimax throttles → Wait 1 hour

### Cost Tracking
- Monitor both API calls
- Track Minimax throttle events
- Optimize based on actual usage

## Agent Assignments

| Agent | Primary | Backup |
|-------|---------|--------|
| Product Owner | Sonnet | Minimax |
| Main Agent | Sonnet | Minimax |
| Sales Agent | Sonnet | Minimax |
| Deploy Agent | Sonnet | Minimax |
| Research Agent | Sonnet | Minimax |
| Social Agent | Sonnet | Minimax |

## Expected Monthly Costs

- All Sonnet: ~$10-15K/month
- Mixed Minimax: ~$2-5K/month (90% savings!)
- With throttle: Self-regulating

---
*Smart cost management: Quality when needed, savings when possible*