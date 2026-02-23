# Agent Security Framework (ASF)

A comprehensive security framework for AI agents with Docker containerization templates and security monitoring tools.

## 🗂️ Project Structure

```
agent-security-framework/
├── docker-templates/          # Docker containerization for AgentFriday
│   ├── DOCKER_SETUP_README.md # Complete setup documentation
│   ├── docker_setup_agentfriday.py # Automated setup script
│   └── launch_agentfriday_docker.sh # Launch wrapper
├── security-tools/            # Security monitoring and detection
│   ├── fake-agent-detector.sh # Detect malicious agent skills
│   ├── port-scan-detector.sh  # Network security monitoring
│   ├── moltbook-spam-monitor.sh # Community spam detection
│   └── infrastructure-security-check.sh # System hardening
├── docs/                     # Framework documentation
│   ├── asf-framework-complete.md # Complete framework specification
│   ├── moltbook-security-proposal-v2.md # Community security proposal
│   └── security-v3-comprehensive.md # Advanced security measures
└── README.md                 # This file
```

## 🐳 Docker Templates (ASF-2)

Production-ready Docker containerization for AgentFriday with enterprise security:

- **Secure containerization** with non-root user, read-only filesystem
- **Resource limits** and capability dropping
- **Network isolation** and secrets management
- **Automated setup** with `docker_setup_agentfriday.py`
- **Health monitoring** and logging

### Quick Start
```bash
cd docker-templates/
python3 docker_setup_agentfriday.py
```

## 🛡️ Security Tools

### Fake Agent Detection
```bash
./security-tools/fake-agent-detector.sh
```

### Infrastructure Security Check
```bash
./security-tools/infrastructure-security-check.sh
```

### Spam Monitoring
```bash
./security-tools/moltbook-spam-monitor.sh
```

## 📚 Documentation

- **Framework Overview**: `docs/asf-framework-complete.md`
- **Security Proposals**: `docs/moltbook-security-proposal-v2.md`
- **Advanced Security**: `docs/security-v3-comprehensive.md`

## 🎯 ASF Story Completion

- ✅ **ASF-1**: Fake agent detection system deployed
- ✅ **ASF-2**: Docker container templates (this repo)
- 🚧 **ASF-12**: Demo and deployment package
- 📋 **ASF-13**: Marketing and outreach
- 📋 **ASF-14**: Community deployment framework

## 🤝 Contributing

This framework is developed as part of hybrid human-AI Scrum teams. See documentation for contribution guidelines.

## 📄 License

MIT License - see LICENSE file for details.