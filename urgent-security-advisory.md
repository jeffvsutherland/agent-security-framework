# 🚨 URGENT SECURITY ADVISORY 🚨
## OpenClaw/Clawdbot Critical Vulnerabilities

**Date:** February 17, 2026  
**Severity:** CRITICAL (10/10)  
**Affected Versions:** All versions including v2026.2.14 (latest)  
**Confirmed by:** ASF Team + Grok AI Independent Analysis

## Executive Summary
OpenClaw has critical vulnerabilities allowing any skill to steal ALL API keys and credentials from the host environment. These vulnerabilities directly caused the Moltbook breach (1M+ credentials stolen) and affect 42,000+ exposed instances globally.

## Critical Vulnerabilities

### 1. Oracle Skill - THE MOLTBOOK BREACH VECTOR
- **Location:** Auto-reads OPENAI_API_KEY from environment
- **Impact:** This exact vulnerability caused the Moltbook breach
- **Status:** UNCHANGED in latest version (v2026.2.14)

### 2. OpenAI-Image-Gen Skill
- **Location:** Line 176 in scripts/gen.py
- **Impact:** Direct credential exposure
- **Status:** Still vulnerable

### 3. Systemic Design Flaw
- Skills run with FULL host access
- No permission isolation
- Any skill can read ANY environment variable

## Confirmed Impact
- **42,000+** exposed OpenClaw instances (SecurityScorecard)
- **1,000,000+** credentials stolen in Moltbook breach
- **6,000+** user databases compromised
- **$30,000+** in stolen API credits
- **0/100** security score (OX Security, Wiz, Palo Alto)

## Immediate Actions Required

### For Users:
1. **REMOVE** environment variables containing API keys
2. **ROTATE** all API keys immediately
3. **AUDIT** installed skills for malicious code
4. **INSTALL** ASF secure versions when available

### For OpenClaw Team:
1. Implement credential isolation (NOT environment variables)
2. Add per-skill permission system
3. Sandbox skill execution
4. Security audit all core skills

## ASF Solution Available
The Agent Security Framework provides:
- ✅ Secure skill versions (oracle-secure, openai-image-gen-secure)
- ✅ Encrypted credential storage
- ✅ Permission-based access control
- ✅ Automated vulnerability scanning

**GitHub:** https://github.com/jeffvsutherland/asf-security-scanner

## Timeline
- **48 hours:** Find official OpenClaw security channels
- **7 days:** Public disclosure if no response
- **NOW:** Users should take immediate protective action

## References
- Grok AI Security Analysis (Feb 17, 2026)
- Moltbook Breach Post-Mortem
- SecurityScorecard OpenClaw Report
- ASF Security Scanner Results

---
*This advisory will be submitted through official channels once located*