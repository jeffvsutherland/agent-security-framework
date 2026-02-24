# ASF Checklist for Clawdbot-Moltbot-Open-Claw

## Quick Start

Maps components to ASF stories/tools.

## Component Mapping

| Component | ASF Story | Tools | Priority |
|-----------|-----------|-------|----------|
| Gateway | ASF-15 | docker-templates/ | HIGH |
| Mission Control | ASF-23 | MISSION-CONTROL-GUIDE.md | HIGH |
| Spam Monitoring | ASF-22 | moltbook-spam-monitor.sh | HIGH |
| Bad Actor DB | ASF-21 | spam-reporting-infrastructure/ | HIGH |
| Skill Security | ASF-5 | docs/asf-5-yara-rules/ | HIGH |
| Code Review | ASF-18 | ASF-18-SCRUM-PROCESS.md | MEDIUM |
| Docker Hardening | ASF-2 | docker-templates/ | HIGH |

## One-Command Deploy

```bash
bash openclaw-secure-deploy.sh
```

## Security Checklist

- [ ] Docker non-root
- [ ] Read-only filesystem
- [ ] Dropped capabilities
- [ ] YARA deployed
- [ ] Spam monitor running

## Daily Checks

```bash
yara -r docs/asf-5-yara-rules/*.yar .openclaw/skills/
~/.asf/asf-openclaw-scanner.py
```
