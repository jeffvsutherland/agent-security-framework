# Mission Control Integration for Code Review Process

## Workflow Integration

The ASF Mandatory Code Review Process integrates seamlessly with our existing Mission Control board workflow.

### Status Flow with Reviews

```
┌─────────┐    ┌─────────────┐    ┌─────────┐    ┌──────┐
│  Inbox  │───►│ In Progress │───►│ Review  │───►│ Done │
└─────────┘    └─────────────┘    └─────────┘    └──────┘
                       ▲                │
                       │                │
                       └────────────────┘
                      (Review Feedback)
```

### Mission Control Comment Examples

#### 1. Moving to Review (Developer)

**API Call:**
```bash
curl -X PATCH -H "Authorization: Bearer [TOKEN]" \
-H "Content-Type: application/json" \
"http://openclaw-mission-control-backend-1:8000/api/v1/boards/[BOARD_ID]/tasks/[TASK_ID]" \
-d '{
  "status": "review",
  "comment": "Moving to review. Ready for:\n- [ ] Peer review\n- [ ] Security review\n- [ ] Product Owner review\n\nDeliverables:\n- gateway-wrapper-v2.sh\n- integration-tests.py\n- documentation.md\n\nTesting: Manually tested keychain integration\nSelf-review: Complete ✅"
}'
```

#### 2. Peer Review Response (Reviewer)

**Approval:**
```bash
curl -X POST -H "Authorization: Bearer [TOKEN]" \
-H "Content-Type: application/json" \
"http://openclaw-mission-control-backend-1:8000/api/v1/boards/[BOARD_ID]/tasks/[TASK_ID]/comments" \
-d '{
  "message": "REVIEW: Approve\nReviewer: Research Agent\nType: Peer Review\n\n✅ Code logic is sound\n✅ Error handling implemented\n✅ Integration approach correct\n✅ No breaking changes identified\n\nReady for Security Review"
}'
```

**Request Changes:**
```bash
curl -X PATCH -H "Authorization: Bearer [TOKEN]" \
-H "Content-Type: application/json" \
"http://openclaw-mission-control-backend-1:8000/api/v1/boards/[BOARD_ID]/tasks/[TASK_ID]" \
-d '{
  "status": "in_progress",
  "comment": "REVIEW: Request Changes\nReviewer: Research Agent\nType: Peer Review\n\nChanges needed:\n- [ ] Add input validation on line 45\n- [ ] Handle edge case when keychain is empty\n- [ ] Update documentation for new parameters\n\nMoving back to In Progress"
}'
```

#### 3. Security Review (Deploy/Research Agent)

```bash
curl -X POST -H "Authorization: Bearer [TOKEN]" \
-H "Content-Type: application/json" \
"http://openclaw-mission-control-backend-1:8000/api/v1/boards/[BOARD_ID]/tasks/[TASK_ID]/comments" \
-d '{
  "message": "REVIEW: Approve\nReviewer: Deploy Agent\nType: Security Review\n\n✅ No hardcoded credentials found\n✅ Keychain integration secure\n✅ File permissions appropriate\n✅ System access properly scoped\n\nSecurity approved. Ready for Product Owner Review"
}'
```

#### 4. Product Owner Review (Raven)

```bash
curl -X PATCH -H "Authorization: Bearer [TOKEN]" \
-H "Content-Type: application/json" \
"http://openclaw-mission-control-backend-1:8000/api/v1/boards/[BOARD_ID]/tasks/[TASK_ID]" \
-d '{
  "status": "done",
  "comment": "REVIEW: Approve\nReviewer: Raven\nType: Product Owner Review\n\n✅ Acceptance criteria met\n✅ Prevents keychain bypass issues\n✅ Documentation complete\n✅ Ready for deployment\n\nMoving to Done"
}'
```

## Automation Helpers

### Review Status Checker Script

```bash
#!/bin/bash
# check-review-status.sh
# Check which stories are waiting for review

BOARD_ID="24394a90-a74e-479c-95e8-e5d24c7b4a40"
AUTH_TOKEN="Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"

echo "📋 Stories Waiting for Review:"
echo "─────────────────────────────────"

curl -s -H "Authorization: $AUTH_TOKEN" \
"http://openclaw-mission-control-backend-1:8000/api/v1/boards/$BOARD_ID/tasks?status=review" | \
python3 -c "
import json, sys
data = json.load(sys.stdin)
items = data.get('items', [])
for item in items:
    print(f'🔍 [{item[\"title\"][:50]}...]')
    print(f'   Assigned: {item.get(\"assigned_agent_id\", \"unassigned\")}')
    print(f'   Priority: {item[\"priority\"]}')
    print()
if not items:
    print('✅ No stories waiting for review')
"
```

