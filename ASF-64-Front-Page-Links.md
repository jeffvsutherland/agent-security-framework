# ASF-64: Connect Front Page Links

**Status:** REVIEW (BLOCKED)  
**Assignee:** Sales Agent  
**Date:** March 8, 2026

---

## Description

Connect all navigation links on the ASF front page to their respective content pages.

## BLOCKER - Header Overlay Issue

The scrumai.org fixed header is blocking website content on sandbox.jvsmanagement.com. The "Get Started on GitHub" button is unclickable.

## Solution

**Option 1:** Deploy to GitHub Pages (no wrapper)
- URL: https://jeffvsutherland.github.io/agent-security-framework/
- Need to enable in repo Settings → Pages → Source: main, folder: /root

**Option 2:** Fix nginx on sandbox.jvsmanagement.com
- Remove the scrumai.org header injection

## Links Ready

| Page | Link | Status |
|------|------|--------|
| CIO Report | ./docs/deliverables/ASF-52-CIO-Security-Report.md | ✅ |
| CIO Command | ./docs/deliverables/ASF-67-Simple-CIO-Command.md | ✅ |
| Features | ./docs/deliverables/ASF-53-Features-Page.md | ✅ |
| Use Cases | ./docs/deliverables/ASF-54-Use-Cases-Page.md | ✅ |
| Contact | ./docs/deliverables/ASF-55-Contact-Page.md | ✅ |
| Features | ./docs/deliverables/ASF-53-Features-Page.md | ✅ |
| Use Cases | ./docs/deliverables/ASF-54-Use-Cases-Page.md | ✅ |
| Contact | ./docs/deliverables/ASF-55-Contact-Page.md | ✅ |
| Security Audit | ./ASF-51-Exposure-Audit.md | ✅ |
| Rate Limiting | ./ASF-59-Rate-Limiting.md | ✅ |

## DoD

- [x] Links ready in content
- [ ] Header blocking resolved
- [ ] All links clickable

---

## See Also

- [ASF Overview](../README.md)
- [CIO Report](./docs/deliverables/ASF-52-CIO-Security-Report.md)

*Updated: March 8, 2026 - BLOCKED*
