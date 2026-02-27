# 📧 Email Setup Guide for All OpenClaw Agents

**Complete setup for agent email access with Gmail App Passwords**

---

## 🎯 Agent Email Accounts (scrumai.org)

| Agent | Email Address | Status | App Password Needed |
|-------|---------------|--------|---------------------|
| Raven (Product Owner) | agent.saturday@scrumai.org | ⚠️ Not signed in | ✅ Required |
| Research Agent | asf.research@scrumai.org | ⚠️ Not signed in | ✅ Required |
| Social Agent | asf.social@scrumai.org | ⚠️ Not signed in | ✅ Required |
| Sales Agent | asf.sales@scrumai.org | ⚠️ Not signed in | ✅ Required |
| Deploy Agent | asf.deploy@scrumai.org | ⚠️ Not signed in | ✅ Required |
| Jeff Sutherland | jeff.sutherland@scrumai.org | ✅ Active | ✅ Required |

---

## 📋 Step-by-Step Setup Process

### Step 1: Generate Gmail App Passwords

For **EACH** email account, you need to create an app password:

1. **Sign in to the Google Account**
   - Go to: https://myaccount.google.com
   - Sign in as: `agent.saturday@scrumai.org` (or other agent email)

2. **Enable 2-Step Verification** (if not already enabled)
   - Go to: Security → 2-Step Verification
   - Follow prompts to enable

3. **Create App Password**
   - Go to: https://myaccount.google.com/apppasswords
   - Or: Security → 2-Step Verification → App passwords
   - Select app: **Mail**
   - Select device: **Other (Custom name)**
   - Name it: `OpenClaw Agent` or `Raven Email Access`
   - Click **Generate**
   - **SAVE THE 16-CHARACTER PASSWORD** (format: `xxxx xxxx xxxx xxxx`)

4. **Repeat for All 6 Accounts**
   - agent.saturday@scrumai.org
   - asf.research@scrumai.org
   - asf.social@scrumai.org
   - asf.sales@scrumai.org
   - asf.deploy@scrumai.org
   - jeff.sutherland@scrumai.org

---

## 🔧 Step 2: Update Email Checker Script

Once you have all app passwords, update the email configuration:

**File to edit:** `/Users/jeffsutherland/clawd/check-email.py`

### Add New Accounts Section

Find the `ACCOUNTS` dictionary in `check-email.py` and add:

```python
ACCOUNTS = {
    # ... existing accounts ...

    # Agent Email Accounts (scrumai.org)
    'agent-saturday': {
        'name': 'Agent Saturday (Raven)',
        'email': 'agent.saturday@scrumai.org',
        'password': 'YOUR_16_CHAR_APP_PASSWORD_HERE',
        'imap_server': 'imap.gmail.com',
        'imap_port': 993
    },
    'asf-research': {
        'name': 'ASF Research Agent',
        'email': 'asf.research@scrumai.org',
        'password': 'YOUR_16_CHAR_APP_PASSWORD_HERE',
        'imap_server': 'imap.gmail.com',
        'imap_port': 993
    },
    'asf-social': {
        'name': 'ASF Social Agent',
        'email': 'asf.social@scrumai.org',
        'password': 'YOUR_16_CHAR_APP_PASSWORD_HERE',
        'imap_server': 'imap.gmail.com',
        'imap_port': 993
    },
    'asf-sales': {
        'name': 'ASF Sales Agent',
        'email': 'asf.sales@scrumai.org',
        'password': 'YOUR_16_CHAR_APP_PASSWORD_HERE',
        'imap_server': 'imap.gmail.com',
        'imap_port': 993
    },
    'asf-deploy': {
        'name': 'ASF Deploy Agent',
        'email': 'asf.deploy@scrumai.org',
        'password': 'YOUR_16_CHAR_APP_PASSWORD_HERE',
        'imap_server': 'imap.gmail.com',
        'imap_port': 993
    },
    'jeff-scrumai': {
        'name': 'Jeff Sutherland (ScrumAI)',
        'email': 'jeff.sutherland@scrumai.org',
        'password': 'YOUR_16_CHAR_APP_PASSWORD_HERE',
        'imap_server': 'imap.gmail.com',
        'imap_port': 993
    }
}
```

---

## 🚀 Step 3: Test Email Access

After updating the script with app passwords:

```bash
# Test Agent Saturday (Raven)
python3 ~/clawd/check-email.py agent-saturday

# Test Research Agent
python3 ~/clawd/check-email.py asf-research

# Test Social Agent
python3 ~/clawd/check-email.py asf-social

# Test Sales Agent
python3 ~/clawd/check-email.py asf-sales

# Test Deploy Agent
python3 ~/clawd/check-email.py asf-deploy

# Test Jeff's ScrumAI account
python3 ~/clawd/check-email.py jeff-scrumai

# Check all accounts at once
python3 ~/clawd/check-email.py
```

---

## 📖 Agent Usage Instructions

### For Raven (Product Owner Agent)

