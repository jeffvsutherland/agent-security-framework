# Python Docker Template

## Overview
Secure Python Docker image template for OpenClaw agents and services.

## Dockerfile

```dockerfile
FROM python:3.11-slim

# Security: Use specific version
LABEL maintainer="ASF Team"
LABEL version="1.0"

# Create non-root user
RUN groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -s /bin/sh -D appuser

# Install only essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY --chown=appuser:appgroup . .

# Security: Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Run application
CMD ["python", "app.py"]
```

## .dockerignore

```
__pycache__
*.pyc
*.pyo
*.pyd
.Python
*.so
*.egg
*.egg-info
dist
build
.git
.gitignore
.env
*.md
tests/
venv/
.venv/
```

## docker-compose.yml Example

```yaml
services:
  python-agent:
    build: ./python
    user: "1000:1000"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
    volumes:
      - ./data:/app/data:ro
    environment:
      - NODE_ENV=production
```

## Security Best Practices

| Practice | Implementation |
|----------|---------------|
| Non-root user | USER 1000:1000 |
| Read-only filesystem | read_only: true |
| Drop capabilities | cap_drop: ALL |
| No new privileges | no-new-privileges:true |
| Minimal base image | python:3.11-slim |
| No cache | pip --no-cache-dir |

## Related Documents
- [ASF-2 Main README](./README.md)
- [ASF-5 YARA Rules](../docs/asf-5-yara-rules/)
- [Security Hardening](../docs/asf-5-yara-rules/SECURITY-HARDENING.md)

---
*Last Updated: 2026-02-21*
