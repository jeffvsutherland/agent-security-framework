# ASF Mandatory Code Review Process

## Background & Motivation

**Problem:** Previous gateway wrapper script bypassed keychain integration causing node crash, requiring major surgery to fix.

**Solution:** Implement strict Scrum process for ANY code changes to prevent deployment issues.

## Core Principle

> **NO CODE SHIPS WITHOUT REVIEW** 
> *Every script, config, and code change must pass mandatory review gates before deployment.*

## Process Overview

### 1. Pre-Development Review Gates

**Before starting ANY code work:**
- [ ] Story must be in "In Progress" status on Mission Control
- [ ] Requirements and acceptance criteria must be defined
- [ ] Technical approach must be documented
- [ ] Security implications must be assessed

### 2. Development Phase Requirements

**During development:**
- [ ] All code must be committed to agent workspace
- [ ] Meaningful commit messages required
- [ ] Work must be documented in hourly updates
- [ ] Any architectural changes must be announced in supergroup

### 3. Pre-Review Checklist

**Before moving story to "Review":**
- [ ] **Self-Review**: Developer has reviewed their own code
- [ ] **Documentation**: All changes are documented
- [ ] **Testing**: Code has been tested (manual minimum)
- [ ] **Security Check**: No credentials in code, follows ASF security patterns
- [ ] **Integration**: Doesn't break existing functionality
- [ ] **Workspace Commit**: All deliverables committed to agent workspace

### 4. Mandatory Review Process

**When story moves to "Review" status:**

#### 4.1 Peer Review (Required)
- **Who**: Any other ASF agent (cross-functional review encouraged)
- **Focus**: Logic, approach, potential issues
- **Timeline**: Within 4 hours of review request
- **Outcome**: Approve OR send back to In Progress with specific feedback

#### 4.2 Security Review (Required for scripts/infrastructure)
- **Who**: Deploy agent OR Research agent (security specialists)
- **Focus**: Security implications, credential handling, system access
- **Timeline**: Within 8 hours of review request  
- **Outcome**: Approve OR send back with security concerns

#### 4.3 Product Owner Review (Always Required)
- **Who**: Raven (@AgentSaturdayASFBot)
- **Focus**: Meets acceptance criteria, business value delivered
- **Timeline**: Within 24 hours of technical approval
- **Outcome**: Move to Done OR send back with requirements clarification

### 5. External Audit (Security/Public Deliverables)

**For public-facing or security-critical deliverables:**
- **Who**: Grok Heavy (external expert)
- **Focus**: Security audit, compliance, best practices
- **Timeline**: As required by Definition of Done
- **Outcome**: Final approval for public release

## Review Implementation in Mission Control

### Status Flow
```
Inbox → In Progress → Review → Done
                    ↑    ↓
                  (Review Feedback)
```

### Comment Requirements

**When requesting review** (moving to Review):
```
Moving to review. Ready for:
- [ ] Peer review
- [ ] Security review (if applicable)  
- [ ] Product Owner review

Deliverables: [list what was built]
Testing: [how it was tested]
```

**When providing review feedback:**
```
REVIEW: [Approve/Request Changes]
Reviewer: [Agent Name]
Type: [Peer/Security/Product Owner]

Feedback:
- [Specific actionable items]
- [What needs to be fixed]

[If approved]: Ready for next review stage
[If changes needed]: Moving back to In Progress
```

## Code Categories & Review Requirements

### Category 1: Scripts (.sh, .py, .js)
**Review Required:**
- ✅ Peer Review
- ✅ Security Review  
- ✅ Product Owner Review

**Special Checks:**
- No hardcoded credentials
- Proper error handling
- System access justified
- Input validation present

### Category 2: Configuration Files
**Review Required:**
- ✅ Peer Review
- ✅ Security Review
- ✅ Product Owner Review

**Special Checks:**
- No sensitive data exposed
- Follows configuration standards
- Backward compatibility considered

### Category 3: Documentation
**Review Required:**
- ✅ Peer Review
- ✅ Product Owner Review

**Special Checks:**
- Accurate and up-to-date
- Clear and actionable
- Follows documentation standards

### Category 4: Infrastructure/Deployment
**Review Required:**
- ✅ Peer Review (Deploy agent preferred)
- ✅ Security Review (mandatory)
- ✅ Product Owner Review
- ✅ External Audit (if customer-facing)

**Special Checks:**
- Security implications assessed
- Rollback plan documented
- System dependencies identified
- Performance impact considered

## Emergency Procedures

### Critical Bug Fixes
**When system is down or security breach:**
1. Announce emergency in supergroup: "🚨 EMERGENCY: [description]"
2. Scrum Master approves emergency deployment
3. Fix deployed immediately
4. **Mandatory post-incident review within 24 hours**

### Emergency Review Process
- Minimum 1 peer review required (can be concurrent with deployment)
- Security review required within 2 hours of deployment
- Full post-incident documentation required

## Enforcement

### Violations
**Deploying code without review:**
- Immediate rollback
- Root cause analysis
- Process improvement discussion

**Review Responsibilities**
- **Agents**: Responsible for requesting appropriate reviews
- **Reviewers**: Must respond within SLA timelines
- **Scrum Master**: Enforces process compliance
- **Product Owner**: Final arbiter of business requirements

### Escalation
1. **Agent doesn't follow process** → Scrum Master intervention
2. **Reviewer misses SLA** → Escalate to Scrum Master
3. **Persistent issues** → Team retrospective and process adjustment

## Tools Integration

### Mission Control
- Status-based workflow enforces review gates
- Comments capture review decisions
- Audit trail for compliance

### Git/Workspace
- All code must be committed before review
- Reviewers check committed code, not descriptions
- Version control provides change tracking

### Supergroup Communication
- Review requests announced
- Escalations communicated
- Emergency procedures coordinated

## Success Metrics

**Quality Indicators:**
- Zero deployment failures due to unreviewed code
- Review turnaround time < 8 hours average
- 100% compliance with review requirements

**Process Health:**
- All stories follow review workflow
- Reviews catch issues before deployment  
- Team learns from review feedback

## Examples

### Good Review Request
```
✅ Sales completed [ASF-18]: Code Review Process. Moving to review.

Ready for review:
- [x] Self-review completed
- [x] Code tested manually
- [x] Documentation updated
- [x] No security concerns identified

Deliverables:
- ASF-MANDATORY-CODE-REVIEW-PROCESS.md
- review-checklist.md
- emergency-procedures.md

Testing: Validated against previous gateway script issue
```

### Good Review Response
```
REVIEW: Approve
Reviewer: Deploy Agent
Type: Security Review

Feedback:
✅ Process covers security concerns well
✅ Emergency procedures are appropriate  
✅ Enforcement mechanisms are clear

Ready for Product Owner review
```

---

**This process is mandatory starting immediately. No exceptions.**