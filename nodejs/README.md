# ASF Docker Template - Node.js

## Overview
Secure Node.js container for running untrusted AI agent skills with credential theft protection.

## Features
- Non-root user execution
- Credential environment variable blocking
- Filesystem access restrictions
- NPM security hardening
- Read-only skill volume mounts

## Files
- `Dockerfile` - Secure Node.js container
- `block_credentials.js` - Credential theft prevention module

## Quick Start

```bash
# Build
docker build -t asf-skill-nodejs .

# Run skill
docker run -v /path/to/skill:/skill:ro asf-skill-nodejs node /skill/index.js
```

## Docker Compose Integration

```yaml
services:
  nodejs-skill:
    build: 
      context: ./nodejs
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
      - NODE_ENV=production
      - NPM_CONFIG_CACHE=/tmp/npm-cache
    healthcheck:
      test: ["CMD", "node", "-e", "console.log('ok')"]
      interval: 30s
      timeout: 10s
      retries: 3
```

## Security Notes

### NPM Hardening
```json
// package.json security section
{
  "scripts": {
    "preinstall": "npm audit --audit-level=moderate"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

```ini
# .npmrc
engine-strict=true
audit=true
audit-level=moderate
fund=false
```

### Environment Blocking
The following patterns are blocked:
- `*KEY*`, `*SECRET*`, `*TOKEN*`, `*PASSWORD*`
- `*CREDENTIAL*`, `*API_KEY*`, `*AUTH*`

### Filesystem Restrictions
Blocked paths:
- `/root/*`
- `/home/*`
- `/etc/passwd`, `/etc/shadow`

### Best Practices
1. Always mount skills as read-only: `/skill:ro`
2. Run as non-root: `USER skilluser`
3. Use production mode: `NODE_ENV=production`
4. Audit dependencies: `npm audit`
5. Use minimal base image: `node:20-alpine`

## Alpine-based Build (Recommended)

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --production

FROM node:20-alpine
RUN addgroup -g 1000 skilluser && adduser -u 1000 -G skilluser -s /bin/sh -D skilluser
USER skilluser
WORKDIR /skill
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "index.js"]
```

## Verification

```bash
# Test credential blocking
docker run asf-skill-nodejs node -e "console.log(process.env.API_KEY)"
# Should return: undefined (blocked)

# Test filesystem blocking
docker run asf-skill-nodejs node -e "require('fs').readFileSync('/etc/passwd')"
# Should throw: Error: ASF Security: Blocked access to /etc/passwd
```

---

**Story:** ASF-2  
**Status:** Ready for Review  
**Version:** 1.0.0