**Check your Agent Saturday email:**
```bash
python3 /workspace/check-email.py agent-saturday
```

**Check recent 10 emails:**
```bash
python3 /workspace/check-email.py agent-saturday --count 10
```

### For Research Agent

**Check your research email:**
```bash
python3 /workspace/check-email.py asf-research --count 10
```

### For Social Agent

**Check your social media coordination email:**
```bash
python3 /workspace/check-email.py asf-social --count 10
```

### For Sales Agent

**Check your sales email:**
```bash
python3 /workspace/check-email.py asf-sales --count 10
```

### For Deploy Agent

**Check your deployment notifications:**
```bash
python3 /workspace/check-email.py asf-deploy --count 10
```

---

## 🔐 Security Best Practices

### App Password Storage

1. **DO NOT commit app passwords to git**
   - Add `check-email.py` to `.gitignore` if it contains passwords
   - Or use environment variables (see below)

2. **Use Environment Variables (Recommended)**

   Instead of hardcoding passwords in the script, use:

   ```python
   import os

   ACCOUNTS = {
       'agent-saturday': {
           'name': 'Agent Saturday (Raven)',
           'email': 'agent.saturday@scrumai.org',
           'password': os.getenv('AGENT_SATURDAY_PASSWORD'),
           'imap_server': 'imap.gmail.com',
           'imap_port': 993
       },
       # ... etc
   }
   ```

   Then set in `~/.zshrc`:
   ```bash
   export AGENT_SATURDAY_PASSWORD="xxxx xxxx xxxx xxxx"
   export ASF_RESEARCH_PASSWORD="xxxx xxxx xxxx xxxx"
   # ... etc
   ```

3. **Secure File Permissions**
   ```bash
   chmod 600 ~/clawd/check-email.py
   ```

---

## 📊 Current Email Status

### Working Accounts (Already Configured)

| Account | Email | Status |
|---------|-------|--------|
| `scrum` | jeff.sutherland@scruminc.com | ✅ 21,827 emails |
| `ff` | drjeffsutherland@frequencyfoundation.com | ✅ 4,114 emails |
| `gmail` | jeff.sutherland@gmail.com | ✅ Working |
| `drjeff` | drjeffsutherland@gmail.com | ✅ Working |

### New Accounts (Need App Passwords)

| Account | Email | Status |
|---------|-------|--------|
| `agent-saturday` | agent.saturday@scrumai.org | ⚠️ Needs app password |
| `asf-research` | asf.research@scrumai.org | ⚠️ Needs app password |
| `asf-social` | asf.social@scrumai.org | ⚠️ Needs app password |
| `asf-sales` | asf.sales@scrumai.org | ⚠️ Needs app password |
| `asf-deploy` | asf.deploy@scrumai.org | ⚠️ Needs app password |
| `jeff-scrumai` | jeff.sutherland@scrumai.org | ⚠️ Needs app password |

---

## 🆘 Troubleshooting

### "Authentication failed"
- **Cause:** Wrong app password or 2-Step Verification not enabled
- **Fix:** Generate a new app password, ensure 2-Step is enabled

### "Account not found in script"
- **Cause:** Account not added to `check-email.py`
- **Fix:** Add account to ACCOUNTS dictionary

### "Permission denied"
- **Cause:** File permissions too restrictive
- **Fix:** `chmod 644 ~/clawd/check-email.py`

### "Connection timeout"
- **Cause:** Network issue or wrong IMAP server
- **Fix:** Verify `imap.gmail.com` port `993` is accessible

---

## 📝 Quick Setup Checklist

- [ ] Sign in to agent.saturday@scrumai.org
- [ ] Enable 2-Step Verification
- [ ] Generate app password
- [ ] Save app password securely
- [ ] Repeat for all 6 agent accounts
- [ ] Update check-email.py with all passwords
- [ ] Test each account with check-email.py
- [ ] Verify agents can access their email
- [ ] Update .gitignore to exclude passwords
- [ ] Consider using environment variables

---

## 🔗 Useful Links

- **Google App Passwords:** https://myaccount.google.com/apppasswords
- **2-Step Verification:** https://myaccount.google.com/security
- **Gmail IMAP Settings:** https://support.google.com/mail/answer/7126229

---

## 📞 Quick Reference

```bash
# After setup, agents use these commands:

# Raven checks Agent Saturday email
python3 /workspace/check-email.py agent-saturday --count 10

# Research Agent checks email
python3 /workspace/check-email.py asf-research --count 10

# Social Agent checks email
python3 /workspace/check-email.py asf-social --count 10

# Sales Agent checks email
python3 /workspace/check-email.py asf-sales --count 10

# Deploy Agent checks email
python3 /workspace/check-email.py asf-deploy --count 10

# Check all agent emails at once
python3 /workspace/check-email.py
```

---

**Created:** February 23, 2026
**Status:** ⚠️ Waiting for app passwords to be generated
**Next Step:** Generate 6 app passwords from Google Admin

---

**Once app passwords are generated, all agents will have email access! 📧✅**
