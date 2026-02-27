# OpenClaw Security Reporting Channels

**As of February 18, 2026**

## 🔍 Official Channels (Based on Standard Practices)

### 1. **GitHub Security Tab**
- **URL:** https://github.com/openclaw/openclaw/security
- Look for:
  - SECURITY.md file
  - Security Advisories section
  - "Report a vulnerability" button

### 2. **Common Security Emails** (Try these)
- security@openclaw.ai
- security@openclaw.com
- vulnerabilities@openclaw.ai
- disclosure@openclaw.ai

### 3. **Discord Community**
- **URL:** https://discord.com/invite/clawd
- Look for:
  - #security channel
  - Admin/moderator contacts
  - Security team members

### 4. **Documentation Site**
- **URL:** https://docs.openclaw.ai
- Check for security reporting guidelines

## 📝 What We Know

From our attempts on February 16, 2026:
- Direct contact to creator resulted in: "Use proper channels, can't handle direct reports"
- This suggests formal channels exist but weren't specified

## 🎯 Recommended Approach

1. **Check GitHub First**
   ```bash
   # Look for SECURITY.md in the repo
   # Usually at: https://github.com/openclaw/openclaw/blob/main/SECURITY.md
   ```

2. **Follow Coordinated Disclosure**
   - 90-day disclosure timeline is standard
   - Provide:
     - Detailed vulnerability description
     - Proof of concept (our scanner results)
     - Suggested fixes (our wrapper scripts)
     - CVSS score estimate (8.8 High)

3. **Email Template**
   ```
   Subject: [SECURITY] Critical API Key Exposure in Default Skills
   
   Dear OpenClaw Security Team,
   
   We have discovered critical vulnerabilities in OpenClaw's default skills
   that allow malicious actors to steal API keys from environment variables.
   
   Affected versions: Latest (2026.2.15) and likely all previous versions
   Severity: HIGH (CVSS 8.8)
   
   We have developed patches and are following coordinated disclosure.
   Full details in attached report.
   
   Please confirm receipt and provide a security contact for further discussion.
   ```

## 🚨 If No Response in 48 Hours

Consider escalating through:
1. Public GitHub issue (without exploit details)
2. Discord announcement (warning only, no exploit)
3. Responsible disclosure on Moltbook (after 90 days)

## 📊 Standard Security Contacts to Try

Based on common patterns:
- **GitHub:** /security/advisories/new
- **Email:** security@[domain]
- **Form:** Often at [domain]/security or /report-vulnerability
- **Bug Bounty:** Check if they use HackerOne, Bugcrowd, etc.

---

**Note:** Since OpenClaw is open source, the GitHub repository is likely the primary channel for security reports.