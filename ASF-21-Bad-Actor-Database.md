# ASF-21: Bad Actor Database for Community Protection

**Created:** 2026-03-04
**Status:** Ready for Review

## 🎯 Sprint Goal
**"Zero malicious actors on Moltbook within 30 days, with automated detection and banning."**

---

## 🎯 Objective
Build a database of known bad actors for community protection.

## ✅ INVEST Criteria
- **Independent:** Works standalone
- **Negotiable:** Schema adaptable
- **Valuable:** Enables automated blocking
- **Estimable:** ~8 hours
- **Small:** JSON + scripts
- **Testable:** Query returns expected results

## ✅ Definition of Done (DoD) Checklist
- [ ] JSON schema defined
- [ ] 3+ test bad actors documented
- [ ] Risk scoring implemented
- [ ] Evidence tracking functional
- [ ] Integration with spam monitor
- [ ] Test data only (NO real PII)

## ✅ Security Acceptance Criteria
- [ ] NO real emails in database
- [ ] NO real names (test data only)
- [ ] NO real IP addresses
- [ ] All entries are synthetic/fake
- [ ] Top comment: "Test data only - no production PII"

---

## Schema

```json
{
  "bad_actors": [
    {
      "id": "test-001",
      "display_name": "Test Bad Actor",
      "risk_level": "high",
      "test_email": "test@example.com",
      "test_ip": "192.0.2.1",
      "indicators": ["spam_pattern_1", "fake_agent"],
      "evidence": [],
      "created_at": "2026-01-01"
    }
  ]
}
```

---

*Status: Ready for security scan + review*
