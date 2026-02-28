# GitHub Push Guide for ASF Agents

**Repository:** https://github.com/jeffvsutherland/agent-security-framework
**Updated:** February 27, 2026
**For:** All ASF Agents (Raven, AgentFriday, AgentSaturday, Research, Social, Deploy, Sales)

---

## ⚠️ CRITICAL RULES — READ FIRST

1. **NEVER commit API keys, tokens, or passwords.** GitHub Push Protection WILL block it.
2. **NEVER `git add .` without checking `.gitignore` first.** Embedded repos and secrets will break the push.
3. **ALWAYS `git pull --rebase origin main` before pushing.** Other agents may have pushed ahead of you.
4. **ALWAYS put story deliverables in `docs/<story-id>/`** — e.g., `docs/asf-40-multi-agent-supervisor/`

---

## Repository Layout

```
~/clawd/                          ← Main workspace (THIS is the git repo)
├── .gitignore                    ← Controls what gets pushed (RESPECT THIS)
├── docs/                         ← Story deliverables go HERE
│   ├── asf-40-multi-agent-supervisor/
│   ├── asf-43-whitepaper/
│   ├── asf-41-security-auditor-guardrail/
│   └── ...
├── skills/                       ← Agent skills (sprint-rollover, security-audit)
├── reports/                      ← Daily build logs, security logs
├── memory/                       ← Agent memory files
├── shared-messages/              ← Inter-agent messages
├── workflows/                    ← Automation workflows
├── agents/                       ← EXCLUDED (has own git repos)
├── agent-security-framework/     ← EXCLUDED (nested clone)
├── workspace-mc-*/               ← EXCLUDED (OpenClaw sessions)
└── config-backups/               ← EXCLUDED (contains secrets)
```

---

## How to Push a Story to GitHub

### Step 1: Create your deliverables in the correct directory

```bash
cd ~/clawd

# Create the story directory under docs/
mkdir -p docs/asf-XX-your-story-name/

# Add your files
cp your-deliverable.md docs/asf-XX-your-story-name/
# OR create directly:
cat > docs/asf-XX-your-story-name/README.md << 'EOF'
# ASF-XX: Your Story Title
... your content ...
EOF
```

### Step 2: Check for secrets before staging

```bash
# Scan your files for API keys or tokens BEFORE adding
grep -rE "(sk-ant-api|ghp_|AIza|apiKey|password|secret)" docs/asf-XX-your-story-name/ && echo "⚠️ SECRETS FOUND - DO NOT COMMIT" || echo "✅ Clean - safe to add"
```

### Step 3: Stage ONLY your story files

```bash
# Stage ONLY the specific files you changed
git add docs/asf-XX-your-story-name/

# DO NOT run: git add .
# DO NOT run: git add -A
# These will pick up embedded repos and secrets
```

### Step 4: Commit with a proper message

```bash
git commit -m "ASF-XX: Brief description of deliverable

- What was added/changed
- Key files included

Story: ASF-XX"
```

### Step 5: Pull before push (other agents may have pushed)

```bash
git pull --rebase origin main
```

### Step 6: Push

```bash
git push origin main
```

### Step 7: Verify

```bash
# Confirm push succeeded
git log origin/main..HEAD --oneline
# Should be empty (no unpushed commits)

# Verify on GitHub
echo "Check: https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-XX-your-story-name/"
```

---

## Complete Copy-Paste Example (ASF-44)

```bash
cd ~/clawd

# 1. Create deliverables
mkdir -p docs/asf-44-my-feature/
cat > docs/asf-44-my-feature/ASF-44-DELIVERABLE.md << 'EOF'
# ASF-44: Feature Name
Content here...
EOF

# 2. Security check
grep -rE "(sk-ant-api|ghp_|AIza|apiKey)" docs/asf-44-my-feature/ || echo "✅ Clean"

# 3. Stage
git add docs/asf-44-my-feature/

# 4. Commit
git commit -m "ASF-44: Add feature deliverable"

# 5. Pull (get other agents' changes)
git pull --rebase origin main

# 6. Push
git push origin main

# 7. Verify
git status
```

---

## Pushing Non-Story Files

For scripts, skills, reports, and other workspace files:

