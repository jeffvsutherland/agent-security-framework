# ASF Docker Template - Python

## Overview
Secure Python container for running untrusted AI agent skills with credential theft protection.

## Features
- Non-root user execution
- Credential environment variable blocking
- Filesystem access restrictions
- Read-only skill volume mounts

## Files
- `Dockerfile` - Secure Python container
- `block_credentials.py` - Credential theft prevention module

## Quick Start

```bash
# Build
docker build -t asf-skill-python .

# Run skill
docker run -v /path/to/skill:/skill:ro asf-skill-python python /skill/main.py
```

## Docker Compose Integration

```yaml
services:
  python-skill:
    build: 
      context: ./python
      dockerfile: Dockerfile
    volumes:
      - ./skills:/skill:ro
      - ./data:/data
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    environment:
      - PYTHONDONTWRITEBYTECODE=1
      - PYTHONUNBUFFERED=1
    healthcheck:
      test: ["CMD", "python", "-c", "print('ok')"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Security Notes

### Environment Blocking
The following patterns are blocked:
- `*KEY*`, `*SECRET*`, `*TOKEN*`, `*PASSWORD*`
- `*CREDENTIAL*`, `*API_KEY*`, `*AUTH*`
- `*PRIVATE*`, `*ACCESS_TOKEN*`

### Filesystem Restrictions
Blocked paths:
- `/root/*`
- `/home/*`
- `/etc/passwd`, `/etc/shadow`
- `/etc/security/*`

### Best Practices
1. Always mount skills as read-only: `/skill:ro`
2. Run as non-root: `USER skilluser`
3. Use `read_only: true` in compose
4. Drop all capabilities: `cap_drop: [ALL]`
5. No new privileges: `no-new-privileges:true`

## Multi-stage Build (Advanced)

```dockerfile
# Build stage
FROM python:3.12-slim-bookworm AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --target=/deps -r requirements.txt

# Runtime stage
FROM gcr.io/distroless/python3-debian12
COPY --from=builder /deps /deps
COPY --from=builder /skill /skill
WORKDIR /skill
ENV PYTHONPATH=/deps
USER nonroot
CMD ["python", "main.py"]
```

## Verification

```bash
# Test credential blocking
docker run asf-skill-python python -c "import os; print(os.environ['API_KEY'])"
# Should raise: PermissionError: Blocked: Attempt to access credential API_KEY

# Test filesystem blocking  
docker run asf-skill-python cat /etc/shadow
# Should raise: PermissionError: Blocked: Access to /etc/shadow is not allowed
```

---

**Story:** ASF-2  
**Status:** Ready for Review  
**Version:** 1.0.0
