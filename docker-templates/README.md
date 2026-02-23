# ASF-2: Docker Templates

## Overview
This directory contains secure Docker templates for various programming languages and use cases in the Agent Security Framework.

## Directory Structure

```
docker-templates/
├── python/          # Python application templates
├── nodejs/          # Node.js application templates  
├── bash/            # Bash/CLI script templates
└── README.md        # This file
```

## Available Templates

### Python Templates
- Secure Python 3.11 slim image
- Non-root user (1000:1000)
- Health checks
- Read-only filesystem support
- See [python/README.md](./python/)

### Node.js Templates
- Secure Node.js 18 Alpine image
- Non-root user (1000:1000)
- Production-ready with npm ci
- Health checks
- See [nodejs/README.md](./nodejs/)

### Bash/CLI Templates
- Secure Debian slim image
- Non-root user (1000:1000)
- Shell script best practices
- Shellcheck integration
- See [bash/README.md](./bash/)

## Security Features

All templates include:

| Feature | Implementation |
|---------|---------------|
| Non-root user | USER 1000:1000 |
| Read-only filesystem | read_only: true |
| Drop capabilities | cap_drop: ALL |
| No new privileges | no-new-privileges:true |
| Minimal base image | slim/alpine variants |
| Health checks | HEALTHCHECK instruction |
| .dockerignore | Excludes sensitive files |

## Quick Start

### Build a Python image
```bash
cd python
docker build -t asf-python .
```

### Build a Node.js image
```bash
cd nodejs
docker build -t asf-nodejs .
```

### Build a Bash image
```bash
cd bash
docker build -t asf-bash .
```

### Using docker-compose
```bash
# Example for Python
docker-compose -f python/docker-compose.yml up -d
```

## Integration with ASF

These templates integrate with other ASF components:

- **ASF-4** (Deployment Guide): Use these templates for deployment
- **ASF-5** (YARA Rules): Scan images before deployment
- **ASF-15** (Docker Complete): Full Docker hardening guide

## Best Practices

1. **Always use specific versions** - Don't use :latest
2. **Multi-stage builds** - Reduce final image size
3. **Scan for vulnerabilities** - Use Trivy or Snyk
4. **Don't commit secrets** - Use environment variables
5. **Test locally** - Before deploying to production

## Related Documents

| Document | Description |
|----------|-------------|
| [ASF-4 Deployment Guide](../deployment-guide/) | Complete deployment instructions |
| [ASF-5 YARA Rules](../docs/asf-5-yara-rules/) | Security scanning rules |
| [ASF-15 Docker Complete](../deployment-guide/ASF-15-DOCKER-COMPLETE.md) | Full Docker hardening |
| [ASF-3 Node Wrapper](../ASF-3-NODE-WRAPPER-GITHUB.md) | GitHub Actions integration |

## Contributing

When adding new templates:
1. Follow security best practices above
2. Include .dockerignore
3. Add health check
4. Document in this README
5. Test build locally

---
*Last Updated: 2026-02-21*
