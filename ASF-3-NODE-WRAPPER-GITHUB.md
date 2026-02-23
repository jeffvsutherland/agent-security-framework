# ASF-3: Node.js Wrapper for GitHub Actions

## Overview
This document describes the secure Node.js wrapper setup for GitHub Actions and CI/CD pipelines for OpenClaw Gateway and Mission Control deployments.

## Use Cases
- Secure build/publish for OpenClaw Gateway patches
- Automated testing on pull requests
- Provenance attestations for container images
- Non-root runner execution

## Prerequisites
```bash
node --version  # v18+
npm --version   # v9+
```

## Installation

### Secure npm install
```bash
# Use npm ci for deterministic builds
npm ci

# Or install with audit
npm ci --audit
```

## Security Scanning

### npm audit
```bash
# Run security audit
npm audit

# Fix vulnerabilities
npm audit fix
```

### Snyk Integration
```bash
# Install Snyk
npm install -g snyk

# Authenticate
snyk auth

# Test for vulnerabilities
snyk test

# Monitor for new vulnerabilities
snyk monitor
```

## GitHub Actions Example

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci --audit
        
      - name: Run tests
        run: npm test
        
      - name: Snyk vulnerability scan
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
          
      - name: Build container
        run: docker build -t openclaw .
        
      - name: Run container security scan
        run: |
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
          aquasec/trivy image openclaw:latest
```

## Provenance Attestations

### SLSA Compliance
```yaml
# Add to your GitHub workflow
- name: Generate provenance
  uses: slsa-framework/slsa-github-generator/generic-generator@v1
  with:
    artifact_name: openclaw.tar.gz
    digest: sha256:0000000000000000000000000000000000000000000000000000000000000000
```

## Non-Root Runner

### Dockerfile for non-root
```dockerfile
FROM node:18-alpine

# Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -s /bin/sh -D appuser

# Set ownership
COPY --chown=appuser:appgroup . /app
USER appuser

WORKDIR /app
CMD ["node", "index.js"]
```

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| NODE_ENV | Production or development | Yes |
| GITHUB_TOKEN | GitHub API token | For CI |
| SNYK_TOKEN | Snyk vulnerability scanner | Optional |

## Related Documents
- [docker-templates/nodejs](../docker-templates/nodejs/)
- [ASF-4 Deployment Guide](../deployment-guide/)
- [OpenClaw Protocol](../OPENCLAW-AGENT-PROTOCOL.md)

---
*Last Updated: 2026-02-21*