### Review SLA Monitor

```python
#!/usr/bin/env python3
# review-sla-monitor.py
# Monitor review SLAs and send alerts

import requests
import json
from datetime import datetime, timedelta

def check_review_slas():
    board_id = "24394a90-a74e-479c-95e8-e5d24c7b4a40"
    headers = {
        "Authorization": "Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM"
    }
    
    # Get stories in review
    url = f"http://openclaw-mission-control-backend-1:8000/api/v1/boards/{board_id}/tasks?status=review"
    response = requests.get(url, headers=headers)
    stories = response.json().get('items', [])
    
    now = datetime.now()
    overdue = []
    
    for story in stories:
        updated_at = datetime.fromisoformat(story['updated_at'].replace('Z', '+00:00'))
        age_hours = (now - updated_at).total_seconds() / 3600
        
        # Check SLA based on review type needed
        if age_hours > 24:  # Product Owner SLA
            overdue.append({
                'title': story['title'],
                'age_hours': age_hours,
                'type': 'Product Owner Review'
            })
        elif age_hours > 8:  # Security Review SLA
            overdue.append({
                'title': story['title'], 
                'age_hours': age_hours,
                'type': 'Security Review'
            })
        elif age_hours > 4:  # Peer Review SLA
            overdue.append({
                'title': story['title'],
                'age_hours': age_hours, 
                'type': 'Peer Review'
            })
    
    if overdue:
        print("🚨 REVIEW SLA VIOLATIONS:")
        for item in overdue:
            print(f"   {item['title']} - {item['type']} overdue by {item['age_hours']:.1f} hours")
    else:
        print("✅ All reviews within SLA")

if __name__ == "__main__":
    check_review_slas()
```

## Agent Integration Examples

### For Agent Workspace Scripts

Add to your agent's workflow scripts:

```bash
# In your deployment/commit script
echo "📋 Pre-commit review checklist:"
echo "- [ ] Self-review complete"
echo "- [ ] Documentation updated"  
echo "- [ ] No credentials in code"
echo "- [ ] Testing performed"
echo ""
read -p "All checks complete? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "❌ Please complete review checklist before committing"
    exit 1
fi
```

### For Reviewers

```bash
# quick-review.sh [TASK_ID] [approve|changes]
#!/bin/bash
TASK_ID=$1
ACTION=$2
REVIEWER_NAME=$(whoami)

if [ "$ACTION" = "approve" ]; then
    MESSAGE="REVIEW: Approve\nReviewer: $REVIEWER_NAME\nType: Peer Review\n\n✅ Code reviewed and approved\nReady for next review stage"
else
    echo "Enter specific changes needed:"
    read -p "> " changes
    MESSAGE="REVIEW: Request Changes\nReviewer: $REVIEWER_NAME\nType: Peer Review\n\nChanges needed:\n- $changes\n\nMoving back to In Progress"
fi

# Post review comment
curl -X POST -H "Authorization: Bearer [TOKEN]" \
-H "Content-Type: application/json" \
"http://openclaw-mission-control-backend-1:8000/api/v1/boards/[BOARD_ID]/tasks/$TASK_ID/comments" \
-d "{\"message\": \"$MESSAGE\"}"
```

## Compliance Dashboard

### Daily Review Metrics

```python
def generate_review_metrics():
    """Generate daily metrics for review process compliance"""
    
    metrics = {
        'stories_completed_with_reviews': 0,
        'average_review_time_hours': 0,
        'sla_violations': 0,
        'review_types_completed': {
            'peer': 0,
            'security': 0,
            'product_owner': 0
        }
    }
    
    # Calculate metrics from Mission Control API
    # Implementation would query the API and analyze comment history
    
    return metrics
```

## Migration from Old Process

### Phase 1: Immediate (Starting Now)
- All new stories must follow review process
- Existing in-progress stories continue old way
- Review process documentation shared with team

### Phase 2: Full Enforcement (Within 1 week)
- ALL code changes require review
- SLA monitoring active
- Compliance dashboard deployed

### Phase 3: Optimization (Ongoing)
- Review process refinements based on team feedback
- Automation improvements
- Performance metrics tracking

---

**This integration ensures seamless adoption of the mandatory code review process within our existing Mission Control workflow.**