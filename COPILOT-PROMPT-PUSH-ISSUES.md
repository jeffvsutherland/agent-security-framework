# Prompt for Copilot: Fix Push Issues

## Context
The OpenClaw agent workspace is experiencing push issues. Agents need to commit and push their work to git.

## Issues to Diagnose and Fix:

1. **Git Push Failures**
   - Check if there are git authentication issues
   - Verify credentials are correct
   - Test push to origin/main

2. **Workspace Sync Issues**
   - Ensure agents can push to /workspace/agents/ repository
   - Check git remote configuration
   - Verify branch protection rules aren't blocking pushes

3. **Common Fixes to Apply:**
   - Run `git status` to check for issues
   - Fix any merge conflicts
   - Ensure git credentials are configured
   - Test with: `git push origin main`

## Commands to Run:
```bash
cd /workspace/agents/product-owner
git status
git remote -v
git push origin main --verbose
```

## Expected Outcome:
All agents should be able to push their deliverables to the workspace git repository without errors.

Please diagnose and fix any push issues found.