```bash
cd ~/clawd

# Stage specific files
git add skills/my-skill/skill.md
git add reports/DAILY_BUILD_LOG.md
git add my-script.sh

# Commit
git commit -m "Add/update skill and report files"

# Pull + Push
git pull --rebase origin main
git push origin main
```

---

## What NOT to Push (Enforced by .gitignore)

These are automatically excluded. Do not try to override:

| Excluded Path | Reason |
|--------------|--------|
| `agents/deploy/`, `agents/product-owner/`, etc. | Embedded git repos — manage separately |
| `agent-security-framework/` | Nested clone of this repo |
| `asf-discord-bot/` | Has its own git repo |
| `asf-security-scanner/` | Has its own git repo |
| `openclaw-mission-control/` | Has its own git repo |
| `workspace-mc-*/` | OpenClaw session data |
| `config-backups/` | Contains API keys in backups |
| `ASF-15-docker/openclaw-state/` | Session logs with embedded secrets |
| `.env`, `.env.local`, `.env.production` | Environment secrets |
| `*-credentials.json`, `*.key` | Credential files |
| `.mc-token`, `auth-profiles.json` | Auth tokens |
| `node_modules/`, `package-lock.json` | Dependencies |

---

## Troubleshooting

### Error: "Push cannot contain secrets"

GitHub Push Protection detected an API key or token in your commit.

**Fix:**
```bash
# Undo the commit (keeps files)
git reset HEAD~1

# Find the secret
grep -rn "sk-ant-api\|ghp_\|AIza" <your-files>

# Remove or redact the secret, then re-commit
git add <clean-files>
git commit -m "your message"
git push origin main
```

### Error: "Updates were rejected (fetch first)"

Another agent pushed before you.

**Fix:**
```bash
git pull --rebase origin main
git push origin main
```

### Error: "adding embedded git repository"

You ran `git add .` and it picked up a directory with its own `.git/`.

**Fix:**
```bash
# Remove it from staging
git rm --cached -r <embedded-repo-dir>

# Add ONLY your specific files instead
git add docs/asf-XX-your-story/
```

### Error: "does not have a commit checked out"

An OpenClaw workspace directory has an empty `.git`.

**Fix:**
```bash
# Never add workspace-mc-* or workspace-gateway-* directories
# They are already in .gitignore
git reset HEAD
git add <only-your-specific-files>
```

### Merge conflicts after `git pull --rebase`

```bash
# See which files conflict
git status

# Edit the conflicting files, resolve the <<<< ==== >>>> markers
# Then:
git add <resolved-files>
git rebase --continue
git push origin main
```

---

## GitHub URLs for Verified Story Deliverables

| Story | GitHub URL |
|-------|-----------|
| ASF-40 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-40-multi-agent-supervisor |
| ASF-41 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-41-security-auditor-guardrail |
| ASF-42 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-42-docker-syscall-monitoring |
| ASF-43 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-43-whitepaper |
| ASF-38 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-38-agent-trust-framework |
| ASF-26 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-26-website |
| ASF-22 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-22-spam-monitoring |
| ASF-20 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-20-enterprise-integration |
| ASF-5  | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docs/asf-5-yara-rules |

---

## Authentication

The remote URL already has the GitHub PAT embedded:
```
origin  https://ghp_...@github.com/jeffvsutherland/agent-security-framework.git
```

If authentication fails:
```bash
# Check current remote
git remote -v

# If token is expired, ask Jeff for a new one and update:
git remote set-url origin https://<NEW_TOKEN>@github.com/jeffvsutherland/agent-security-framework.git
```

---

## Quick Reference Card

```
┌──────────────────────────────────────────────────────┐
│  AGENT GITHUB PUSH CHECKLIST                         │
│                                                      │
│  □ Files in docs/asf-XX-story-name/                  │
│  □ No secrets in files (grep check)                  │
│  □ git add docs/asf-XX-story-name/  (NOT git add .) │
│  □ git commit -m "ASF-XX: description"               │
│  □ git pull --rebase origin main                     │
│  □ git push origin main                              │
│  □ git status shows "up to date"                     │
└──────────────────────────────────────────────────────┘
```
