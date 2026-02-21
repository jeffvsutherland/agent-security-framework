# State Manager Skill - Automated Protocol Compliance

## Purpose
Reduce entropy in state tracking and protocol compliance through automation.

## Core Script: state_manager.py

### Features:
1. **Automated Hourly Heartbeat**
   - Tracks: Done, Next, Blockers, Entropy Found
   - Updates MEMORY.md heartbeat section
   - Logs to heartbeat.log for Mission Control sync
   - Keeps only last 5 heartbeats (reduces clutter)

2. **Definition of Done Tracking**
   - Mark criteria as complete
   - Log completions with timestamps
   - Audit trail for compliance

3. **Entropy Metrics**
   - Calculate productive vs idle/blocked time
   - Track entropy percentage
   - Identify patterns of waste

## Usage:

### Basic Heartbeat Update:
```python
from state_manager import RavenState

raven = RavenState()
raven.update_heartbeat(
    done="Completed ASF-26 documentation",
    next_step="Review PR with team",
    blockers="None"
)
```

### With Entropy Tracking:
```python
raven.update_heartbeat(
    done="Set up email authentication",
    next_step="Test IMAP connection",
    blockers="Need app password from admin",
    entropy_found="Manual email checks wasting 30min/day"
)
```

### Check Entropy Level:
```python
entropy_percentage = raven.get_entropy_metrics()
# Shows productive vs wasted hours
```

### Mark DoD Complete:
```python
raven.mark_definition_of_done("ASF-26", criteria_index=1)
```

## Integration with Workflow:

1. **Pre-Sleep Routine**: Run before session timeout
   ```bash
   python state_manager.py
   ```

2. **Cron Schedule**: Set up hourly automation
   ```bash
   0 * * * * cd /workspace/agents/product-owner && python3 state_manager.py
   ```

3. **Mission Control Sync**: Read heartbeat.log for updates
   ```python
   with open("heartbeat.log") as f:
       latest = f.readlines()[-1]
       mission_control.update(json.loads(latest))
   ```

## Files Created:
- `state_manager.py` - Core automation script
- `heartbeat.log` - JSON log of all heartbeats
- `dod_completions.log` - Audit trail of DoD

## Entropy Reduction Impact:
- **Before**: Manual updates, often forgotten, no metrics
- **After**: Automated tracking, guaranteed compliance, entropy visibility
- **Savings**: 5-10 minutes per hour in manual tracking

---
*This skill embodies the entropy crusher mindset: automate repetitive tasks, measure everything, eliminate waste.*