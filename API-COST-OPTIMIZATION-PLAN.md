# API Cost Optimization Plan - Crushing Financial Entropy

## 🚨 Current Entropy: Light-Speed API Credit Burn

### Problem Analysis
- 6 agents making continuous API calls
- Using expensive models for simple tasks
- No caching or request pooling
- Redundant context reloading
- No cost visibility/tracking

## 📊 Immediate Actions (Today)

### 1. Model Tiering by Task Complexity
```
Tier 1 (Simple): Claude Haiku / GPT-3.5-turbo
- Status updates
- Heartbeats
- Simple queries
- File operations
Cost: ~$0.0003/1K tokens

Tier 2 (Standard): Claude Sonnet / GPT-4
- Code generation
- Complex analysis
- Decision making
Cost: ~$0.003/1K tokens

Tier 3 (Complex): Claude Opus / GPT-4-turbo
- Architecture decisions
- Security audits
- Critical thinking
Cost: ~$0.015/1K tokens
```

### 2. Batch Operations Protocol
- Combine multiple small tasks into single prompts
- Queue non-urgent requests for bulk processing
- Use state_manager.py to coordinate batches
- Target: 5:1 reduction in API calls

### 3. Aggressive Caching Strategy
```python
# Add to state_manager.py
class ResponseCache:
    def __init__(self, ttl=3600):
        self.cache = {}
        self.ttl = ttl
    
    def get_or_fetch(self, key, fetch_func):
        if key in self.cache and not self.is_expired(key):
            return self.cache[key]
        result = fetch_func()
        self.cache[key] = {'data': result, 'time': time.time()}
        return result
```

## 🎯 24-Hour Implementation Plan

### Hour 1-4: Configure Model Tiers
- Update agent configs with model selection logic
- Heartbeats → Haiku
- Routine tasks → GPT-3.5-turbo
- Complex work → Keep current models

### Hour 5-8: Implement Request Batching
- Modify state_manager.py for batch queuing
- Add 5-minute batch windows
- Combine related operations

### Hour 9-12: Deploy Caching Layer
- Cache common queries (file listings, status checks)
- Store responses for 1-hour TTL
- Skip redundant API calls

### Hour 13-16: Add Cost Tracking
```python
# Cost tracking in state_manager.py
def track_api_cost(model, tokens):
    costs = {
        'haiku': 0.00025,
        'gpt-3.5': 0.0005,
        'sonnet': 0.003,
        'gpt-4': 0.01,
        'opus': 0.015
    }
    cost = (tokens / 1000) * costs.get(model, 0.01)
    log_cost(cost)
    return cost
```

### Hour 17-24: Monitor & Optimize
- Track cost reduction metrics
- Identify remaining high-cost operations
- Fine-tune batching windows

## 💰 Expected Savings

| Current | Optimized | Reduction |
|---------|-----------|-----------|
| $500/day | $50/day | 90% |
| 100K API calls | 10K calls | 90% |
| All Opus/GPT-4 | Mixed tiers | 80% cost |

## 🔧 Long-Term Solutions

### 1. Local Model Integration
- Deploy Ollama for simple tasks
- Use for heartbeats, status checks
- Cost: $0 after setup

### 2. Subscription Models
- OpenAI Enterprise
- Anthropic Claude for Work
- Fixed monthly cost vs usage

### 3. Smart Context Management
- Compress conversation history
- Summarize instead of full context
- Reduce tokens per call by 70%

## 📈 Success Metrics
- Cost per story point
- API calls per hour
- Cache hit rate
- Model tier distribution

## 🚀 Implementation Priority
1. **NOW**: Switch heartbeats to Haiku
2. **TODAY**: Implement batching
3. **TOMORROW**: Deploy caching
4. **THIS WEEK**: Local models

---
*Every API call saved is money earned. This is entropy elimination at its finest.*