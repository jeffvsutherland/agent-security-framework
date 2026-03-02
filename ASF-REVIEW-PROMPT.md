# ASF Story Review Prompt for Grok Heavy

Use this prompt when you want Grok Heavy to review an ASF story:

---

## Prompt

```
Review ASF story [STORY-NUMBER] for completeness and quality.

Story: [STORY-TITLE]
Description: [STORY-DESCRIPTION]

Deliverables location: /workspace/agent-security-framework/docs/[ASF-XX-xxx]/

Required elements:
1. ✅ All deliverables exist in the correct folder
2. ✅ Content is substantial (not placeholder/minimal)
3. ✅ Zero secrets (no API keys, tokens, passwords in code)
4. ✅ Integration table present (if applicable)
5. ✅ Scripts are executable (chmod +x where needed)
6. ✅ Documentation is complete

Checklist:
- [ ] Folder exists at docs/asf-[XX]-[name]/
- [ ] Main deliverable files present
- [ ] No 404s or empty files
- [ ] Run: cd ~/agent-security-framework && ./asf-security-gate.sh --full --target .
- [ ] Verify zero secrets: grep -r "token\|password\|secret\|api_key" docs/asf-[XX]/

Reply with:
- "APPROVED" if all checks pass
- Specific fixes needed if not
```

---

## Quick Review Command

```bash
# Check story folder exists
ls -la /workspace/agent-security-framework/docs/asf-[XX]-[name]/

# Run security audit
cd /workspace/agent-security-framework && ./asf-security-gate.sh --full --target .

# Check for secrets
grep -rE "(api_key|token|password|secret|credential|GITHUB_TOKEN)" docs/asf-[XX]-[name]/ --include="*.md" --include="*.py" --include="*.sh"
```

---

## Example Usage

```
Review ASF-47 for approval. Folder: docs/asf-47-human-readable-report/
- Check ASF-47-HUMAN-READABLE-REPORT.md exists with integration table
- Check generate-report.py exists and is executable
- Run security audit
- Verify zero secrets
```

