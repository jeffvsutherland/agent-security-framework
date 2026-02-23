# Bash Docker Template

## Overview
Secure Bash Docker image template for OpenClaw automation scripts and CLI tools.

## Dockerfile

```dockerfile
FROM debian:bookworm-slim

# Security: Use specific version
LABEL maintainer="ASF Team"
LABEL version="1.0"

# Install only essential packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        ca-certificates \
        jq \
        git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 1000 appgroup && \
    useradd -u 1000 -g appgroup -s /bin/bash -D appuser

# Set work directory
WORKDIR /app

# Copy scripts
COPY --chown=appuser:appgroup scripts/ ./scripts/
COPY --chown=appuser:appgroup entrypoint.sh .

# Make scripts executable
RUN chmod +x scripts/*.sh entrypoint.sh

# Security: Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD bash -c '[[ -f /app/health.sh ]] && /app/health.sh || exit 1'

# Entry point
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["--help"]
```

## .dockerignore

```
*.md
.git
.gitignore
.env
*.log
tests/
```

## docker-compose.yml Example

```yaml
services:
  asl-cli:
    build: ./bash
    user: "1000:1000"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    volumes:
      - ./scripts:/app/scripts:ro
      - ~/.aws:/home/appuser/.aws:ro
    environment:
      - AWS_DEFAULT_REGION=us-east-1
```

## Script Example

```bash
#!/bin/bash
set -euo pipefail

echo "ASF CLI Tool v1.0"
echo "-----------------"

case "${1:-}" in
    deploy)
        echo "Deploying..."
        ;;
    status)
        echo "Checking status..."
        ;;
    --help|-h)
        echo "Usage: $0 {deploy|status}"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        exit 1
        ;;
esac
```

## Security Best Practices

| Practice | Implementation |
|----------|---------------|
| Non-root user | USER 1000:1000 |
| Read-only filesystem | read_only: true |
| Drop capabilities | cap_drop: ALL |
| No new privileges | no-new-privileges:true |
| Minimal base image | debian:bookworm-slim |
| Error handling | set -euo pipefail |
| Shellcheck | Run shellcheck on all scripts |

## Shellcheck Integration

```dockerfile
RUN apt-get update && apt-get install -y shellcheck
```

## Related Documents
- [ASF-2 Main README](./README.md)
- [ASF-5 YARA Rules](../docs/asf-5-yara-rules/)
- [ASF-4 Deployment Guide](../deployment-guide/)

---
*Last Updated: 2026-02-21*
