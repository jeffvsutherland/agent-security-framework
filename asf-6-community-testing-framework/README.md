# ASF-6: Community Testing Framework

**Created:** 2026-03-04
**Status:** Ready for Review

## 🎯 Sprint Goal
**"Community members can submit skills and receive automated security analysis within 5 minutes, with zero exposure to real credentials."**

---

## 🎯 Objective
Create testing framework where community submits skill samples and gets automated security analysis.

## ✅ INVEST Criteria
- **Independent:** Web form works standalone
- **Negotiable:** API accepts common formats
- **Valuable:** Enables community security validation
- **Estimable:** ~1 week effort
- **Small:** MVP can ship in 2 days
- **Testable:** Submit test skill → get report

## ✅ Definition of Done (DoD) Checklist
- [ ] Web form for skill submission
- [ ] API endpoint functional
- [ ] YARA rule validation
- [ ] Credential exposure detection
- [ ] Results dashboard
- [ ] Test harness with mocks
- [ ] No real credentials in tests

## ✅ Security Acceptance Criteria
- [ ] All submissions scanned in Docker isolation
- [ ] No real credentials in test environment
- [ ] Results anonymized
- [ ] No credential storage
- [ ] Test data only (fake/sample data)

---

## Test Harness (Secure)

```python
# test_framework.py
# Uses mocks only - NO real credentials

def test_scan_malicious_skill():
    # Use sample malicious pattern (not real malware)
    sample = create_test_skill_with_pattern("suspicious_eval")
    result = scan_skill(sample)
    assert result.threat_detected == True

def test_scan_clean_skill():
    # Use known clean sample
    sample = create_test_skill("hello_world")
    result = scan_skill(sample)
    assert result.threat_detected == False

def test_no_credentials_exposed():
    # Verify no real keys in results
    result = scan_skill(test_skill)
    assert "sk-" not in result.raw_output
    assert "password" not in result.raw_output.lower()
```

---

## API Usage

```bash
# Submit skill (test data only)
curl -X POST https://api.agentsecurityframework.com/v1/scan \
  -F "skill=@test_skill.zip"

# Check results
curl https://api.agentsecurityframework.com/v1/results/{scan_id}
```

---

*Status: Ready for security scan + review*
