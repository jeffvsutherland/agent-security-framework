# OpenClaw Skills Guide for Raven

## 🎯 What Are Skills?

Skills are modular packages that extend OpenClaw agent capabilities with specialized knowledge, workflows, and tools. Think of them as plugins that give your agents superpowers.

## ✅ Currently Installed Skills

### 1. **find-skills** (v0.1.0) - The Navigator
- **Purpose**: Search through 200k+ skills to find the right tool for any task
- **Use When**: You need to discover new capabilities or find skills for specific tasks
- **Command**: `npx skills find [query]`

### 2. **mcporter** (v1.0.0) - The Bridge
- **Purpose**: Build MCP (Model Context Protocol) servers to connect AI to private data and external tools
- **Use When**: You need to integrate with custom data sources or APIs
- **Command**: `mcporter list`, `mcporter call`, `mcporter config`

### 3. **using-superpowers** (v0.1.0) - The Optimizer
- **Purpose**: Forces agents to understand and maximize their high-level capabilities
- **Use When**: You want agents to use their full potential instead of guessing
- **Best Practice**: Load this skill when starting complex tasks

### 4. **subagent-driven-development** (v0.1.0) - The Manager
- **Purpose**: Delegate sub-tasks to specialized agents and audit their work
- **Use When**: Complex multi-step tasks that can be broken down and parallelized
- **Benefit**: Focus on vision while sub-agents handle the grind

### 5. **pls-agent-tools** (v1.0.0) - The Toolkit
- **Purpose**: Collection of practical utilities for everyday agent labor
- **Use When**: You need common tools that standard models can't handle
- **Examples**: File manipulation, data processing, system utilities

## 📦 Managing Skills with ClawHub

### Search for Skills
```bash
npx clawhub search "keyword"
npx clawhub explore
```

### Install Skills
```bash
# Basic install
npx clawhub install skill-name --dir skills

# Force install (bypass security warnings)
npx clawhub install skill-name --dir skills --force
```

### List Installed Skills
```bash
npx clawhub list
```

### Update Skills
```bash
# Update specific skill
npx clawhub update skill-name

# Update all skills
npx clawhub update
```

### Uninstall Skills
```bash
npx clawhub uninstall skill-name
```

### Get Skill Info
```bash
npx clawhub inspect skill-name
```

## 📁 Skill Locations

### On Host Machine
- **Path**: `/Users/jeffsutherland/clawd/skills/`
- **Access**: Direct file system access

### In OpenClaw Container
- **Path**: `/app/skills/` (symlinks to `/workspace/skills/`)
- **Workspace Mount**: `/workspace` → `~/clawd`
- **Auto-loaded**: Skills are automatically discovered by OpenClaw on startup

## 🔄 Installing New Skills

### Step 1: Search for the skill
```bash
npx clawhub search "description of what you need"
```

### Step 2: Install to workspace
```bash
cd ~/clawd
npx clawhub install skill-name --dir skills --force
```

### Step 3: Link to OpenClaw container (if needed)
```bash
docker exec openclaw-gateway sh -c 'cd /app/skills && ln -sf /workspace/skills/skill-name skill-name'
```

### Step 4: Restart OpenClaw
```bash
cd ~/clawd/ASF-15-docker
docker-compose restart openclaw
```

### Step 5: Verify
```bash
docker exec openclaw-gateway ls /app/skills | grep skill-name
```

## ⚠️ Security Notes

- **Third-party skills are untrusted code** - Review before installing
- **Security flags**: ClawHub may flag skills with risky patterns (crypto keys, APIs, eval)
- **Use --force**: Only after reviewing the skill's SKILL.md file
- **Check source**: Verify skill comes from trusted publishers

## 🎓 Skill Creation

To create your own skills, use the **skill-creator** skill (already installed in OpenClaw):

```bash
# Read the skill-creator documentation
docker exec openclaw-gateway cat /app/skills/skill-creator/SKILL.md
```

## 🔍 Finding Skills for Specific Tasks

### Common Use Cases:

- **"How do I do X?"** → Use `find-skills` to search
- **"Connect to API/Database"** → Use `mcporter` to build MCP bridge
- **"Complex multi-step task"** → Use `subagent-driven-development`
- **"Optimize agent performance"** → Use `using-superpowers`
- **"Need utility tools"** → Use `pls-agent-tools`

## 📚 Additional Resources

- **ClawHub Website**: https://clawhub.ai/
- **Skills Repository**: https://github.com/openclaw/skills
- **ClawHub CLI Docs**: Run `npx clawhub --help`

## 🆘 Troubleshooting

### Rate Limiting
If you see "Rate limit exceeded", wait 30-60 seconds between commands.

### Skill Not Loading
1. Check symlink exists: `docker exec openclaw-gateway ls -la /app/skills/skill-name`
2. Verify skill has SKILL.md: `docker exec openclaw-gateway cat /app/skills/skill-name/SKILL.md`
3. Restart container: `docker-compose restart openclaw`

### Container Can't Access Skill
Ensure the workspace volume is mounted correctly in `docker-compose.yml`:
```yaml
volumes:
  - ${HOME}/clawd:/workspace
```

---

**Last Updated**: 2026-02-23
**OpenClaw Version**: 2026.2.19
**Total Skills Available**: 200,000+
**Currently Installed**: 7 (including base skills)
