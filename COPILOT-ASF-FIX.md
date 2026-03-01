# Prompt for Copilot to Fix Missing ASF Folders

```
The ASF repo is missing dedicated folders for ASF-40 and ASF-43.

Current folders that exist:
- asf-41-security-auditor-guardrail (has integration table)
- asf-42-docker-syscall-monitoring (has integration table)
- asf-44-fix-prompt-generator (has integration table)

What's missing:
- asf-40-multi-agent-supervisor/ folder doesn't exist
- asf-43-whitepaper/ folder doesn't exist

Your task:
1. Create folder: mkdir -p docs/asf-40-multi-agent-supervisor/
2. Create folder: mkdir -p docs/asf-43-whitepaper/
3. Add ASF-40-MULTI-AGENT-SUPERVISOR.md with integration table
4. Add start-supervisor.sh script
5. Add ASF-43-WHITEPAPER.md with integration table
6. Add to both folders:
   ## Open-Claw / Clawdbot / Moltbot Integration
   | Component | Role in Stack | One-command activation |
   |----------|---------------|---------------------|
   | Open-Claw host | Full isolation + trust baseline | ./start-supervisor.sh --openclaw |
   | Clawdbot (WhatsApp) | Skill monitoring + localhost bridge | ./start-supervisor.sh --clawbot |
   | Moltbot (PC-control) | Voice/PC commands gated by guardrail | ./start-supervisor.sh --moltbot |

7. Commit and push with message: "ASF-40/43: Add integration tables per Grok review"

Location: ~/agent-security-framework or ~/clawd
```

Run this in your workspace to create the missing folders.
