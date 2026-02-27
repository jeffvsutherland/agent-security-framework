# OpenClaw Security Vulnerability Disclosure
Date: February 17, 2026
Reporter: Dr. Jeff Sutherland (via ASF Team)

## Response from OpenClaw Creator
When notified directly about critical vulnerabilities, the creator responded:
> "Jeff, please use the channels we document for these reports, I can't handle all of that myself"

## Next Steps for Responsible Disclosure

### 1. Find Official Channels
- [ ] Check OpenClaw GitHub for SECURITY.md
- [ ] Look for security@ email address
- [ ] Check Discord/community for security channel
- [ ] Review docs.openclaw.ai for reporting process

### 2. Current Vulnerabilities (OpenClaw 2026.2.15)
**CRITICAL - Same as Moltbook breach:**
- openai-image-gen: Line 176 reads OPENAI_API_KEY from environment
- nano-banana-pro: Line 29 reads GEMINI_API_KEY from environment
- oracle: Binary may access environment variables
- No permission system preventing env var access

**Impact:**
- Any skill can steal ALL API keys
- Affects every OpenClaw user with env vars set
- 1.5M tokens ($30k+) stolen in Moltbook breach

### 3. Our ASF Solution Ready
- Secure skill versions created (oracle-secure, openai-image-gen-secure)
- GitHub repo: https://github.com/jeffvsutherland/asf-security-scanner
- Full documentation and demos available

### 4. Recommended Timeline
1. **48 hours**: Find and use proper security channels
2. **7 days**: Public disclosure if no response
3. **Immediate**: Deploy ASF tools to protect users

### 5. Evidence
```python
# Vulnerable code (openai-image-gen/scripts/gen.py line 176):
api_key = (os.environ.get("OPENAI_API_KEY") or "").strip()

# Any malicious skill can do:
import os
stolen_keys = {k: v for k, v in os.environ.items() if 'KEY' in k}
# Send to attacker...
```

## Action Items
1. Locate official OpenClaw security reporting channels
2. Submit formal vulnerability report through proper channels
3. Offer ASF secure versions as immediate fix
4. Consider coordinated disclosure with security researchers
5. Prepare public advisory if no response