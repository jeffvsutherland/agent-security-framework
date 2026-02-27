# 🎯 ASF Agent Quick Reference Card

## 🤖 Agent Telegram Bots
- **@jeffsutherlandbot** - Main coordinator
- **@ASFDeployBot** - DevOps & infrastructure  
- **@ASFSalesBot** - Sales & outreach
- **@ASFSocialBot** - Social media & community
- **@ASFResearchBot** - Research & documentation
- **@AgentSaturdayASFBot** - Product management

## 📝 Quick Assignment Template
```
@[AgentBot] Please work on ASF-XX: [Story Title]
- [Task 1]
- [Task 2]
- Update Jira hourly
- Complete by [deadline]
```

## 🔍 Status Commands
- **All agents:** `@jeffsutherlandbot What are all agents working on?`
- **Sprint status:** `@AgentSaturdayASFBot Current sprint status?`
- **Story details:** `@[AgentBot] Status update on ASF-XX?`

## ⚡ Common Tasks
| Task | Agent | Command |
|------|-------|---------|
| Security scan | Deploy | `@ASFDeployBot Run ASF security scanner on all skills` |
| Social post | Social | `@ASFSocialBot Draft Moltbook post about ASF v1.0` |
| Market research | Research | `@ASFResearchBot Research competitor security tools` |
| Sales deck | Sales | `@ASFSalesBot Create enterprise security pitch deck` |
| Sprint planning | Product | `@AgentSaturdayASFBot Plan next sprint stories` |

## 🚨 Troubleshooting
- **Not responding:** Check Docker logs: `docker logs openclaw-gateway`
- **Jira failing:** Ask agent for error: `What error did you get?`
- **File access:** Ensure files are in `/workspace/`

## 📊 Definition of Done
1. ✅ Implementation complete
2. ✅ Grok Heavy review
3. ✅ Docs updated
4. ✅ Tests pass
5. ✅ Product Owner approval
6. ✅ Jeff's approval
7. ✅ Moved to Done in Jira