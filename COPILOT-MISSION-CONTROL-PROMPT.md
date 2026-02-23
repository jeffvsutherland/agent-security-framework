# Prompt for Copilot: Enable Mission Control Access for Raven

## Problem
Raven (Product Owner agent) cannot access Mission Control from her Docker environment due to network isolation. This prevents her from:
- Reading/updating stories on the Scrum board
- Checking story status
- Moving stories between columns
- Adding comments for hourly updates

## What Raven Needs

### API Endpoint
```
http://host.docker.internal:8001/api/v1
```

### Board ID
```
24394a90-a74e-479c-95e8-e5d24c7b4a40
```

### Authentication
Every request needs this header:
```
Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM
```

### Commands Raven Needs to Run

1. **List all tasks:**
```bash
curl -s -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
"http://host.docker.internal:8001/api/v1/boards/24394a90-a74e-479c-95e8-e5d24c7b4a40/tasks"
```

2. **List inbox tasks:**
```bash
curl -s -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
"http://host.docker.internal:8001/api/v1/boards/24394a90-a74e-479c-95e8-e5d24c7b4a40/tasks?status=inbox"
```

3. **Update task status:**
```bash
curl -s -X PATCH -H "Authorization: Bearer HthMEQIXNRw8f1FHLVmVA1sIM8R+swsGADUzux3I6vp7357b2vzuPe5h7+dG5xMM" \
-H "Content-Type: application/json" \
"http://host.docker.internal:8001/api/v1/boards/24394a90-a74e-479c-95e8-e5d24c7b4a40/tasks/{TASK_ID}" \
-d '{"status": "in_progress", "assignee": "product-owner"}'
```

## Current Error
When Raven tries to connect, she gets:
```
Cannot connect
```

## Possible Solutions

### Option 1: Docker Network Configuration
Ensure the OpenClaw container can reach `host.docker.internal:8001`

Add to docker-compose or docker run:
```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

### Option 2: Expose Mission Control on Docker Network
Make sure Mission Control backend is accessible from other containers

### Option 3: Proxy Route
Set up a proxy in the OpenClaw gateway that routes to Mission Control

## Test Script Raven Will Run
```bash
curl -s -m 5 http://host.docker.internal:8001/health && echo "OK" || echo "FAIL"
```

## Expected Outcome
After fix, Raven should be able to:
1. List tasks in inbox, in_progress, review, done
2. Pick up top-priority stories
3. Update story status
4. Add comments for hourly updates
5. Complete Definition of Done workflow

## Priority
HIGH - Without this, Raven cannot perform Product Owner duties effectively.

---
*Requesting Copilot's assistance to resolve network connectivity*