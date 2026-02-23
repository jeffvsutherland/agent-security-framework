# ASF-14: Community Deployment & Onboarding Guide

## Overview
This guide covers how to securely deploy the Agent Security Framework and participate in the ASF community.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Fork & Clone](#fork--clone)
3. [Secure Skill Contribution](#secure-skill-contribution)
4. [Deployment Options](#deployment-options)
5. [Ban & Appeal Process](#ban--appeal-process)
6. [Reporting Issues](#reporting-issues)

## Quick Start

```bash
# Clone the repository
git clone https://github.com/jeffvsutherland/agent-security-framework.git
cd agent-security-framework

# Run deployment
./deploy.sh
```

## Fork & Clone

### For Community Members
1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/agent-security-framework.git
   ```

### Security Requirements
- **Never commit secrets/keys** - Use environment variables
- **All code must pass YARA scans** - See [ASF-5 YARA Rules](./docs/asf-5-yara-rules/)
- **No malicious skills** - Zero tolerance policy

## Secure Skill Contribution

### Before Contributing
1. Run YARA validation:
   ```bash
   yara -r docs/asf-5-yara-rules/*.yar your-skill/
   ```

2. Follow coding standards in `docs/asf-5-yara-rules/README.md`

3. Submit PR with:
   - Clear description
   - Security impact assessment
   - Test results

### Prohibited Content
- ❌ Credential harvesting
- ❌ Network exfiltration
- ❌ Reverse shells
- ❌ Cryptocurrency miners
- ❌ Typosquatting/name-squatting

## Deployment Options

### Docker Deployment
```bash
cd docker-templates
./launch_agentfriday_docker.sh
```

### Manual Deployment
See [Deployment Guide](./deploy.sh)

### Cloud Providers
| Provider | Guide |
|----------|-------|
| AWS | Coming soon |
| GCP | Coming soon |
| Azure | Coming soon |

## Ban & Appeal Process

### Grounds for Ban
- Malicious skill submission
- Attempted credential theft
- Abuse of community resources
- Violation of security policies

### Appeal Process
1. Submit appeal to: security@scrumai.org
2. Include:
   - Your GitHub username
   - Reason for ban
   - Explanation of actions
3. Review within 7 business days

## Reporting Issues

### Security Vulnerabilities
**Do NOT open public issues for security vulnerabilities!**

Email: security@scrumai.org

### Spam & Abuse
See [ASF-24 Spam Reporting](../security-tools/moltbook-spam-monitor.sh)

### General Issues
Open an issue on GitHub with appropriate labels.

## Related Documents
- [ASF-5 YARA Rules](./docs/asf-5-yara-rules/)
- [ASF-18 Scrum Process](./ASF-18-SCRUM-PROCESS.md)
- [Spam Reporting Infrastructure](./security-tools/moltbook-spam-monitor.sh)

---
*Last Updated: 2026-02-21*
