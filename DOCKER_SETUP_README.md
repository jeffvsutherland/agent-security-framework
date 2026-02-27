# 🐳 AgentFriday Docker Setup

Secure containerization setup for AgentFriday on macOS.

## 🚀 Quick Start

1. **Run the setup script:**
```bash
python3 docker_setup_agentfriday.py
```

2. **Add your API keys:**
```bash
cd ~/agentfriday-docker
cp secrets/api_keys.json.template secrets/api_keys.json
# Edit secrets/api_keys.json with your real API keys
```

3. **Start AgentFriday:**
```bash
docker-compose up -d
```

## 🛡️ Security Features

- ✅ **Non-root user** (UID 1000)
- ✅ **Read-only filesystem** with specific writable areas
- ✅ **Dropped capabilities** (minimal privileges)
- ✅ **Resource limits** (CPU/memory constraints)
- ✅ **Network isolation** (internal network)
- ✅ **Secrets mounted read-only**
- ✅ **Health checks** for monitoring

## 📋 Management Commands

```bash
# View logs
docker-compose logs -f

# Stop AgentFriday
docker-compose stop

# Restart AgentFriday
docker-compose restart

# Shell access (debugging)
docker-compose exec agentfriday bash

# Completely remove
docker-compose down --volumes
```

## 📁 Directory Structure

```
~/agentfriday-docker/
├── Dockerfile              # Container definition
├── docker-compose.yml      # Service configuration
├── requirements.txt        # Python dependencies
├── agentfriday_main.py     # Main application
├── harden_security.sh      # Security hardening
├── secrets/
│   ├── api_keys.json.template
│   └── api_keys.json       # Your real API keys (create this)
├── data/                   # Persistent data
└── logs/                   # Application logs
```

## 🔐 Security Best Practices

1. **Never commit api_keys.json** to version control
2. **Regularly update the container** (`docker-compose pull && docker-compose up -d`)
3. **Monitor logs** for suspicious activity
4. **Use strong API keys** and rotate them regularly
5. **Backup the data/ directory** regularly

## 🚨 Troubleshooting

**Docker Desktop not starting?**
- Open Docker Desktop app manually
- Check system requirements (macOS 10.14+)
- Restart your Mac if needed

**Permission denied errors?**
- Run: `./harden_security.sh` in the project directory
- Check file ownership: `ls -la secrets/`

**Container won't start?**
- Check logs: `docker-compose logs`
- Verify API keys in `secrets/api_keys.json`
- Ensure Docker has enough resources (Settings > Resources)

**Can't access from outside container?**
- Uncomment ports section in docker-compose.yml if needed
- Remember: network is isolated by default for security

## 🔧 Customization

**To modify AgentFriday behavior:**
1. Edit `agentfriday_main.py`
2. Rebuild: `docker-compose build`
3. Restart: `docker-compose up -d`

**To add new Python packages:**
1. Add to `requirements.txt`
2. Rebuild: `docker-compose build`

**To expose network access:**
1. Edit `docker-compose.yml`
2. Remove `internal: true` from network config
3. Uncomment ports if needed

## 📊 Monitoring

Health check endpoint: `http://localhost:8080/health` (if ports exposed)

Inside container: `curl http://localhost:8080/health`

## 🆘 Support

If you encounter issues:
1. Check the logs: `docker-compose logs -f`
2. Verify Docker Desktop is running
3. Ensure all secrets are properly configured
4. Try rebuilding: `docker-compose build --no-cache`