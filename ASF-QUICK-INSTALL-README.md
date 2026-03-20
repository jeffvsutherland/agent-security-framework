# ASF Quick Install Script

One-command installer for **OpenClaw**, **Mission Control**, and the **Agent Security Framework (ASF)**.

## What This Installs

| Component | Description |
|-----------|-------------|
| **OpenClaw** | Core AI agent platform with gateway, skills, and tools |
| **Mission Control** | Scrum project management board for agent teams |
| **ASF** | Agent Security Framework - security hardening and monitoring |

## Requirements

- Linux or macOS
- Docker (running)
- Git
- Curl

## Quick Install (One Command)

```bash
curl -sSL https://raw.githubusercontent.com/jeffvsutherland/agent-security-framework/main/asf-quick-install.sh | bash
```

Or download and run manually:

```bash
wget -O asf-install.sh https://raw.githubusercontent.com/jeffvsutherland/agent-security-framework/main/asf-quick-install.sh
chmod +x asf-install.sh
./asf-install.sh
```

## What Happens

1. ✅ Checks Docker and required dependencies
2. ✅ Creates installation directory (`~/asf-install`)
3. ✅ Clones OpenClaw from GitHub
4. ✅ Clones Mission Control board
5. ✅ Clones ASF security framework
6. ✅ Applies ASF security configurations
7. ✅ Creates launcher script

## After Installation

### Start Services
```bash
~/asf-install/asf-launcher.sh start
```

### Check Status
```bash
~/asf-install/asf-launcher.sh status
```

### View Logs
```bash
~/asf-install/asf-launcher.sh logs
```

### Access Services

| Service | URL |
|---------|-----|
| OpenClaw Gateway | http://localhost:3000 |
| Mission Control API | http://localhost:8001 |

## Configuration

Edit the environment file:
```bash
nano ~/asf-install/openclaw/.env
```

Add your API keys (OpenAI, Anthropic, etc.).

## Troubleshooting

### Docker not running
```bash
# Start Docker
sudo systemctl start docker
# Or on macOS: Open Docker Desktop
```

### Port already in use
Edit the docker-compose.yml to change ports, or stop other services using those ports.

### Need help?
Check the individual component READMEs in:
- `~/asf-install/openclaw/README.md`
- `~/asf-install/agent-security-framework/`

## Uninstaller

```bash
rm -rf ~/asf-install
```

---

**Version:** 2026.03  
**Repository:** https://github.com/jeffvsutherland/agent-security-framework
