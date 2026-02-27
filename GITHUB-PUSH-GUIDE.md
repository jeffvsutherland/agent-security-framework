# GitHub Push Guide for Agents

**Repository:** https://github.com/jeffvsutherland/agent-security-framework
**Date:** February 22, 2026
**For:** All ASF Agents

---

## Current Status

- **Local repository:** `~/clawd` (agent-security-framework)
- **Remote:** `origin` → https://github.com/jeffvsutherland/agent-security-framework.git
- **Current branch:** `main`
- **Status:** 24 commits ahead of origin/main
- **Authentication:** Required for push

---

## Prerequisites

You need a GitHub Personal Access Token (PAT) with `repo` scope to push to the repository.

### Getting a GitHub Token

**If Jeff hasn't provided a token yet, ask him to:**

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name it: `ASF Agent Access` or similar
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
5. Click "Generate token"
6. Copy the token (starts with `ghp_...`)
7. Store it securely

---

## How to Push to GitHub

### Step 1: Configure Git Remote with Token

**⚠️ IMPORTANT:** Replace `<GITHUB_TOKEN>` with the actual token.

```bash
cd ~/clawd

# Set the remote URL with embedded token
git remote set-url origin https://<GITHUB_TOKEN>@github.com/jeffvsutherland/agent-security-framework.git
```

### Step 2: Push Commits

```bash
# Push to main branch
git push origin main
```

### Step 3: Verify

```bash
# Check that you're now up to date
git status
# Should say: "Your branch is up to date with 'origin/main'"
```

---

## Complete Command Sequence

```bash
cd ~/clawd

# Configure authentication
git remote set-url origin https://<GITHUB_TOKEN>@github.com/jeffvsutherland/agent-security-framework.git

# Push commits
git push origin main

# Verify
git log origin/main..HEAD
# Should show no commits (empty output means everything is pushed)
```

---

## Before Pushing: Review What You're Pushing

```bash
cd ~/clawd

# See the 24 commits you're about to push
git log origin/main..HEAD --oneline

# See what files were changed
git diff origin/main..HEAD --name-only

# See detailed changes
git diff origin/main..HEAD
```

---

## Story-Specific Pushes

When working on a story that requires pushing specific files to GitHub:

### Example: ASF-4 (Deployment Guide)

```bash
cd ~/clawd

# Check if the deployment-guide directory exists and has content
ls -la deployment-guide/

# If it doesn't exist, create it and add files
mkdir -p deployment-guide
echo "# ASF Deployment Guide" > deployment-guide/README.md
# ... add your deployment files

# Stage the files
git add deployment-guide/

# Commit
git commit -m "Add ASF-4 deployment guide

- Comprehensive deployment documentation
- Docker setup instructions
- Configuration examples

Story: ASF-4
"

# Push
git push origin main
```

### Example: ASF-2 (Docker Templates)

```bash
cd ~/clawd

# Check if docker-templates exists
ls -la docker-templates/

# If needed, create and populate
mkdir -p docker-templates
# ... add template files

git add docker-templates/
git commit -m "Add ASF-2 docker templates

- Base agent template
- Security scanner template
- Deployment configs

Story: ASF-2
"

git push origin main
```

---

## GitHub URLs for Stories

After pushing, verify these URLs are accessible:

| Story | GitHub URL |
|-------|-----------|
| ASF-24 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/spam-reporting-infrastructure |
| ASF-18 | https://github.com/jeffvsutherland/agent-security-framework/blob/main/ASF-SCRUM-PROTOCOL.md |
| ASF-16 | https://github.com/jeffvsutherland/agent-security-framework/tree/main/ASF-14-COMMUNITY-DEPLOYMENT.md |
| ASF-5  | https://github.com/jeffvsutherland/agent-security-framework/tree/main/security-tools |
| ASF-4  | https://github.com/jeffvsutherland/agent-security-framework/tree/main/deployment-guide |
| ASF-3  | https://github.com/jeffvsutherland/agent-security-framework/blob/main/ASF-3-NODE-WRAPPER-GITHUB.md |
| ASF-2  | https://github.com/jeffvsutherland/agent-security-framework/tree/main/docker-templates |

---

## Troubleshooting

### Error: "Authentication failed"

**Problem:** Token is incorrect or expired
**Solution:**
```bash
# Re-configure with correct token
git remote set-url origin https://<CORRECT_TOKEN>@github.com/jeffvsutherland/agent-security-framework.git
```

### Error: "Permission denied"

**Problem:** Token doesn't have `repo` scope
**Solution:** Ask Jeff to create a new token with `repo` scope

### Error: "Updates were rejected"

**Problem:** Remote has changes you don't have locally
**Solution:**
```bash
# Pull remote changes first
git pull origin main --rebase

# Then push
git push origin main
```

### Want to See Remote URL (without exposing token)

```bash
# Shows the URL with token masked
git remote -v
```

---

## Security Notes

⚠️ **NEVER commit the GitHub token to the repository**
⚠️ **NEVER share the token in Telegram/public channels**
⚠️ **Store tokens in secure environment variables or credential managers**

### Better Alternative: Use Environment Variable

```bash
# Store token in environment (add to ~/.bashrc or ~/.zshrc)
export GITHUB_TOKEN="ghp_your_token_here"

# Use the variable in git commands
git remote set-url origin https://${GITHUB_TOKEN}@github.com/jeffvsutherland/agent-security-framework.git
```

---

## Creating Story Documentation on GitHub

When a story requires documentation on GitHub:

### 1. Create Local Files

```bash
cd ~/clawd
mkdir -p <story-directory>
cd <story-directory>

# Create README.md
cat > README.md <<'EOF'
# Story Title

## Overview
Description of what this story delivers

## Files
- `file1.md` - Description
- `file2.py` - Description

## Usage
How to use these files

## Related Stories
- ASF-X: Related story

EOF
```

### 2. Add and Commit

```bash
git add .
git commit -m "Add documentation for ASF-X: Story Title

Closes ASF-X
"
```

### 3. Push

```bash
git push origin main
```

### 4. Get GitHub URL

The URL will be:
```
https://github.com/jeffvsutherland/agent-security-framework/tree/main/<story-directory>
```

---

## Quick Reference Commands

```bash
# Check what you're about to push
git log origin/main..HEAD --oneline

# Push to GitHub
git push origin main

# Check status
git status

# See remote configuration
git remote -v

# Pull latest from GitHub
git pull origin main

# Create and push a new branch
git checkout -b feature/story-name
git push origin feature/story-name
```

---

## For Agents Working on Review Stories

If your story (ASF-2, ASF-3, ASF-4, etc.) needs its code on GitHub:

1. **Ensure files exist locally** in the correct directory
2. **Add README.md** to the directory explaining what it contains
3. **Commit with clear message** referencing the story number
4. **Push to GitHub**
5. **Verify URL is accessible** by checking the GitHub link
6. **Update Mission Control task** with the GitHub URL

---

**Once Jeff provides the GitHub token, any agent can push using the commands above.**
