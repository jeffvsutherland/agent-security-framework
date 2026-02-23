# Node.js Docker Template

## Overview
Secure Node.js Docker image template for OpenClaw Mission Control backend and agents.

## Dockerfile

```dockerfile
FROM node:18-alpine

# Security: Use specific version
LABEL maintainer="ASF Team"
LABEL version="1.0"

# Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -s /bin/sh -D appuser

# Install only essential packages
RUN apk add --no-cache \
        curl \
        ca-certificates

# Set work directory
WORKDIR /app

# Copy package files first for better caching
COPY package*.json ./
RUN npm ci --production --audit

# Copy application
COPY --chown=appuser:appgroup . .

# Security: Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Run application
CMD ["node", "index.js"]
```

## .dockerignore

```
node_modules/
npm-debug.log*
.env
.env.local
.git
.gitignore
*.md
tests/
coverage/
.DS_Store
```

## docker-compose.yml Example

```yaml
services:
  mission-control-backend:
    build: ./nodejs
    user: "1000:1000"
    read_only: true
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:8000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
    ports:
      - "8000:8000"
    volumes:
      - ./data:/app/data:ro
    environment:
      - NODE_ENV=production
      - PORT=8000
```

## Security Best Practices

| Practice | Implementation |
|----------|---------------|
| Non-root user | USER 1000:1000 |
| Read-only filesystem | read_only: true |
| Drop capabilities | cap_drop: ALL |
| No new privileges | no-new-privileges:true |
| Minimal base image | node:18-alpine |
| Production mode | npm ci --production |
| Security audit | npm ci --audit |

## Package.json Example

```json
{
  "name": "openclaw-mission-control",
  "version": "1.0.0",
  "description": "Mission Control Backend for OpenClaw",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "jest",
    "security:audit": "npm audit"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "devDependencies": {
    "nodemon": "^3.0.0",
    "jest": "^29.0.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

## Related Documents
- [ASF-2 Main README](./README.md)
- [ASF-3 Node Wrapper](../ASF-3-NODE-WRAPPER-GITHUB.md)
- [ASF-4 Deployment Guide](../deployment-guide/)

---
*Last Updated: 2026-02-21*
