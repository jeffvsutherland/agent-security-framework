# ASF Code Review Checklist

## Quick Reference for Agents

### Before Starting Development
- [ ] Story is in "In Progress" on Mission Control
- [ ] Requirements defined and clear
- [ ] Technical approach documented
- [ ] Security implications assessed

### During Development
- [ ] Code committed to workspace with meaningful messages
- [ ] Hourly updates include progress
- [ ] Documentation updated
- [ ] No credentials in code

### Before Requesting Review (Pre-Review Self-Check)
- [ ] **Self-Review**: I have reviewed my own code
- [ ] **Testing**: Code has been tested (manual minimum)
- [ ] **Documentation**: Changes are documented
- [ ] **Security**: No credentials, follows ASF patterns
- [ ] **Integration**: Doesn't break existing functionality
- [ ] **Workspace**: All deliverables committed

### Moving to Review Status

**Comment Template:**
```
Moving to review. Ready for:
- [ ] Peer review
- [ ] Security review [if scripts/infrastructure]
- [ ] Product Owner review

Deliverables: [list files created]
Testing: [how it was tested]
Self-review: Complete ✅
```

### Review Categories by Code Type

| Code Type | Peer Review | Security Review | PO Review | External Audit |
|-----------|-------------|----------------|-----------|----------------|
| Scripts (.sh/.py/.js) | ✅ | ✅ | ✅ | If public |
| Configuration | ✅ | ✅ | ✅ | If customer-facing |
| Documentation | ✅ | ❌ | ✅ | If public |
| Infrastructure | ✅ | ✅ | ✅ | If customer-facing |

### Reviewer Responsibilities

**As a Peer Reviewer:**
- [ ] Respond within 4 hours
- [ ] Check logic and approach
- [ ] Identify potential issues
- [ ] Provide specific, actionable feedback

**As Security Reviewer:**
- [ ] Respond within 8 hours
- [ ] Check for credential leaks
- [ ] Assess security implications
- [ ] Verify safe system access patterns

**As Product Owner:**
- [ ] Respond within 24 hours
- [ ] Verify acceptance criteria met
- [ ] Confirm business value delivered
- [ ] Ensure quality standards met

### Review Response Templates

**Approval:**
```
REVIEW: Approve
Reviewer: [Your Agent Name]
Type: [Peer/Security/Product Owner]

✅ [What looks good]
✅ [Meets requirements]
✅ [No concerns found]

Ready for [next review stage/Done]
```

**Request Changes:**
```
REVIEW: Request Changes
Reviewer: [Your Agent Name]
Type: [Peer/Security/Product Owner]

Changes needed:
- [ ] [Specific actionable item]
- [ ] [What needs to be fixed]
- [ ] [Security concern if applicable]

Moving back to In Progress
```

### Emergency Process Quick Reference

**🚨 EMERGENCY DEPLOYMENT:**
1. Announce: "🚨 EMERGENCY: [description]"
2. Get Scrum Master approval
3. Deploy fix immediately
4. Get minimum 1 peer review (concurrent OK)
5. Security review within 2 hours
6. Full post-incident review within 24 hours

### Common Review Issues

**❌ Avoid These:**
- Hardcoded credentials or API keys
- Missing error handling
- Undocumented system access
- Breaking existing functionality
- No testing performed
- Vague commit messages

**✅ Best Practices:**
- Clear, descriptive variable names
- Proper error handling and logging
- Security-first approach
- Comprehensive documentation
- Thorough self-review
- Meaningful commit messages

### SLA Reminders

- **Peer Review**: 4 hours
- **Security Review**: 8 hours  
- **Product Owner Review**: 24 hours
- **Emergency Reviews**: 2 hours

### Escalation Path

1. **Missing SLA** → Ping reviewer in supergroup
2. **Still no response** → Escalate to Scrum Master
3. **Persistent issues** → Team retrospective

---

*Keep this checklist handy! Pin it to your workspace for quick reference.*